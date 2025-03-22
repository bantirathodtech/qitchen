// File: common/cache/store_cache.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/log/loggers.dart';
import '../../../features/store/model/store_models.dart';

/// Dedicated class for caching store data
class StoreCache {
  static const String TAG = '[StoreCache]';
  static const String STORE_DATA_KEY = 'cached_store_data';
  static const String CACHE_TIMESTAMP_KEY = 'store_cache_timestamp';

  /// Save store data to cache
  static Future<bool> saveStoreData(StoreModel storeData) async {
    try {
      AppLogger.logInfo('$TAG: Saving store data to cache');
      final prefs = await SharedPreferences.getInstance();

      // Convert store data to JSON
      final jsonData = json.encode(storeData.toJson());

      // Save data and timestamp
      await prefs.setString(STORE_DATA_KEY, jsonData);
      await prefs.setInt(CACHE_TIMESTAMP_KEY, DateTime.now().millisecondsSinceEpoch);

      AppLogger.logInfo('$TAG: Store data cached successfully');
      return true;
    } catch (e) {
      AppLogger.logError('$TAG: Error caching store data: $e');
      return false;
    }
  }

  /// Get cached store data if available and not expired
  static Future<StoreModel?> getStoreData() async {
    try {
      AppLogger.logInfo('$TAG: Attempting to get cached store data');
      final prefs = await SharedPreferences.getInstance();

      // Check if cache exists
      if (!prefs.containsKey(STORE_DATA_KEY)) {
        AppLogger.logInfo('$TAG: No cached store data found');
        return null;
      }

      // Check if cache is expired (24 hours)
      final timestamp = prefs.getInt(CACHE_TIMESTAMP_KEY) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheDuration = now - timestamp;

      // // Cache expiration: 24 hours (24 * 60 * 60 * 1000 ms)
      // if (cacheDuration > 86400000) {
      //   AppLogger.logInfo('$TAG: Cached store data is expired');
      //   return null;
      // }

      // Cache expiration: 1 hours (1 * 60 * 60 * 1000 ms)
      if (cacheDuration > 3600000) {
        AppLogger.logInfo('$TAG: Cached store data is expired');
        return null;
      }

      // Retrieve and parse cached data
      final jsonData = prefs.getString(STORE_DATA_KEY);
      if (jsonData == null) return null;

      final storeData = StoreModel.fromJson(json.decode(jsonData));
      AppLogger.logInfo('$TAG: Successfully retrieved cached store data');
      return storeData;
    } catch (e) {
      AppLogger.logError('$TAG: Error retrieving cached store data: $e');
      return null;
    }
  }

  /// Clear store data cache
  static Future<void> clearCache() async {
    try {
      AppLogger.logInfo('$TAG: Clearing store data cache');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(STORE_DATA_KEY);
      await prefs.remove(CACHE_TIMESTAMP_KEY);
      AppLogger.logInfo('$TAG: Store data cache cleared');
    } catch (e) {
      AppLogger.logError('$TAG: Error clearing store data cache: $e');
    }
  }
}