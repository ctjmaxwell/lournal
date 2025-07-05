import 'package:flutter/material.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  final double? value;
  final double strokeWidth;
  final Color? color;
  final String? semanticsLabel;
  final String? semanticsValue;

  const CustomCircularProgressIndicator({
    super.key,
    this.value,
    this.strokeWidth = 4.0,
    this.color,
    this.semanticsLabel,
    this.semanticsValue,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      value: value,
      strokeWidth: strokeWidth,
      semanticsLabel: semanticsLabel,
      semanticsValue: semanticsValue,
      valueColor: AlwaysStoppedAnimation<Color>(
        color ?? Theme.of(context).colorScheme.tertiary,
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
    );
  }
}