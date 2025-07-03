// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lournal/auth/auth.dart';
import 'package:lournal/auth/google_auth.dart';
import 'package:lournal/firebase_options.dart';
import 'package:lournal/providers/cooldown_service.dart';
import 'package:lournal/providers/notes_provider.dart'; // 1. Import your new provider
import 'package:lournal/theme/dark_mode.dart';
import 'package:lournal/theme/light_mode.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService.instance.initialize();

  // // --- START TEMPORARY EMULATOR CONFIG ---
  // // if (kDebugMode) { // <--- ADD THIS
  //   try {
  //     FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  //     FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  //     await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //   } catch (e) {
  //     print('Failed to connect to Firebase Emulators: $e');
  //   }
  // //}
  // // --- END TEMPORARY EMULATOR CONFIG ---

  // Set preferred orientations to portrait for all iOS devices
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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