import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lournal/components/custom_circular_progress_indicator.dart';
import 'package:lournal/pages/language_speak_page.dart';
import 'package:lournal/pages/notes_page.dart';
import 'package:lournal/pages/start_page.dart';
import 'package:lournal/providers/user_preferences_provider.dart';
import 'package:provider/provider.dart';

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
    return Consumer<UserPreferencesProvider>(
      builder: (context, prefsProvider, child) {
        if (prefsProvider.isLoading) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primary,
          );
        }

        if (prefsProvider.hasError) {
          return Scaffold(
            body: Center(child: Text('Error fetching user data: ${prefsProvider.error}')),
          );
        }

        final userPreferences = prefsProvider.userPreferences;

        if (userPreferences?.onboardingComplete != true) {
          return const LanguageSpeakPage();
        } else {
          return NotesPage(userPreferences: userPreferences!);
        }
      },
    );
  }
}