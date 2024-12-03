import 'package:shared_preferences/shared_preferences.dart';

class OfflineDataCache {
  static const String cartDataKey = 'cartData';

  static Future<void> saveCartData(String cartData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cartDataKey, cartData);
    } catch (e) {
      // Handle error
    }
  }

  static Future<String?> getCartData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(cartDataKey);
    } catch (e) {
      // Handle error
      return null;
    }
  }

  static Future<void> clearCartData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(cartDataKey);
    } catch (e) {
      // Handle error
    }
  }
}
