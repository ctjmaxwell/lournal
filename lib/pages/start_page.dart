import 'package:flutter/material.dart';
import 'package:lournal/l10n/app_localizations.dart';
import 'package:lournal/pages/login_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 50), // Added 50 bottom padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Added logo in a circle with tertiary theme color
                      // CHANGE BELOW
                      Container(
                        width: 200,
                        height: 200,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('lib/assets/lournal-logo-background.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // CHANGE ABOVE
                      const SizedBox(height: 24),
                      Text(
                        "Lournal",
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.startPageSlogan,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 36),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(AppLocalizations.of(context)!.getStarted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}