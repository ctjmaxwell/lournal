import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lournal/pages/notes_page.dart';
import 'package:lournal/pages/start_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Consider removing this Scaffold if StartPage and NotesPage provide their own.
    // If you keep it, ensure it's not conflicting with Scaffolds in child pages.
    // For now, let's assume StartPage and NotesPage are full Scaffold widgets.
    return StreamBuilder<User?>( // Explicitly type the StreamBuilder
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, AsyncSnapshot<User?> snapshot) { // Explicitly type the AsyncSnapshot
        // --- Debugging Print Statement ---
        print("AuthPage StreamBuilder rebuilding: ConnectionState: ${snapshot.connectionState}, HasData: ${snapshot.hasData}, User UID: ${snapshot.data?.uid}, Error: ${snapshot.error}");

        // 1. Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold( // A temporary Scaffold for the loading indicator is fine
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Handle error state (optional but good practice)
        if (snapshot.hasError) {
          return Scaffold( // A temporary Scaffold for the error message
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        // 3. User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          print("AuthPage: User is logged in. Showing NotesPage.");
          return NotesPage(); // Ensure NotesPage is a complete page (likely with its own Scaffold)
        }
        // 4. User is not logged in
        else {
          print("AuthPage: User is NOT logged in. Showing StartPage.");
          return const StartPage(); // Ensure StartPage is a complete page (likely with its own Scaffold)
        }
      },
    );
  }
}