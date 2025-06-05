import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lournal/components/my_textfield.dart';
import 'package:lournal/helper/helper_functions.dart';

class RegisterPage extends StatefulWidget {

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controllers
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmationController = TextEditingController();

  void registerUser() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    );

    // make sure passwords match
    if (passwordController.text != confirmationController.text) {
      // pop loading circle
      if (mounted) Navigator.pop(context);

      // show error message
      displayMessageToUser("Passwords do not match", context);
      return; // Stop further execution.
    } else {
      try {
        // create the user
        UserCredential? userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // update the user's displayName with the provided username
        await userCredential.user?.updateDisplayName(usernameController.text);
        
        // pop loading circle if the widget is still mounted
        if (mounted) Navigator.pop(context);
        
        // show success message
        if (mounted) {
          displayMessageToUser("Account created successfully!", context);
          
          // Navigate back to login page after short delay to allow user to read the message
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context); // This will return to the login page
            }
          });
        }
        
      } on FirebaseAuthException catch (e) {
        // pop loading circle if the widget is still mounted
        if (mounted) Navigator.pop(context);

        // show error message if the widget is still mounted
        if (mounted) {
          displayMessageToUser(e.code, context);
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
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

              // username textfield
              MyTextField(
                hintText: "Username", 
                obscureText: false, 
                controller: usernameController,
              ),

              const SizedBox(height: 10),

              // email textfield
              MyTextField(
                hintText: "Email", 
                obscureText: false, 
                controller: emailController,
              ),

              const SizedBox(height: 10),

              // password textfield
              MyTextField(
                hintText: "Password", 
                obscureText: true, 
                controller: passwordController,
              ),

              const SizedBox(height: 10),

              // confirmation textfield
              MyTextField(
                hintText: "Confirm Password", 
                obscureText: true, 
                controller: confirmationController,
              ),

              const SizedBox(height: 10),

              // forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "I have read and agree to the terms of service",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  registerUser();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 36),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Sign Up'),
              ),
            ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  GestureDetector(
                    onTap: () {
                      // Navigate to login page
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