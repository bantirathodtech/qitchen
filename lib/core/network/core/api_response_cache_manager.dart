import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ApiResponseCacheManager {
  static const String _cachePrefix = 'api_cache_';
  static const Duration _cacheDuration =
      Duration(hours: 1); // Cache duration: 1 hour

  // Method to save the API response in cache
  static Future<void> saveResponseToCache(
      String endpoint, dynamic response) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _getCacheKey(endpoint);
    final cacheData = json.encode({
      'timestamp': DateTime.now().toIso8601String(),
      'response': response,
    });
    await prefs.setString(cacheKey, cacheData);
  }

  // Method to retrieve the cached response
  static Future<dynamic> getResponseFromCache(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _getCacheKey(endpoint);
    final cachedData = prefs.getString(cacheKey);

    if (cachedData != null) {
      final Map<String, dynamic> cacheMap = json.decode(cachedData);
      final DateTime timestamp = DateTime.parse(cacheMap['timestamp']);

      // Check if the cached data is still valid (within the defined cache duration)
      if (DateTime.now().difference(timestamp) < _cacheDuration) {
        return cacheMap['response'];
      } else {
        // Cache expired
        await prefs.remove(cacheKey);
      }
    }

    return null; // No valid cached data
  }

  // Method to check if the cache is available and not expired
  static Future<bool> isCacheValid(String endpoint) async {
    final response = await getResponseFromCache(endpoint);
    return response != null;
  }

  // Helper method to generate cache key based on the API endpoint
  static String _getCacheKey(String endpoint) {
    return _cachePrefix + endpoint.hashCode.toString();
  }

  // Clear all cached responses
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
    for (var key in keys) {
      await prefs.remove(key);
    }
  }

  // Clear a specific endpoint's cache
  static Future<void> clearCacheForEndpoint(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _getCacheKey(endpoint);
    await prefs.remove(cacheKey);
  }
}
