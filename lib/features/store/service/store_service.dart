// File: services/store_service.dart

import 'package:cw_food_ordering/features/store/model/store_models.dart';

import '../../../../../common/log/loggers.dart';
import '../../../../core/api/api_base_service.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_url_manager.dart';

/// Service responsible for handling all store-related API calls
class StoreService {
  static const String TAG = '[StoreService]';
  final ApiBaseService _apiBaseService;

  StoreService({required ApiBaseService apiBaseService})
      : _apiBaseService = apiBaseService;

  /// Fetch all store data from the API
  Future<StoreModel> fetchStores() async {
    try {
      AppLogger.logInfo('$TAG: Initiating store data fetch');
      AppLogger.logDebug('$TAG: Using config ID: ${ApiConstants.CONFIG_ID}');

      // Make API call
      final response = await _apiBaseService.sendRestRequest(
        endpoint: AppUrls.getStore,
        method: 'GET',
        queryParams: {'config_id': ApiConstants.CONFIG_ID},
      );
      AppLogger.logInfo('$TAG: Received API response');

      // Validate response
      if (!_isValidResponse(response)) {
        throw StoreServiceException('Invalid response format from API');
      }

      // Parse response
      final storeData = _parseResponse(response);

      // Validate store data
      _validateStoreData(storeData);

      AppLogger.logInfo(
        '$TAG: Successfully fetched ${storeData.restaurants.length} restaurants',
      );

      return storeData;
    } catch (e) {
      _handleError('Failed to fetch stores', e);
      rethrow;
    }
  }

  /// Check if a specific store exists by ID
  Future<bool> checkStoreExists(String storeId) async {
    try {
      AppLogger.logInfo('$TAG: Checking existence of store: $storeId');

      final response = await _apiBaseService.sendRestRequest(
        endpoint: '${AppUrls.getStore}/$storeId',
        method: 'GET',
        queryParams: {'config_id': ApiConstants.CONFIG_ID},
      );

      final exists = response != null && response['data'] != null;
      AppLogger.logInfo('$TAG: Store $storeId exists: $exists');

      return exists;
    } catch (e) {
      AppLogger.logError('$TAG: Error checking store existence: $e');
      return false;
    }
  }

  // Private helper methods
  bool _isValidResponse(dynamic response) {
    if (response == null) {
      AppLogger.logError('$TAG: Null response received');
      return false;
    }

    if (response['data'] == null) {
      AppLogger.logError('$TAG: Response missing data field');
      return false;
    }

    if (response['data']['getStores'] == null) {
      AppLogger.logError('$TAG: Response missing getStores field');
      return false;
    }

    AppLogger.logDebug('$TAG: Response validation successful');
    return true;
  }

  StoreModel _parseResponse(Map<String, dynamic> response) {
    try {
      AppLogger.logInfo('$TAG: Parsing API response');

      final storeModel = StoreModel.fromJson(response['data']['getStores']);

      AppLogger.logDebug(
        '$TAG: Parsed store data:'
        '\n- Name: ${storeModel.name}'
        '\n- Restaurants: ${storeModel.restaurants.length}'
        '\n- Has Banner: ${storeModel.promotionBanner.isNotEmpty}',
      );

      return storeModel;
    } catch (e) {
      throw StoreServiceException('Error parsing response: $e');
    }
  }

  void _validateStoreData(StoreModel storeData) {
    AppLogger.logInfo('$TAG: Validating store data');

    // Validate basic store data
    if (storeData.name.isEmpty) {
      AppLogger.logWarning('$TAG: Store name is empty');
    }

    // Validate restaurants
    if (storeData.restaurants.isEmpty) {
      AppLogger.logWarning('$TAG: No restaurants found in store data');
    }

    // Validate restaurant data
    for (final restaurant in storeData.restaurants) {
      _validateRestaurantData(restaurant);
    }

    AppLogger.logInfo('$TAG: Store data validation complete');
  }

  void _validateRestaurantData(RestaurantModel restaurant) {
    final List<String> warnings = [];

    if (restaurant.name.isEmpty) {
      warnings.add('Restaurant name is empty');
    }

    if (restaurant.storeId.isEmpty) {
      warnings.add('Store ID is empty');
    }

    if (restaurant.businessUnit.csBunitId.isEmpty) {
      warnings.add('Business unit ID is empty');
    }

    if (restaurant.timings.isEmpty) {
      warnings.add('No timing information available');
    }

    if (warnings.isNotEmpty) {
      AppLogger.logWarning(
        '$TAG: Validation warnings for restaurant ${restaurant.name}:'
        '\n- ${warnings.join("\n- ")}',
      );
    }
  }

  void _handleError(String context, Object error) {
    final message = '$context: $error';
    AppLogger.logError('$TAG: $message');
    throw StoreServiceException(message);
  }
}

/// Custom exception for store service errors
class StoreServiceException implements Exception {
  final String message;

  StoreServiceException(this.message);

  @override
  String toString() => message;
}

/// Extension for service response validation
extension ResponseValidation on Map<String, dynamic> {
  bool get hasValidData =>
      this['data'] != null && this['data']['getStores'] != null;

  bool get hasStores =>
      hasValidData &&
      (this['data']['getStores']['storeConfig'] as List?)?.isNotEmpty == true;
}
