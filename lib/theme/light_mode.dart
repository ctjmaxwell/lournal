import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    surface: Color(0xFFB5B5B5),
    primary: Color(0xFFF6F6F6),
    secondary: Color(0xFFECECEC),
    inversePrimary: Color(0xFF505050),
    tertiary: Color(0xFF778BFF),
    inverseSurface: Color(0xFFCECECE),
  ),
  textTheme: GoogleFonts.poppinsTextTheme(
    ThemeData.light().textTheme,
  ).apply(
    bodyColor: const Color(0xFF585858),
    displayColor: const Color(0xFF585858),
  ),

  // The complete theme for text selection
  textSelectionTheme: const TextSelectionThemeData(
    // This styles the highlight background (which you've already done)
    selectionColor: Color(0xFF778BFF),
    
    // --- THIS LINE CONTROLS THE HANDLES ---
    // This styles the circular handles at the start and end of the selection
    selectionHandleColor: Color(0xFF778BFF), 
  ),
);