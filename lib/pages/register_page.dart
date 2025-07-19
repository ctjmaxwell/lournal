import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lournal/components/custom_circular_progress_indicator.dart';
import 'package:lournal/components/custom_snackbar.dart';
import 'package:lournal/components/my_textfield.dart';
import 'package:lournal/services/firestore.dart';
import 'package:lournal/sheets/privacy_policy_bottomsheet.dart';
import 'package:lournal/sheets/terms_and_conditions_bottomsheet.dart';

class RegisterPage extends StatefulWidget {
  final FirebaseAuth? auth;

  const RegisterPage({super.key, this.auth});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmationController = TextEditingController();

  // FocusNodes to manage text field focus
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmationFocusNode = FocusNode();

  // State variables for field-specific errors
  bool _isUsernameInvalid = false;
  bool _passwordInvalid = false;
  bool _isEmailInvalid = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to clear error states automatically when the user types
    usernameController.addListener(_clearUsernameError);
    passwordController.addListener(_clearPasswordError);
    confirmationController.addListener(_clearPasswordError);
    emailController.addListener(_clearEmailError);
  }

  @override
  void dispose() {
    // Clean up the controllers and listeners to prevent memory leaks
    usernameController.removeListener(_clearUsernameError);
    passwordController.removeListener(_clearPasswordError);
    confirmationController.removeListener(_clearPasswordError);
    emailController.removeListener(_clearEmailError);
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmationController.dispose();

    // Dispose FocusNodes to prevent memory leaks
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmationFocusNode.dispose();

    super.dispose();
  }

  void _clearUsernameError() {
    if (_isUsernameInvalid) {
      setState(() {
        _isUsernameInvalid = false;
      });
    }
  }

  void _clearPasswordError() {
    if (_passwordInvalid) {
      setState(() {
        _passwordInvalid = false;
      });
    }
  }

  void _clearEmailError() {
    if (_isEmailInvalid) {
      setState(() {
        _isEmailInvalid = false;
      });
    }
  }

  void registerUser() async {
    final auth = widget.auth ?? FirebaseAuth.instance;

    // Unfocus all nodes to dismiss the keyboard
    _usernameFocusNode.unfocus();
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    _confirmationFocusNode.unfocus();

    if (!mounted) return;

    // Reset all error states on a new submission attempt
    setState(() {
      _isUsernameInvalid = false;
      _passwordInvalid = false;
      _isEmailInvalid = false;
    });

    if (usernameController.text.trim().isEmpty) {
      showCustomSnackBar(context, "Username cannot be empty",
          backgroundColor: Colors.red);
      setState(() {
        _isUsernameInvalid = true;
      });
      return; // Stop execution
    }

    // show loading circle
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CustomCircularProgressIndicator(),
          ),
        );
      },
    );

    if (passwordController.text != confirmationController.text) {
      if (mounted) Navigator.pop(context); // Pop loading circle
      showCustomSnackBar(context, "Passwords do not match",
          backgroundColor: Colors.red);
      setState(() {
        _passwordInvalid = true;
      });
      return; // Stop execution
    }

    try {
      UserCredential? userCredential =
          await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await userCredential.user?.sendEmailVerification();
      await userCredential.user
          ?.updateDisplayName(usernameController.text.trim());

      // --- Create user document in Firestore with onboarding incomplete ---
      final firestoreService = FirestoreService();
      await firestoreService.setUserPreferences(
        uid: userCredential.user!.uid,
        nativeLanguage: '', // Set empty strings for now
        learningLanguage: '',
        email: userCredential.user?.email,
        displayName: usernameController.text.trim(),
      );

      // --- FIX: Sign out the user to prevent automatic login after registration ---
      await auth.signOut();

      // Pop the loading circle
      if (mounted) Navigator.pop(context);

      // --- FIX: Pop the RegisterPage and return 'true' to signal success ---
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context); // Pop loading circle on error

      if (mounted) {
        String errorMessage = e.message ?? "An unknown error occurred.";

        if (e.code == 'invalid-email') {
          setState(() {
            _isEmailInvalid = true;
          });
          showCustomSnackBar(context, errorMessage, backgroundColor: Colors.red);
        } else if (e.code == 'email-already-in-use') {
          setState(() {
            _isEmailInvalid = true;
          });
          showCustomSnackBar(context, errorMessage);
        } else if (e.code == 'weak-password') {
          setState(() {
            _passwordInvalid = true;
          });
          showCustomSnackBar(context, errorMessage);
        } else {
          showCustomSnackBar(context, errorMessage);
        }
      }
    }
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
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sign Up',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                'Sync your notes across devices',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 25),
              MyTextField(
                hintText: "Username",
                obscureText: false,
                controller: usernameController,
                hasError: _isUsernameInvalid,
                focusNode: _usernameFocusNode,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_emailFocusNode);
                },
              ),
              const SizedBox(height: 10),
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
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_confirmationFocusNode);
                },
              ),
              const SizedBox(height: 10),
              MyTextField(
                hintText: "Confirm Password",
                obscureText: true,
                controller: confirmationController,
                hasError: _passwordInvalid,
                focusNode: _confirmationFocusNode,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => registerUser(),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 12,
                    ),
                    children: [
                      const TextSpan(
                          text:
                              'By signing up, you agree to our '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showPrivacyPolicyBottomSheet(context);
                          },
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Terms and Conditions',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showTermsAndConditionsBottomSheet(context);
                          },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 36),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Sign Up'),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      " Login here",
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
