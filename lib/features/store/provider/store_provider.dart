// File: store_provider.dart

import 'package:flutter/material.dart';

import '../../../../common/log/loggers.dart';
import '../../../../data/db/app_preferences.dart';
import '../model/store_models.dart';

/// StoreProvider: Single source of truth for store/restaurant data and businessUnitId
/// Manages restaurant selection and provides access to businessUnitId throughout the app
class StoreProvider extends ChangeNotifier {
  static const String TAG = '[StoreProvider]';

  // Core state
  StoreModel? _storeData;
  RestaurantModel? _selectedRestaurant;
  String? _userName;

  // Public getters
  StoreModel? get storeData => _storeData;
  RestaurantModel? get selectedRestaurant => _selectedRestaurant;
  String? get userName => _userName;

  // Primary getter for businessUnitId - Single source of truth
  String? get businessUnitId {
    final id = _selectedRestaurant?.businessUnit.csBunitId;
    AppLogger.logDebug('$TAG: Accessing businessUnitId: $id');
    return id;
  }

  // Complete store details getter
  Map<String, String> get activeStoreDetails {
    AppLogger.logDebug('$TAG: Accessing active store details');
    return {
      'restaurantName': selectedRestaurant?.name ?? '',
      'csBunitId': businessUnitId ?? '',
      'storeId': selectedRestaurant?.storeId ?? '',
    };
  }

  // Constructor - Initialize and load user data
  StoreProvider() {
    AppLogger.logInfo('$TAG: Initializing StoreProvider');
    _loadUserData();
  }

  // Initialize store data
  void initializeStores(StoreModel data) {
    AppLogger.logInfo(
        '$TAG: Initializing store data with ${data.restaurants.length} restaurants');
    _storeData = data;
    notifyListeners();
  }

  // Select restaurant - Primary method for updating businessUnitId
  void selectRestaurant(RestaurantModel restaurant) {
    AppLogger.logInfo('$TAG: Selecting restaurant: ${restaurant.name}');
    AppLogger.logInfo(
        '$TAG: Updating businessUnitId to: ${restaurant.businessUnit.csBunitId}');

    _selectedRestaurant = restaurant;
    notifyListeners();
  }

  // Validate businessUnitId matches current selection
  bool validateBusinessUnit(String? csBunitId) {
    final isValid = businessUnitId == csBunitId;
    AppLogger.logInfo(
        '$TAG: Validating businessUnitId - Current: $businessUnitId, '
        'Checking: $csBunitId, Valid: $isValid');
    return isValid;
  }

  // Clear selections including businessUnitId
  void clearSelections() {
    AppLogger.logInfo('$TAG: Clearing all selections and businessUnitId');
    _selectedRestaurant = null;
    notifyListeners();
  }

  // Private helper methods
  Future<void> _loadUserData() async {
    try {
      AppLogger.logInfo('$TAG: Loading user data');
      final userData = await AppPreference.getUserData();
      _userName = userData['firstName'];
      notifyListeners();
      AppLogger.logInfo('$TAG: User data loaded successfully');
    } catch (e) {
      AppLogger.logError('$TAG: Error loading user data: $e');
    }
  }
}
