import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lournal/auth/auth.dart';
import 'package:lournal/auth/google_auth.dart';
import 'package:lournal/firebase_options.dart';
import 'package:lournal/providers/cooldown_service.dart';
import 'package:lournal/providers/notes_provider.dart';
import 'package:lournal/providers/user_preferences_provider.dart';
import 'package:lournal/theme/dark_mode.dart';
import 'package:lournal/theme/light_mode.dart';
import 'package:provider/provider.dart';
import 'package:lournal/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService.instance.initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CooldownService()),
        ChangeNotifierProvider(create: (context) => NotesProvider()),
        ChangeNotifierProvider(create: (context) => UserPreferencesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferencesProvider>(
      builder: (context, prefsProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const AuthPage(),
          theme: lightMode,
          darkTheme: darkMode,
          
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}