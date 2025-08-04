import 'package:flutter/material.dart';
import 'package:lournal/components/custom_circular_progress_indicator.dart';
import 'package:lournal/components/custom_snackbar.dart';
import 'package:lournal/helper/language_and_type_helper.dart';
import 'package:lournal/helper/language_option.dart';
import 'package:lournal/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LanguageLearnPage extends StatefulWidget {
  final String nativeLanguage;
  final bool isEditing;

  const LanguageLearnPage({
    super.key,
    required this.nativeLanguage,
    this.isEditing = false,
  });

  @override
  State<LanguageLearnPage> createState() => _LanguageLearnPageState();
}

class _LanguageLearnPageState extends State<LanguageLearnPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _selectedLanguage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = null;
  }

  void _toggleLanguageSelection(String language) {
    setState(() {
      if (_selectedLanguage == language) {
        _selectedLanguage = null;
      } else {
        _selectedLanguage = language;
      }
    });
  }

  Future<void> _onDone() async {
    if (_isSaving) return;

    if (_selectedLanguage == null) {
      showCustomSnackBar(
        context,
        'Please select a language to learn.',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (widget.nativeLanguage == _selectedLanguage) {
      showCustomSnackBar(
        context,
        'Learning language must be different from the language you speak.',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // This should not happen if the user is on this page, but it's a safe check
        throw Exception("No authenticated user found.");
      }

      await _firestoreService.setUserPreferences(
        uid: user.uid,
        nativeLanguage: widget.nativeLanguage,
        learningLanguage: _selectedLanguage!,
        onboardingComplete: true,
      );

      if (mounted) {
        if (widget.isEditing) {
          int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 2);
        } else {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          context,
          'Failed to save preferences. Please try again.',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Text(
                      "What is the main language\nyou want to learn?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...supportedLanguages.map((language) {
                    final isSelected = _selectedLanguage == language;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: LanguageOption(
                        flagCode: getCountryCodeForLanguage(language),
                        language: language,
                        isSelected: isSelected,
                        onTap: () => _toggleLanguageSelection(language),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.tertiary,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(120),
                        ),
                      ),
                      onPressed: _onDone,
                      child: _isSaving
                          ? const CustomCircularProgressIndicator(
                              color: Colors.white)
                          : const Text(
                              "Done",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
