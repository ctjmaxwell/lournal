import 'package:flutter/material.dart';

/// Displays a custom snackbar with a given [message].
///
/// The snackbar has a floating behavior and rounded corners.
/// The [backgroundColor] is optional and defaults to the theme's tertiary color.
void showCustomSnackBar(
  BuildContext context,
  String message, {
  // Added an optional, nullable Color parameter.
  Color? backgroundColor,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      // Use the provided backgroundColor, or fall back to the theme color if it's null.
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.tertiary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 3),
    ),
  );
}