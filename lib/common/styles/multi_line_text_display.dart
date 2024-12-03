import 'package:flutter/material.dart';

/// A widget that displays text, allowing it to be split into multiple lines
/// based on a specified character threshold.
///
/// This widget is useful for displaying dynamic text content that may be
/// too long to fit on a single line. It automatically splits the text
/// into multiple lines when the length exceeds the defined threshold.
class MultiLineTextDisplay extends StatelessWidget {
  final String text; // The text to be displayed
  final TextStyle? style; // Optional text style for customization
  final int thresholdLength; // The threshold length for splitting the text

  const MultiLineTextDisplay({
    super.key,
    required this.text,
    this.style,
    this.thresholdLength = 20, // Default threshold length
  });

  @override
  Widget build(BuildContext context) {
    // Check if the text exceeds the threshold
    bool shouldSplit = text.length > thresholdLength;

    return shouldSplit
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Split the text and display the first part
              Text(
                text.substring(
                    0, text.lastIndexOf(' ')), // Display all but the last word
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // Ellipsis if text overflows
              ),
              // Display the last part of the text
              Text(
                text.split(' ').last, // Display the last word
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // Ellipsis if text overflows
              ),
            ],
          )
        : Text(
            text, // Display the full text if under threshold
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis, // Ellipsis if text overflows
          );
  }
}

/// This file contains the MultiLineTextDisplay widget, which is commonly used
/// throughout the app to display product names, descriptions, or any text content
/// that may vary in length. The widget ensures that text is displayed neatly and
/// is responsive to the available space, making it a reusable and versatile
/// component for better text handling in the user interface.
