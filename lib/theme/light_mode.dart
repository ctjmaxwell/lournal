import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Color.fromARGB(255, 129, 129, 129),
    primary: Colors.grey.shade200,
    secondary: const Color.fromARGB(255, 220, 220, 220),
    inversePrimary: Colors.grey.shade800,
    tertiary: Color(0xFF778BFF),
  ),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.grey.shade800,
    displayColor: Colors.black,
  ),
);