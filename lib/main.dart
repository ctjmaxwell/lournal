import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lournal/auth/auth.dart';
import 'package:lournal/firebase_options.dart';
import 'package:lournal/providers/cooldown_service.dart';
import 'package:lournal/providers/notes_provider.dart'; // 1. Import your new provider
import 'package:lournal/theme/dark_mode.dart';
import 'package:lournal/theme/light_mode.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Replace ChangeNotifierProvider with MultiProvider
  runApp(
    MultiProvider(
      providers: [
        // 3. List all of your providers here
        ChangeNotifierProvider(create: (context) => CooldownService()),
        ChangeNotifierProvider(create: (context) => NotesProvider()),
      ],
      child: const MyApp(), // Your app is the child
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}