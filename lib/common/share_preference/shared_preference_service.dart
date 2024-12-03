// import 'package:shared_preferences/shared_preferences.dart';
//
// class UserDataStorage {
//   static const String _isLoggedInKey = 'isLoggedIn';
//   static const String _firstNameKey = 'firstName';
//   static const String _lastNameKey = 'lastName';
//   static const String _emailKey = 'email';
//   static const String _otpKey = 'otp';
//   static const String _tokenKey = 'token';
//   static const String _customerIdKey = 'customerId';
//   static const String _isNewCustomerKey = 'isNewCustomer';
//   static const String _walletIdKey = 'walletId';
//
//   static Future<void> saveUserData(Map<String, dynamic> userData) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_isLoggedInKey, true);
//     await prefs.setString(_firstNameKey, userData['firstname'] ?? '');
//     await prefs.setString(_lastNameKey, userData['lastname'] ?? '');
//     await prefs.setString(_emailKey, userData['email'] ?? '');
//     await prefs.setString(_otpKey, userData['otp']?.toString() ?? '');
//     await prefs.setString(_tokenKey, userData['token'] ?? '');
//     await prefs.setString(_customerIdKey, userData['b2cCustomerId'] ?? '');
//     await prefs.setBool(_isNewCustomerKey, userData['newCustomer'] ?? false);
//     await prefs.setString(_walletIdKey, userData['walletId'] ?? '');
//   }
//
//   static Future<Map<String, dynamic>> getUserData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
//     if (!isLoggedIn) {
//       return {};
//     }
//
//     String firstName = prefs.getString(_firstNameKey) ?? '';
//     String lastName = prefs.getString(_lastNameKey) ?? '';
//     String email = prefs.getString(_emailKey) ?? '';
//     String otp = prefs.getString(_otpKey) ?? '';
//     String token = prefs.getString(_tokenKey) ?? '';
//     String customerId = prefs.getString(_customerIdKey) ?? '';
//     bool isNewCustomer = prefs.getBool(_isNewCustomerKey) ?? false;
//     String walletId = prefs.getString(_walletIdKey) ?? '';
//
//     return {
//       'firstname': firstName,
//       'lastname': lastName,
//       'email': email,
//       'otp': otp.isNotEmpty ? int.parse(otp) : null,
//       'token': token,
//       'b2cCustomerId': customerId,
//       'newCustomer': isNewCustomer,
//       'walletId': walletId,
//     };
//   }
//
//   static Future<void> logout() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_isLoggedInKey, false);
//   }
// }
