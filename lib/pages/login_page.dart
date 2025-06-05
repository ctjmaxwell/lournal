import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lournal/components/my_textfield.dart';
import 'package:lournal/helper/helper_functions.dart';
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

  void login() async {
    if (!mounted) return; // Check if the widget is still in the tree

    // Show loading circle
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(), // Trim whitespace
        password: passwordController.text,
      );

      // Pop loading circle
      // Ensure the context for popping the dialog is correct and widget is mounted
      if (mounted) {
        Navigator.pop(context); // This pops the dialog
      }

      // After successful login, the StreamBuilder in AuthWrapper will handle
      // navigation to the NotesPage automatically.
      // The popUntil call here is to ensure that if LoginPage or other auth
      // screens (like RegisterPage if you can navigate back and forth)
      // were pushed on top of the AuthWrapper, they are all removed,
      // returning control to the AuthWrapper.
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      // No explicit navigation to NotesPage is needed here from LoginPage.
      // The AuthWrapper handles this based on the auth state change.

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop the dialog
        displayMessageToUser(e.code, context);
      }
    } catch (e) {
      // Catch any other generic errors
      if (mounted) {
        Navigator.pop(context); // Pop the dialog
        displayMessageToUser("An unexpected error occurred: ${e.toString()}", context);
      }
      print("Login error: $e"); // For debugging
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'Sync your notes across devices',
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
              ),
              const SizedBox(height: 10),
              MyTextField(
                hintText: "Password",
                obscureText: true,
                controller: passwordController,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Ensure ForgotPasswordPage also allows returning correctly
                      // or is handled within the AuthWrapper's scope if it changes auth state.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
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
                  onPressed: login, // Call the login method
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
                      // Pushing RegisterPage. If registration leads to auto-login,
                      // the AuthWrapper will pick it up.
                      // Ensure navigation back from RegisterPage behaves as expected.
                      Navigator.pushReplacement( // Consider pushReplacement if you don't want to return to Login from Register
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
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