import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final bool hasError;
  // --- NEW ---
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;


  const MyTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.hasError = false,
    // --- NEW ---
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    );

    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: Theme.of(context).colorScheme.tertiary,
      // --- NEW ---
      focusNode: focusNode,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade600,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary,
        enabledBorder: hasError ? errorBorder : defaultBorder,
        focusedBorder: hasError ? errorBorder : defaultBorder,
      ),
    );
  }
}