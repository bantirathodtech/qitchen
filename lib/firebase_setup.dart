import 'package:firebase_core/firebase_core.dart' show Firebase, FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

// Purpose: Centralizes Firebase configuration for all platforms (web, Android, iOS)
// Usage: Call initializeFirebase() from main.dart to set up Firebase before running the app
// Why: Separates setup logic for clarity, maintainability, and reusability

class FirebaseSetup {
  // Step 1: Define platform-specific FirebaseOptions
  // Why: Each platform requires unique keys and IDs for Firebase initialization
  static const FirebaseOptions _webOptions = FirebaseOptions(
    apiKey: 'AIzaSyAJ5q5h8QIfDuU55Ib8_9fy6XXc9EPePSk', // From Firebase Console (web)
    appId: '1:910425365277:web:27e71d6abaa27ca46b9ff4', // Latest web appId
    messagingSenderId: '910425365277', // Project number
    projectId: 'cw-food-ordering', // Project ID
    authDomain: 'cw-food-ordering.firebaseapp.com', // Auth domain
    storageBucket: 'cw-food-ordering.appspot.com', // Consistent with Android
    measurementId: 'G-KLQWQN2WGB', // Optional, for analytics
  );

  static const FirebaseOptions _androidOptions = FirebaseOptions(
    apiKey: 'AIzaSyBvpsZ8Dsi7n67Gr77wdfS_s7XJD1ljGS0', // From google-services.json
    appId: '1:910425365277:android:968761a03dbfb8f46b9ff4', // Android appId
    messagingSenderId: '910425365277', // Project number
    projectId: 'cw-food-ordering', // Project ID
    storageBucket: 'cw-food-ordering.appspot.com', // Storage bucket
  );

  static const FirebaseOptions _iosOptions = FirebaseOptions(
    apiKey: 'AIzaSyDfKwuoNyrcSGvVERaB1xy0n62EZnkQSDc', // From GoogleService-Info.plist
    appId: '1:910425365277:ios:d8827f97aaf9945b6b9ff4', // iOS appId
    messagingSenderId: '910425365277', // Project number
    projectId: 'cw-food-ordering', // Project ID
    storageBucket: 'cw-food-ordering.appspot.com', // Storage bucket
    iosBundleId: 'com.reusable.firebasePhoneAuth', // From Firebase Console
  );

  // Step 2: Select the appropriate options based on the platform
  // Why: Ensures Firebase initializes with the correct config for web, Android, or iOS
  static FirebaseOptions _getOptions() {
    if (kIsWeb) {
      return _webOptions;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidOptions;
      case TargetPlatform.iOS:
        return _iosOptions;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError('Firebase is not supported on this platform.');
      default:
        throw UnsupportedError('Unknown platform.');
    }
  }

  // Step 3: Initialize Firebase with the selected options
  // Usage: Call this method before runApp() in main.dart
  // Why: Ensures Firebase is ready for OTP authentication across all platforms
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: _getOptions(),
    );
  }
}