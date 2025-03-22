import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_setup.dart'; // Import the new setup file
import 'common/providers/app_multi_provider.dart';
import 'common/routes/app_routes.dart';
import 'common/styles/app_theme.dart';

// Purpose: Entry point of the Flutter app
// Step Flow:
// 1. Ensure widgets are initialized
// 2. Initialize Firebase using FirebaseSetup
// 3. Set up providers and run the app
// Why: Firebase must be initialized before using OTP features

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Step 1: Prepare Flutter bindings
  await FirebaseSetup.initializeFirebase(); // Step 2: Initialize Firebase
  runApp(
    MultiProvider(
      providers: getProviders(), // Step 3: Set up app providers
      child: const MyApp(),
    ),
  );
}

// Purpose: Check if the user is logged in using SharedPreferences
// Usage: Can be used to determine initial route (currently not in use)
// Why: Helps route users to the correct screen based on login status
Future<bool> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CW Food Ordering',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: Routes.splashScreen, // Start with splash screen
      routes: Routes.routes, // Defined routes from app_routes.dart
    );
  }
}