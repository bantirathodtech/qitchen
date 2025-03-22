// File: common/cache/product_cache.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/log/loggers.dart';
import '../model/product_model.dart';

/// Dedicated class for caching product data
class ProductCache {
  static const String TAG = '[ProductCache]';
  static const String PRODUCT_DATA_PREFIX = 'cached_products_';
  static const String CACHE_TIMESTAMP_PREFIX = 'products_cache_timestamp_';
  static const int CACHE_DURATION_MS = 600000; // 10 min in milliseconds

  /// Save products data to cache for a specific store
  static Future<bool> saveProductsData(String storeId, List<ProductModel> products) async {
    try {
      AppLogger.logInfo('$TAG: Saving products data to cache for store: $storeId');
      final prefs = await SharedPreferences.getInstance();

      // Create a list of product JSON objects
      final productsList = products.map((product) => product.toJson()).toList();

      // Convert to JSON string
      final jsonData = json.encode(productsList);

      // Save data and timestamp using store-specific keys
      await prefs.setString('$PRODUCT_DATA_PREFIX$storeId', jsonData);
      await prefs.setInt('$CACHE_TIMESTAMP_PREFIX$storeId', DateTime.now().millisecondsSinceEpoch);

      AppLogger.logInfo('$TAG: Products data cached successfully for store: $storeId');
      return true;
    } catch (e) {
      AppLogger.logError('$TAG: Error caching products data: $e');
      return false;
    }
  }

  /// Get cached products data if available and not expired
  static Future<List<ProductModel>?> getProductsData(String storeId) async {
    try {
      AppLogger.logInfo('$TAG: Attempting to get cached products data for store: $storeId');
      final prefs = await SharedPreferences.getInstance();

      // Check if cache exists
      final cacheKey = '$PRODUCT_DATA_PREFIX$storeId';
      if (!prefs.containsKey(cacheKey)) {
        AppLogger.logInfo('$TAG: No cached products data found for store: $storeId');
        return null;
      }

      // Check if cache is expired (1 hour)
      final timestamp = prefs.getInt('$CACHE_TIMESTAMP_PREFIX$storeId') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheDuration = now - timestamp;

      if (cacheDuration > CACHE_DURATION_MS) {
        AppLogger.logInfo('$TAG: Cached products data is expired for store: $storeId');
        return null;
      }

      // Retrieve and parse cached data
      final jsonData = prefs.getString(cacheKey);
      if (jsonData == null) return null;

      final productsList = (json.decode(jsonData) as List)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();

      AppLogger.logInfo('$TAG: Successfully retrieved ${productsList.length} cached products for store: $storeId');
      return productsList;
    } catch (e) {
      AppLogger.logError('$TAG: Error retrieving cached products data: $e');
      return null;
    }
  }

  /// Clear products data cache for a specific store or all stores
  static Future<void> clearCache([String? storeId]) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (storeId != null) {
        // Clear cache for specific store
        AppLogger.logInfo('$TAG: Clearing products cache for store: $storeId');
        await prefs.remove('$PRODUCT_DATA_PREFIX$storeId');
        await prefs.remove('$CACHE_TIMESTAMP_PREFIX$storeId');
      } else {
        // Clear all product caches
        AppLogger.logInfo('$TAG: Clearing all products caches');
        final keys = prefs.getKeys();
        for (final key in keys) {
          if (key.startsWith(PRODUCT_DATA_PREFIX) || key.startsWith(CACHE_TIMESTAMP_PREFIX)) {
            await prefs.remove(key);
          }
        }
      }
      AppLogger.logInfo('$TAG: Products cache cleared ${storeId != null ? 'for store: $storeId' : 'for all stores'}');
    } catch (e) {
      AppLogger.logError('$TAG: Error clearing products cache: $e');
    }
  }
}