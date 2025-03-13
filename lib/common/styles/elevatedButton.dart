import 'package:flutter/material.dart';

import 'app_text_styles.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final Color color;
  final double width;
  final double height;
  final VoidCallback onPressed; // Non-nullable, required
  final EdgeInsetsGeometry padding;
  final double elevation;
  final ButtonStyle? style;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.color,
    this.width = double.infinity,
    this.height = 40.0,
    required this.onPressed, // Make it required
    this.padding = const EdgeInsets.symmetric(
      vertical: 8.0,
      horizontal: 40.0,
    ),
    this.elevation = 2.0,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: style ??
            ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: padding,
              elevation: elevation,
            ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.buttonText,
        ),
      ),
    );
  }
}
