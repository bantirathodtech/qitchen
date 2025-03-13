import 'package:flutter/material.dart';

class AppTheme {
  // Define common colors
  static const Color primaryColor = Color(0xFF6200EA);
  static const Color backgroundColor = Colors.white; // Pure white background
  static const Color errorColor = Colors.red;

  // Define a light theme
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    // Customize other aspects of the theme
    textTheme: TextTheme(
      displayLarge: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
      labelLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
    ),
  );
}
