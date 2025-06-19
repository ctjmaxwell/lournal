import 'dart:async'; // Import the async library for the Timer

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lournal/components/custom_snackbar.dart';
import 'package:lournal/components/my_textfield.dart';
import 'package:lournal/pages/forgot_password.dart';
import 'package:lournal/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // --- NEW: FocusNodes to manage text field focus ---
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isEmailInvalid = false;
  bool _passwordInvalid = false;

  // Tracks when the cooldown for resending an email ends.
  DateTime? _resendCooldownEnd;

  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      if (_isEmailInvalid) {
        setState(() {
          _isEmailInvalid = false;
        });
      }
    });
    // --- ADDED: Listener for password controller to clear error on input ---
    passwordController.addListener(() {
      if (_passwordInvalid) {
        setState(() {
          _passwordInvalid = false;
        });
      }
    });
  }

  void login() async {
    // Unfocus nodes to dismiss keyboard before showing dialog
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.tertiary,
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (mounted) Navigator.pop(context); // Pop loading circle

      final user = userCredential.user;
      if (user != null) {
        if (user.emailVerified) {
          if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          await _showVerificationDialog();
          await FirebaseAuth.instance.signOut();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        String message = 'An error occurred. Please try again.';

        if (e.code == 'invalid-email') {
          setState(() {
            _isEmailInvalid = true;
            _passwordInvalid = false; // Ensure password field is not red for email errors
          });
          message = 'The email address is badly formatted.';
        } else if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          setState(() {
            _isEmailInvalid = true;
            _passwordInvalid = true;
          });
          message = 'Incorrect email or password. Please try again.';
        } else {
           setState(() {
            _isEmailInvalid = false; // Assuming general errors might not be tied to a specific field.
            _passwordInvalid = false;
          });
          message = e.message ?? message;
        }
        showCustomSnackBar(context, message, backgroundColor: Colors.red);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        setState(() {
          _isEmailInvalid = false;
          _passwordInvalid = false; // Reset both on unexpected errors
        });
        showCustomSnackBar(context, "An unexpected error occurred. Please try again.", backgroundColor: Colors.red);
      }
    }
  }

  Future<void> _showVerificationDialog() async {
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _VerificationDialog(
          cooldownEnd: _resendCooldownEnd,
          onResend: (newCooldownTime) {
            if (mounted) {
              setState(() {
                _resendCooldownEnd = newCooldownTime;
              });
            }
          },
        );
      },
    );
  }

  void _navigateToAndClearFields(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) {
      if (mounted) {
        emailController.clear();
        passwordController.clear();
        setState(() {
          _isEmailInvalid = false;
          _passwordInvalid = false; // ADDED: Reset password error state
        });
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    // --- NEW: Dispose FocusNodes to prevent memory leaks ---
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Log In',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                'Welcome back to Lournal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 25),
              // --- MODIFIED: Email TextField ---
              MyTextField(
                hintText: "Email",
                obscureText: false,
                controller: emailController,
                hasError: _isEmailInvalid,
                focusNode: _emailFocusNode,
                textInputAction: TextInputAction.next, // Changes enter button to "Next"
                onSubmitted: (_) {
                  // When "Next" is pressed, focus the password field
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
              ),
              const SizedBox(height: 10),
              // --- MODIFIED: Password TextField ---
              MyTextField(
                hintText: "Password",
                obscureText: true,
                controller: passwordController,
                hasError: _passwordInvalid,
                focusNode: _passwordFocusNode,
                textInputAction: TextInputAction.done, // Changes enter button to "Done"
                onSubmitted: (_) => login(), // When "Done" is pressed, attempt to log in
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      _navigateToAndClearFields(const ForgotPasswordPage());
                    },
                    child: Text(
                      "Forgot password?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 36),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Log In'),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  GestureDetector(
                    onTap: () {
                      _navigateToAndClearFields(const RegisterPage());
                    },
                    child: Text(
                      " Register here",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- NEW WIDGET ---
// A stateful dialog to manage the cooldown timer.
class _VerificationDialog extends StatefulWidget {
  final DateTime? cooldownEnd;
  final ValueChanged<DateTime> onResend;

  const _VerificationDialog({this.cooldownEnd, required this.onResend});

  @override
  State<_VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<_VerificationDialog> {
  int _secondsRemaining = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Check if there's an existing cooldown from the parent widget.
    if (widget.cooldownEnd != null) {
      final difference = widget.cooldownEnd!.difference(DateTime.now());
      if (difference.isNegative == false) {
        _secondsRemaining = difference.inSeconds;
        startTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Important: cancel the timer to avoid memory leaks.
    super.dispose();
  }

  void startTimer() {
    _timer?.cancel(); // Cancel any existing timer.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendEmail() async {
    // Disable the button immediately and start the cooldown.
    const cooldownDuration = Duration(seconds: 30);
    widget.onResend(DateTime.now().add(cooldownDuration));
    if (mounted) {
      setState(() {
        _secondsRemaining = cooldownDuration.inSeconds;
      });
    }
    startTimer();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      }
      if (mounted) {
        Navigator.of(context).pop();
        showCustomSnackBar(context, "Verification email sent!");
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        final message = (e.code == 'too-many-requests')
            ? 'Too many requests. Please try again later.'
            : 'An error occurred: ${e.message}';
        showCustomSnackBar(context, message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOnCooldown = _secondsRemaining > 0;

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: const Text('Email Not Verified'),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Please check your inbox and verify your email address to continue.'),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: isOnCooldown
                ? Colors.grey.shade700 // Disabled color
                : Theme.of(context).colorScheme.tertiary,
            foregroundColor: Colors.white,
          ),
          onPressed: isOnCooldown ? null : _resendEmail,
          child: Text(
            isOnCooldown ? 'Resend in $_secondsRemaining' : 'Resend Email',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}