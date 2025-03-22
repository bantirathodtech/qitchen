import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  // Dynamically selects FirebaseOptions based on the platform
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError('Firebase is not supported on this platform.');
      default:
        throw UnsupportedError('Unknown platform.');
    }
  }

  // Web configuration (using the latest web app ID)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAJ5q5h8QIfDuU55Ib8_9fy6XXc9EPePSk', // Web API key
    appId: '1:910425365277:web:27e71d6abaa27ca46b9ff4', // Latest web appId
    messagingSenderId: '910425365277', // Project number
    projectId: 'cw-food-ordering', // Project ID
    authDomain: 'cw-food-ordering.firebaseapp.com', // Auth domain
    storageBucket: 'cw-food-ordering.firebasestorage.app', // Storage bucket
    measurementId: 'G-KLQWQN2WGB', // Optional, for analytics
  );

  // Android configuration (from google-services.json)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvpsZ8Dsi7n67Gr77wdfS_s7XJD1ljGS0', // Android API key
    appId: '1:910425365277:android:968761a03dbfb8f46b9ff4', // Android appId
    messagingSenderId: '910425365277', // Project number
    projectId: 'cw-food-ordering', // Project ID
    storageBucket: 'cw-food-ordering.appspot.com', // Storage bucket
  );

  // iOS configuration (placeholder, update with GoogleService-Info.plist)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY', // Add from GoogleService-Info.plist
    appId: '1:910425365277:ios:d8827f97aaf9945b6b9ff4', // iOS appId
    messagingSenderId: '910425365277', // Project number
    projectId: 'cw-food-ordering', // Project ID
    storageBucket: 'cw-food-ordering.appspot.com', // Storage bucket
    iosBundleId: 'com.reusable.firebasePhoneAuth', // From Firebase Console
  );
}