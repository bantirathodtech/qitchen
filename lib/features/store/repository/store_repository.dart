// File: repositories/store_repository.dart

import 'package:cw_food_ordering/features/store/model/store_models.dart';

import '../../../../../common/log/loggers.dart';
import '../service/store_service.dart';

/// Repository handling store data operations and caching
class StoreRepository {
  static const String TAG = '[StoreRepository]';

  final StoreService _storeService;

  // Cache for store data
  StoreModel? _cachedStoreData;
  DateTime? _lastFetchTime;

  // Cache duration (5 minutes)
  static const cacheDuration = Duration(minutes: 5);

  StoreRepository({required StoreService storeService})
      : _storeService = storeService {
    AppLogger.logInfo('$TAG: Initializing StoreRepository');
  }

  /// Fetch stores with caching
  Future<StoreModel> getStores({bool forceRefresh = false}) async {
    try {
      AppLogger.logInfo('$TAG: Getting stores (forceRefresh: $forceRefresh)');

      // Check cache if not forcing refresh
      if (!forceRefresh && _isCacheValid) {
        AppLogger.logInfo('$TAG: Returning cached store data');
        return _cachedStoreData!;
      }

      // Fetch fresh data
      AppLogger.logInfo('$TAG: Fetching fresh store data');
      final storeData = await _storeService.fetchStores();

      // Update cache
      _updateCache(storeData);

      AppLogger.logInfo(
        '$TAG: Successfully retrieved ${storeData.restaurants.length} restaurants',
      );

      return storeData;
    } catch (e) {
      _handleError('Failed to get stores', e);
      rethrow;
    }
  }

  /// Get a specific restaurant by ID
  Future<RestaurantModel?> getRestaurantById(String storeId) async {
    try {
      AppLogger.logInfo('$TAG: Finding restaurant with ID: $storeId');

      // Check cache first
      if (_isCacheValid && _cachedStoreData != null) {
        final restaurant = _findRestaurantInCache(storeId);
        if (restaurant != null) {
          AppLogger.logInfo('$TAG: Found restaurant in cache');
          return restaurant;
        }
      }

      // If not in cache, fetch fresh data
      final storeData = await getStores(forceRefresh: true);
      return _findRestaurantInData(storeId, storeData);
    } catch (e) {
      _handleError('Failed to get restaurant', e);
      return null;
    }
  }

  /// Get restaurants filtered by business unit ID
  Future<List<RestaurantModel>> getRestaurantsByBusinessUnit(
    String businessUnitId,
  ) async {
    try {
      AppLogger.logInfo(
        '$TAG: Finding restaurants for business unit: $businessUnitId',
      );

      final storeData = await getStores();

      final restaurants = storeData.restaurants
          .where((restaurant) =>
              restaurant.businessUnit.csBunitId == businessUnitId)
          .toList();

      AppLogger.logInfo(
        '$TAG: Found ${restaurants.length} restaurants for business unit',
      );

      return restaurants;
    } catch (e) {
      _handleError('Failed to get restaurants by business unit', e);
      return [];
    }
  }

  /// Check if store exists and is operational
  Future<bool> isStoreOperational(String storeId) async {
    try {
      AppLogger.logInfo('$TAG: Checking if store is operational: $storeId');

      // First check if store exists
      if (!await _storeService.checkStoreExists(storeId)) {
        AppLogger.logInfo('$TAG: Store $storeId does not exist');
        return false;
      }

      // Get store data
      final restaurant = await getRestaurantById(storeId);
      if (restaurant == null) {
        AppLogger.logInfo('$TAG: Store $storeId data not found');
        return false;
      }

      // Check if store has valid business unit
      if (restaurant.businessUnit.csBunitId.isEmpty) {
        AppLogger.logInfo('$TAG: Store $storeId has no valid business unit');
        return false;
      }

      // Check if store has timing information
      if (restaurant.timings.isEmpty) {
        AppLogger.logInfo('$TAG: Store $storeId has no timing information');
        return false;
      }

      AppLogger.logInfo('$TAG: Store $storeId is operational');
      return true;
    } catch (e) {
      _handleError('Failed to check store operational status', e);
      return false;
    }
  }

  /// Clear the cache
  void clearCache() {
    AppLogger.logInfo('$TAG: Clearing cache');
    _cachedStoreData = null;
    _lastFetchTime = null;
  }

  // Private helper methods
  bool get _isCacheValid {
    if (_cachedStoreData == null || _lastFetchTime == null) return false;

    final cacheAge = DateTime.now().difference(_lastFetchTime!);
    return cacheAge < cacheDuration;
  }

  void _updateCache(StoreModel storeData) {
    AppLogger.logInfo('$TAG: Updating cache');
    _cachedStoreData = storeData;
    _lastFetchTime = DateTime.now();
  }

  RestaurantModel? _findRestaurantInCache(String storeId) {
    return _cachedStoreData?.restaurants.firstWhere(
      (r) => r.storeId == storeId,
      orElse: () => throw StoreNotFoundException(storeId),
    );
  }

  RestaurantModel? _findRestaurantInData(
    String storeId,
    StoreModel storeData,
  ) {
    try {
      final restaurant = storeData.restaurants.firstWhere(
        (r) => r.storeId == storeId,
      );
      AppLogger.logInfo('$TAG: Found restaurant: ${restaurant.name}');
      return restaurant;
    } catch (e) {
      AppLogger.logWarning('$TAG: Restaurant not found: $storeId');
      return null;
    }
  }

  void _handleError(String context, Object error) {
    final message = '$context: $error';
    AppLogger.logError('$TAG: $message');

    if (error is StoreServiceException) {
      throw StoreRepositoryException(message, error);
    } else {
      throw StoreRepositoryException(message);
    }
  }
}

/// Custom exceptions
class StoreRepositoryException implements Exception {
  final String message;
  final Exception? cause;

  StoreRepositoryException(this.message, [this.cause]);

  @override
  String toString() => cause != null ? '$message (Caused by: $cause)' : message;
}

class StoreNotFoundException implements Exception {
  final String storeId;

  StoreNotFoundException(this.storeId);

  @override
  String toString() => 'Store not found: $storeId';
}
