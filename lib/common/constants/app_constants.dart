// // app_constants.dart
// import '../share_preference/shared_preference_service.dart';
//
// class AppConstants {
//   // Define the API endpoint
//   static const String apiUrl = "https://sapp.mycw.in/fnbordering/graphql";
//
//   // Client ID
//   static const String clientId = "39BC576048054849BFBFEDBF29142A3E";
//
//   // Config ID
//   static const String configId = "2EF21B71E41C4730B6046409F979CC17";
//
//   //Commerce Config ID
//   static const String commerceConfigId = "26A6983253504DB893DD15176D2F1D87";
//
//   // Global variable to store the user's mobile number
//   static String mobileNum = '';
//
//   // Global variables to store user information
//   static late String firstname;
//   static late String lastname;
//   static late String email;
//   static late String token;
//
//   // Define methods for API calls
//   static Future<Map<String, dynamic>> resendOTP(String mobile) async {
//     // Implement the logic to make the API call to resend OTP
//     // For example:
//     // final response = await YourApiClass.sendRequest(apiUrl, mobile);
//     // return response;
//     throw UnimplementedError();
//   }
//
//   // Initialize user data on app start
//   static Future<void> initUserData() async {
//     try {
//       final userData = await UserDataStorage.getUserData();
//       firstname = userData['firstname'] ?? '';
//       lastname = userData['lastname'] ?? '';
//       email = userData['email'] ?? '';
//       token = userData['token'] ?? '';
//     } catch (e) {
//       print('Error initializing user data: $e');
//     }
//   }
//
//   // Save user data
//   static Future<void> saveUserData(Map<String, dynamic> userData) async {
//     await UserDataStorage.saveUserData(userData);
//     // Update global variables
//     firstname = userData['firstname'] ?? '';
//     lastname = userData['lastname'] ?? '';
//     email = userData['email'] ?? '';
//     token = userData['token'] ?? '';
//   }
// }
