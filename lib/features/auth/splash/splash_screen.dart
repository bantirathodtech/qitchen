import 'package:flutter/material.dart';
import '../../../common/log/loggers.dart';
import '../../../data/db/app_preferences.dart';
import '../../main/main_screen.dart';
import '../signin/signin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start checking login status immediately
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    try {
      // Get user data without any artificial delay
      Map<String, dynamic> userData = await AppPreference.getUserData();

      // Check if user is logged in
      bool isLoggedIn = userData.isNotEmpty;

      // Log the login status
      AppLogger.logInfo('User login status: $isLoggedIn');

      if (isLoggedIn) {
        AppLogger.logInfo('User data: $userData');
        AppLogger.logDebug('Navigating to MainScreen');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        AppLogger.logDebug('Navigating to SignInScreen');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        }
      }
    } catch (e) {
      AppLogger.logError('Error checking login status: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          'assets/images/splash_screen.png',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          // Add alignment to keep it fixed
          alignment: Alignment.center,
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
      ),
    );
  }
}
