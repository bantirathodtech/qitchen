import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/log/loggers.dart';

class AppPreference {
  static const String customerDataKey = 'customerData';
  static const String phoneNumberKey = 'phoneNumber';
  static const String isLoggedInKey = 'isLoggedIn';
  static const String cartDataKey = 'cartData'; // Added for Cart Data
  static const String walletIdKey = 'walletId';

  // Save cart data
  static Future<void> saveCartData(String cartData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cartDataKey, cartData);
      AppLogger.logInfo('Cart data saved successfully');
    } catch (e) {
      AppLogger.logError('Error saving cart data: $e');
    }
  }

  // Get cart data
  static Future<String?> getCartData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(cartDataKey);
    } catch (e) {
      AppLogger.logError('Error getting cart data: $e');
    }
    return null;
  }

  // Clear cart data
  static Future<void> clearCartData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(cartDataKey);
      AppLogger.logInfo('Cart data cleared');
    } catch (e) {
      AppLogger.logError('Error clearing cart data: $e');
    }
  }

  // Save complete user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(customerDataKey, json.encode(userData));
      await prefs.setString(phoneNumberKey, userData['phone'] ?? '');
      await prefs.setBool(isLoggedInKey, true);
      AppLogger.logInfo('User data saved successfully');
      // Log the saved data for debugging
      AppLogger.logInfo('Saved User Data Printing: ${json.encode(userData)}');
      AppLogger.logInfo(
          'Saved Phone Number Printing: ${userData['phone'] ?? ''}');
    } catch (e) {
      AppLogger.logError('Error saving user data: $e');
    }
  }

  // Get user data
  static Future<Map<String, dynamic>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerDataString = prefs.getString(customerDataKey);
      if (customerDataString != null) {
        final userData = json.decode(customerDataString);
        userData['phone'] = prefs.getString(phoneNumberKey);
        return userData;
      }
    } catch (e) {
      AppLogger.logError('Error getting user data: $e');
    }
    return {};
  }

  // Clear user data
  static Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(customerDataKey);
      await prefs.remove(phoneNumberKey);
      await prefs.setBool(isLoggedInKey, false);
      AppLogger.logInfo('User data cleared');
    } catch (e) {
      AppLogger.logError('Error clearing user data: $e');
    }
  }

  static Future<void> saveWalletId(String walletId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(walletIdKey, walletId);
      AppLogger.logInfo('Wallet ID saved successfully');
    } catch (e) {
      AppLogger.logError('Error saving wallet ID: $e');
    }
  }

  static Future<String?> getWalletId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(walletIdKey);
    } catch (e) {
      AppLogger.logError('Error getting wallet ID: $e');
    }
    return null;
  }
}
