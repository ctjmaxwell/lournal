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
  ),
  textTheme: GoogleFonts.poppinsTextTheme(
    ThemeData.dark().textTheme,
  ).apply(
    bodyColor: Colors.grey.shade300,
    displayColor: Colors.white,
  ),
);
