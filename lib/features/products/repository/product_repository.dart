import '../../../../common/log/loggers.dart';
import '../../../../core/api/api_constants.dart';
import '../ache/product_cache.dart';
import '../model/product_model.dart';
import '../service/product_service_redis.dart';

/// Repository handling product data operations and caching
class ProductRepository {
  static const String TAG = '[ProductRepository]';

  final ProductService _productService;

  // In-memory cache for product data
  final Map<String, List<ProductModel>> _cache = {};
  final Map<String, DateTime> _lastFetchTime = {};

  ProductRepository({required ProductService productService})
      : _productService = productService {
    AppLogger.logInfo('$TAG: Initializing ProductRepository');
  }

  // Fetch products with multi-level caching logic
  Future<List<ProductModel>> getProducts(String storeId, {bool forceRefresh = false}) async {
    try {
      AppLogger.logInfo('$TAG: Getting products for store: $storeId (forceRefresh: $forceRefresh)');

      // Step 1: Check in-memory cache first (fastest)
      if (!forceRefresh && _isCacheValid(storeId)) {
        AppLogger.logInfo('$TAG: Returning in-memory cached product data');
        return _cache[storeId]!;
      }

      // Step 2: Check disk cache if in-memory cache is not valid
      if (!forceRefresh) {
        final cachedProducts = await ProductCache.getProductsData(storeId);
        if (cachedProducts != null) {
          AppLogger.logInfo('$TAG: Returning disk cached product data');
          // Update in-memory cache
          _updateCache(storeId, cachedProducts);
          return cachedProducts;
        }
      }

      // Step 3: Fetch fresh data from service
      AppLogger.logInfo('$TAG: Fetching fresh product data from service');
      final products = await _productService.fetchProducts(storeId);

      // Step 4: Update both caches with new data
      _updateCache(storeId, products);
      await ProductCache.saveProductsData(storeId, products);

      AppLogger.logInfo('$TAG: Successfully retrieved ${products.length} products');
      return products;
    } catch (e) {
      _handleError('Failed to get products', e);
      rethrow;
    }
  }

  // Get products filtered by category
  Future<List<ProductModel>> getProductsByCategory(String storeId, String categoryId) async {
    try {
      final products = await getProducts(storeId);
      return products.where((p) => p.categoryId == categoryId).toList();
    } catch (e) {
      _handleError('Failed to get products by category', e);
      return [];
    }
  }

  // Clear both in-memory and disk cache
  void clearCache([String? storeId]) {
    AppLogger.logInfo('$TAG: Clearing cache ${storeId ?? 'all'}');
    if (storeId != null) {
      _cache.remove(storeId);
      _lastFetchTime.remove(storeId);
      ProductCache.clearCache(storeId); // Clear disk cache for this store
    } else {
      _cache.clear();
      _lastFetchTime.clear();
      ProductCache.clearCache(); // Clear all disk caches
    }
  }

  // Helper method to check in-memory cache validity
  bool _isCacheValid(String storeId) {
    final lastFetch = _lastFetchTime[storeId];
    if (lastFetch == null || !_cache.containsKey(storeId)) return false;
    final cacheAge = DateTime.now().difference(lastFetch);
    return cacheAge < ApiConstants.CACHE_DURATION;
  }

  // Helper method to update in-memory cache
  void _updateCache(String storeId, List<ProductModel> products) {
    AppLogger.logInfo('$TAG: Updating in-memory cache for store: $storeId');
    _cache[storeId] = products;
    _lastFetchTime[storeId] = DateTime.now();
  }

  // Helper method to handle errors
  void _handleError(String context, Object error) {
    final message = '$context: $error';
    AppLogger.logError('$TAG: $message');
    if (error is ProductServiceException) {
      throw ProductRepositoryException(message, error);
    } else {
      throw ProductRepositoryException(message);
    }
  }
}

/// Custom exceptions
class ProductRepositoryException implements Exception {
  final String message;
  final Exception? cause;

  ProductRepositoryException(this.message, [this.cause]);

  @override
  String toString() => cause != null ? '$message (Caused by: $cause)' : message;
}

// // product_repository.dart
//
// import '../../../../common/log/loggers.dart';
// import '../../../../core/api/api_constants.dart';
// import '../model/product_model.dart';
// import '../service/product_service_redis.dart';
//
// /// Repository handling product data operations and caching
// class ProductRepository {
//   static const String TAG = '[ProductRepository]';
//
//   final ProductService _productService;
//
// // Cache for product data
//   final Map<String, List<ProductModel>> _cache = {};
//   final Map<String, DateTime> _lastFetchTime = {};
//
//   ProductRepository({required ProductService productService})
//       : _productService = productService {
//     AppLogger.logInfo('$TAG: Initializing ProductRepository');
//   }
//
//   /// Fetch products with caching
//   Future<List<ProductModel>> getProducts(String storeId,
//       {bool forceRefresh = false}) async {
//     try {
//       AppLogger.logInfo(
//           '$TAG: Getting products for store: $storeId (forceRefresh: $forceRefresh)');
//
// // Check cache if not forcing refresh
//       if (!forceRefresh && _isCacheValid(storeId)) {
//         AppLogger.logInfo('$TAG: Returning cached product data');
//         return _cache[storeId]!;
//       }
//
// // Fetch fresh data
//       AppLogger.logInfo('$TAG: Fetching fresh product data');
//       final products = await _productService.fetchProducts(storeId);
//
// // Update cache
//       _updateCache(storeId, products);
//
//       AppLogger.logInfo(
//         '$TAG: Successfully retrieved ${products.length} products',
//       );
//
//       return products;
//     } catch (e) {
//       _handleError('Failed to get products', e);
//       rethrow;
//     }
//   }
//
//   /// Get products by category
//   Future<List<ProductModel>> getProductsByCategory(
//       String storeId, String categoryId) async {
//     try {
//       final products = await getProducts(storeId);
//       return products.where((p) => p.categoryId == categoryId).toList();
//     } catch (e) {
//       _handleError('Failed to get products by category', e);
//       return [];
//     }
//   }
//
//   /// Clear the cache
//   void clearCache([String? storeId]) {
//     AppLogger.logInfo('$TAG: Clearing cache ${storeId ?? 'all'}');
//     if (storeId != null) {
//       _cache.remove(storeId);
//       _lastFetchTime.remove(storeId);
//     } else {
//       _cache.clear();
//       _lastFetchTime.clear();
//     }
//   }
//
// // Private helper methods
//   bool _isCacheValid(String storeId) {
//     final lastFetch = _lastFetchTime[storeId];
//     if (lastFetch == null || !_cache.containsKey(storeId)) return false;
//
//     final cacheAge = DateTime.now().difference(lastFetch);
//     return cacheAge < ApiConstants.CACHE_DURATION;
//   }
//
//   void _updateCache(String storeId, List<ProductModel> products) {
//     AppLogger.logInfo('$TAG: Updating cache for store: $storeId');
//     _cache[storeId] = products;
//     _lastFetchTime[storeId] = DateTime.now();
//   }
//
//   void _handleError(String context, Object error) {
//     final message = '$context: $error';
//     AppLogger.logError('$TAG: $message');
//
//     if (error is ProductServiceException) {
//       throw ProductRepositoryException(message, error);
//     } else {
//       throw ProductRepositoryException(message);
//     }
//   }
// }
//
// /// Custom exceptions
// class ProductRepositoryException implements Exception {
//   final String message;
//   final Exception? cause;
//
//   ProductRepositoryException(this.message, [this.cause]);
//
//   @override
//   String toString() => cause != null ? '$message (Caused by: $cause)' : message;
// }
