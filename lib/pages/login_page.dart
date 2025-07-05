import 'dart:async'; // Import the async library for the Timer

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lournal/auth/google_auth.dart';
import 'package:lournal/components/custom_circular_progress_indicator.dart';
import 'package:lournal/components/custom_snackbar.dart';
import 'package:lournal/components/my_textfield.dart';
import 'package:lournal/pages/forgot_password.dart';
import 'package:lournal/pages/register_page.dart';




class LoginPage extends StatefulWidget {
  // Add this field to allow injecting a mock FirebaseAuth instance for testing.
  final FirebaseAuth? auth;

  // Update the constructor to accept the optional 'auth' parameter.
  const LoginPage({super.key, this.auth});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isEmailInvalid = false;
  bool _passwordInvalid = false;

  // Tracks when the cooldown for resending an email ends.
  DateTime? _resendCooldownEnd;

  @override
  void initState() {
    super.initState();
    // Listener to clear the email error state when the user types.
    emailController.addListener(() {
      if (_isEmailInvalid) {
        setState(() {
          _isEmailInvalid = false;
        });
      }
    });
    // Listener to clear the password error state when the user types.
    passwordController.addListener(() {
      if (_passwordInvalid) {
        setState(() {
          _passwordInvalid = false;
        });
      }
    });
  }

  // Get an instance of your AuthService
  final AuthService _authService = AuthService.instance;

  // Method to handle the Google Sign-In flow
  void signInWithGoogle() async {
    // Unfocus nodes to dismiss keyboard
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();

    if (!mounted) return;

    // Show loading circle
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CustomCircularProgressIndicator()),
    );

    try {
      // Call the signInWithGoogle method from your AuthService
      await _authService.signInWithGoogle();

      if (mounted) {
        Navigator.pop(context); // Pop loading circle
        // Navigate to home page or wherever you need to go after login
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading circle
        String message = 'An error occurred. Please try again.';
        if (e is FirebaseAuthException && e.code == 'sign_in_canceled') {
          message = 'Sign-in was canceled.';
        } else {
          message = e.toString();
        }
        showCustomSnackBar(context, message, backgroundColor: Colors.red);
      }
    }
  }
  

  void login() async {
    // Use the injected auth instance from the widget if it exists;
    // otherwise, fall back to the real FirebaseAuth.instance.
    final auth = widget.auth ?? FirebaseAuth.instance;

    // Unfocus nodes to dismiss the keyboard before showing a dialog or navigating.
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();

    if (!mounted) return;

    // Show a loading indicator while the login process is in progress.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CustomCircularProgressIndicator(),
        ),
      ),
    );

    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (mounted) Navigator.pop(context); // Pop loading circle

      final user = userCredential.user;
      if (user != null) {
        if (user.emailVerified) {
          // If the user is verified, pop all routes until the first one (home).
          if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          // If not verified, show the verification dialog, then sign out.
          await _showVerificationDialog(auth);
          await auth.signOut();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading circle
        String message = 'An error occurred. Please try again.';

        if (e.code == 'invalid-email') {
          setState(() {
            _isEmailInvalid = true;
            _passwordInvalid = false; // Ensure password field is not red
          });
          message = 'The email address is badly formatted.';
        } else if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          setState(() {
            _isEmailInvalid = true;
            _passwordInvalid = true;
          });
          message = 'Incorrect email or password. Please try again.';
        } else {
          setState(() {
            _isEmailInvalid = false;
            _passwordInvalid = false;
          });
          message = e.message ?? message;
        }
        showCustomSnackBar(context, message, backgroundColor: Colors.red);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading circle
        setState(() {
          _isEmailInvalid = false;
          _passwordInvalid = false;
        });
        showCustomSnackBar(
            context, "An unexpected error occurred. Please try again.",
            backgroundColor: Colors.red);
      }
    }
  }

  // Pass the auth instance to the dialog so it can be used for resending emails.
  Future<void> _showVerificationDialog(FirebaseAuth auth) async {
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _VerificationDialog(
          auth: auth, // Pass the auth instance to the dialog.
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

  // --- FIX: Handle the result from RegisterPage and show a snackbar on success ---
  void _navigateToAndClearFields(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((registrationResult) {
      if (mounted) {
        // Always clear fields when returning to the login page.
        emailController.clear();
        passwordController.clear();
        setState(() {
          _isEmailInvalid = false;
          _passwordInvalid = false;
        });

        // If registration was successful (returned true), show the snackbar.
        if (registrationResult == true) {
          showCustomSnackBar(
              context, "Account created! Please verify your email.");
        }
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
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
              MyTextField(
                hintText: "Email",
                obscureText: false,
                controller: emailController,
                hasError: _isEmailInvalid,
                focusNode: _emailFocusNode,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
              ),
              const SizedBox(height: 10),
              MyTextField(
                hintText: "Password",
                obscureText: true,
                controller: passwordController,
                hasError: _passwordInvalid,
                focusNode: _passwordFocusNode,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => login(),
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
                      // This now correctly handles the navigation to the RegisterPage
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
              ),
              // *** NEW: Divider ***
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25.0),
                child: Row(
                  children: [
                    Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400])),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('Or', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400])),
                  ],
                ),
              ),
              
              // *** NEW: Custom Google Sign-In Button ***
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, // Light grey background
                    foregroundColor: Theme.of(context).colorScheme.inversePrimary, // Dark grey text
                    elevation: 0, // No shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.inverseSurface, // Border color
                        width: 1.5, // Border width
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // You must add the Google logo to your assets
                      Image.asset(
                        'lib/assets/google.png', // Make sure you have this asset
                        height: 22.0,
                        width: 22.0,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}

// A stateful dialog to manage the cooldown timer for resending verification emails.
class _VerificationDialog extends StatefulWidget {
  final FirebaseAuth auth; // Instance passed from the LoginPage.
  final DateTime? cooldownEnd;
  final ValueChanged<DateTime> onResend;

  const _VerificationDialog({
    required this.auth,
    this.cooldownEnd,
    required this.onResend,
  });

  @override
  State<_VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<_VerificationDialog> {
  int _secondsRemaining = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.cooldownEnd != null) {
      final difference = widget.cooldownEnd!.difference(DateTime.now());
      if (!difference.isNegative) {
        _secondsRemaining = difference.inSeconds;
        startTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer?.cancel();
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
    const cooldownDuration = Duration(seconds: 30);
    widget.onResend(DateTime.now().add(cooldownDuration));
    if (mounted) {
      setState(() {
        _secondsRemaining = cooldownDuration.inSeconds;
      });
    }
    startTimer();

    try {
      // Use the injected auth instance to get the current user.
      final user = widget.auth.currentUser;
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
        showCustomSnackBar(context, message, backgroundColor: Colors.red);
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
            Text(
                'Please check your inbox and verify your email address to continue.'),
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
                ? Theme.of(context).colorScheme.surface // Disabled color
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

