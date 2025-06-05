import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lournal/auth/auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Logout user
  void logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            // This Expanded centers the profile section in the available space
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                children: [
                  // Profile pic
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: const EdgeInsets.all(25),
                    child: Icon(
                      Icons.person,
                      size: 150,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  const SizedBox(height: 20), // Spacing between profile pic and text
                  
                  user == null
                      ? const Text(
                          "No user logged in",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        )
                      : Column(
                          children: [
                            Text(
                              
                              user.displayName ?? 'No name set',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              user.email ?? 'No email',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            // Logout button at the bottom
            SizedBox(
              width: double.infinity, // Full width button
              child: ElevatedButton(
                onPressed: () => logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text("Log Out"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
