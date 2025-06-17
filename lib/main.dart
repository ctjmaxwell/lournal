import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lournal/auth/auth.dart';
import 'package:lournal/firebase_options.dart';
import 'package:lournal/services/cooldown_service.dart'; // 1. Import the service
import 'package:lournal/theme/dark_mode.dart';
import 'package:lournal/theme/light_mode.dart';
import 'package:provider/provider.dart'; // 2. Import the provider package
// import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Wrap your app in the provider
  runApp(
    ChangeNotifierProvider(
      create: (context) => CooldownService(),
      child: const MyApp(),
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