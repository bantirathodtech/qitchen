import 'package:flutter/material.dart';

import '../../../common/log/loggers.dart';
import '../../../data/db/app_preferences.dart';
import '../../main/main_screen.dart';
import '../signin/signin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    // Simulate a delay to show the splash screen
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Get user data
      Map<String, dynamic> userData = await AppPreference.getUserData();

      // Check if user is logged in
      bool isLoggedIn = userData.isNotEmpty;

      // Log the login status
      AppLogger.logInfo('User login status: $isLoggedIn');

      if (isLoggedIn) {
        // Log user data
        AppLogger.logInfo('User data: $userData');
        AppLogger.logInfo(
            'User phone number: ${userData['phone'] ?? 'No phone number'}');

        AppLogger.logDebug('Navigating to MainScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        AppLogger.logDebug('Navigating to SignInScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      }
    } catch (e) {
      AppLogger.logError('Error checking login status: $e');
      // In case of error, navigate to SignInScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/splash_screen.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Container(
          //     padding: const EdgeInsets.all(20.0),
          //     decoration: BoxDecoration(
          //       color: Colors.black.withOpacity(0.5), // Optional: for better readability
          //     ),
          //     child: Column(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         Text(
          //           'CW Food Ordering',
          //           style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          //             color: Colors.white,
          //           ),
          //         ),
          //         const SizedBox(height: 10),
          //         Text(
          //           'Version 1.0.0',
          //           style: Theme.of(context).textTheme.titleMedium?.copyWith(
          //             color: Colors.white,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
