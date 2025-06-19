import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF595959),
    primary: Color(0xFF070707),
    secondary: Color(0xFF181818),
    inversePrimary: Color(0xFFCCCCCC),
    tertiary: Color(0xFF778BFF),
    inverseSurface: Colors.white54,
  ),
  textTheme: GoogleFonts.poppinsTextTheme(
    ThemeData.dark().textTheme,
  ).apply(
    bodyColor: Color(0xFFDEDEDE),
    displayColor: Color(0xFFDEDEDE),
  ),

  // The complete theme for text selection
  textSelectionTheme: TextSelectionThemeData(
    // This styles the highlight background (which you've already done)
    selectionColor: Color(0xFF778BFF),
    
    // --- THIS LINE CONTROLS THE HANDLES ---
    // This styles the circular handles at the start and end of the selection
    selectionHandleColor: Color(0xFF778BFF), 
  ),
);