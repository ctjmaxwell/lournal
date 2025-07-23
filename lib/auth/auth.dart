// auth.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lournal/components/custom_circular_progress_indicator.dart';
import 'package:lournal/pages/language_speak_page.dart';
import 'package:lournal/pages/notes_page.dart';
import 'package:lournal/pages/start_page.dart';
import 'package:lournal/services/firestore.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CustomCircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (snapshot.hasData) {
          return const OnboardingGate();
        } else {
          return const StartPage();
        }
      },
    );
  }
}


// --- WIDGET MODIFIED TO USE STREAMBUILDER ---

class OnboardingGate extends StatelessWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    // ✅ CHANGED: Use a StreamBuilder to listen for real-time updates
    return StreamBuilder<UserPreferences?>(
      // ✅ CHANGED: Use the stream method from your FirestoreService
      stream: firestoreService.streamUserPreferences(),
      builder: (context, snapshot) {
        // Show loading indicator while waiting for the first stream event
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primary,
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error fetching user data: ${snapshot.error}')),
          );
        }

        final userPreferences = snapshot.data;

        // ROUTING LOGIC (This remains the same)
        // If the stream provides data where onboarding is not complete, show the onboarding page.
        if (userPreferences?.onboardingComplete != true) {
          // You are correctly showing the LanguageSpeakPage you provided.
          // Note: The LanguageSpeakPage now doesn't need to worry about navigation,
          // it just pushes the next screen in the flow.
          return const LanguageSpeakPage();
        }
        // Otherwise, the stream has confirmed onboarding is complete, so show the main app.
        else {
          return NotesPage(userPreferences: userPreferences!);
        }
      },
    );
  }
}