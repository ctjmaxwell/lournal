import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lournal/pages/notes_page.dart';
import 'package:lournal/pages/start_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {
          // user logged in
          if (snapshot.hasData) {
            return NotesPage();
          }

          // user not logged in
          else {
            return const StartPage();
          }
        }
      ),
    );
  }
}