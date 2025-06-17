import 'package:flutter/material.dart';

class TermsAndConditionsBottomSheet extends StatelessWidget {
  const TermsAndConditionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Terms and Conditions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                'Your terms and conditions text goes here. ', // Replace with your actual text
              ),
            ),
          ),
        ],
      ),
    );
  }
}