// File: viewmodels/home_viewmodel.dart

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../common/log/loggers.dart';
import '../../products/viewmodel/product_viewmodel.dart';
import '../cache/store_cache.dart';
import '../model/store_models.dart';
import '../provider/store_provider.dart';
import '../service/store_service.dart';

/// ViewModel for managing home screen state and business logic
class HomeViewModel extends ChangeNotifier {
  static const String TAG = '[HomeViewModel]';

  // Dependencies
  final StoreService _storeService;
  final StoreProvider _storeProvider;

  // Local state
  bool _isLoading = false;
  String _error = '';

  // Public getters
  bool get isLoading => _isLoading;
  String get error => _error;
  StoreModel? get storeData => _storeProvider.storeData;
  RestaurantModel? get selectedRestaurant => _storeProvider.selectedRestaurant;

  HomeViewModel({
    required StoreService storeService,
    required StoreProvider storeProvider,
  })  : _storeService = storeService,
        _storeProvider = storeProvider {
    AppLogger.logInfo('$TAG: Initializing HomeViewModel');
  }

  /// Clear error state (new method)
  void clearError() {
    if (_error.isNotEmpty) {
      _error = '';
      notifyListeners();
    }
  }

  /// Fetch all store data from the service with caching
  Future<void> fetchStores({bool forceRefresh = false}) async {
    try {
      AppLogger.logInfo('$TAG: Starting store data fetch (force: $forceRefresh)');
      _setLoading(true);
      _clearError();

      // Check if we can use cached data when not forcing refresh
      if (!forceRefresh) {
        final cachedData = await StoreCache.getStoreData();
        if (cachedData != null) {
          AppLogger.logInfo('$TAG: Using cached store data');
          _storeProvider.initializeStores(cachedData);
          _setLoading(false);
          return;
        }
      }

      // Fetch fresh store data from API
      final storeData = await _storeService.fetchStores();
      AppLogger.logInfo('$TAG: Fetched ${storeData.restaurants.length} restaurants');

      // Cache the newly fetched data
      await StoreCache.saveStoreData(storeData);
      AppLogger.logInfo('$TAG: Store data cached for future use');

      // Update store provider
      _storeProvider.initializeStores(storeData);

      AppLogger.logInfo('$TAG: Successfully loaded store data');
    } catch (e) {
      _handleError('Failed to fetch stores', e);
    } finally {
      _setLoading(false);
    }
  }

  // Add this method to HomeViewModel class (already exists in your shared code)
  void setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  // Add to HomeViewModel
  List<RestaurantModel> searchRestaurants(String query) {
    if (storeData == null) return [];

    final searchQuery = query.toLowerCase();
    return storeData!.restaurants.where((restaurant) {
      final name = restaurant.name.toLowerCase();
      final description = restaurant.shortDescription?.toLowerCase() ?? '';
      return name.contains(searchQuery) || description.contains(searchQuery);
    }).toList();
  }

  /// Select a restaurant and update provider
  void selectRestaurant(RestaurantModel restaurant) {
    try {
      AppLogger.logInfo('$TAG: Selecting restaurant: ${restaurant.name}');
      AppLogger.logDebug(
        '$TAG: Restaurant ID: ${restaurant.storeId}, '
        'Business Unit: ${restaurant.businessUnit.csBunitId}',
      );

      _storeProvider.selectRestaurant(restaurant);
    } catch (e) {
      _handleError('Failed to select restaurant', e);
    }
  }

  /// Check if a restaurant is currently open
  bool isRestaurantOpen(RestaurantModel restaurant) {
    try {
      final currentDay = _getCurrentDay();
      final currentTime = DateTime.now();

      // Check for holiday
      if (_isHoliday(restaurant, currentTime)) {
        AppLogger.logInfo(
          '$TAG: Restaurant ${restaurant.name} is closed for holiday',
        );
        return false;
      }

      // Check timing for current day
      final isOpen = restaurant.timings.any((timing) {
        if (!timing.isDayOpen(currentDay)) return false;

        final openTime = _parseTime(timing.startTime);
        final closeTime = _parseTime(timing.endTime);
        final now = _parseTime(
          '${currentTime.hour}:${currentTime.minute}:00',
        );

        return now.isAfter(openTime) && now.isBefore(closeTime);
      });

      AppLogger.logInfo(
        '$TAG: Restaurant ${restaurant.name} is ${isOpen ? 'open' : 'closed'}',
      );
      return isOpen;
    } catch (e) {
      _handleError('Error checking restaurant status', e);
      return false;
    }
  }

  /// Get restaurant status information
  Map<String, dynamic> getRestaurantStatus(RestaurantModel restaurant) {
    try {
      final isOpen = isRestaurantOpen(restaurant);
      final timing = _getDisplayTiming(restaurant);

      return {
        'isOpen': isOpen,
        'statusText': isOpen ? 'Open' : 'Closed',
        'displayTiming': timing,
      };
    } catch (e) {
      _handleError('Error getting restaurant status', e);
      return {
        'isOpen': false,
        'statusText': 'Status unavailable',
        'displayTiming': 'Timing unavailable',
      };
    }
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = '';
    notifyListeners();
  }

  void _handleError(String context, Object error) {
    final message = '$context: $error';
    AppLogger.logError('$TAG: $message');
    _error = message;
    notifyListeners();
  }

  String _getCurrentDay() {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    return days[DateTime.now().weekday - 1];
  }

  bool _isHoliday(RestaurantModel restaurant, DateTime date) {
    return restaurant.holidays.any((holiday) {
      final holidayDate = DateTime.parse(holiday.holidayDate);
      return date.year == holidayDate.year &&
          date.month == holidayDate.month &&
          date.day == holidayDate.day;
    });
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  // String _getDisplayTiming(RestaurantModel restaurant) {
  //   final currentDay = _getCurrentDay();
  //   final timing = restaurant.timings.firstWhere(
  //     (t) => t.isDayOpen(currentDay),
  //     orElse: () => restaurant.timings.first,
  //   );
  //
  //   return '${_formatTime(timing.startTime)} - ${_formatTime(timing.endTime)}';
  // }

  String _getDisplayTiming(RestaurantModel restaurant) {
    try {
      final currentDay = _getCurrentDay();

      // Try to find timing for current day
      final timing = restaurant.timings.firstWhere(
        (t) => t.isDayOpen(currentDay),
        orElse: () {
          // If no timing found for current day, return first timing or default message
          return restaurant.timings.isNotEmpty
              ? restaurant.timings.first
              : TimingModel(
                  startTime: "09:00:00",
                  endTime: "22:00:00",
                  days: {
                    'monday': true,
                    'tuesday': true,
                    'wednesday': true,
                    'thursday': true,
                    'friday': true,
                    'saturday': true,
                    'sunday': true,
                  },
                );
        },
      );

      return '${_formatTime(timing.startTime)} - ${_formatTime(timing.endTime)}';
    } catch (e) {
      AppLogger.logWarning('$TAG: Error getting display timing: $e');
      return 'Hours not available';
    }
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour;
    return '$displayHour:$minute $period';
  }

  // Add this method to your HomeViewModel
  // Future<void> preloadProductsForAllRestaurants(BuildContext context) async {
  //   if (storeData == null || storeData!.restaurants.isEmpty) return;
  //
  //   AppLogger.logInfo('$TAG: Starting background preload of products for all restaurants');
  //
  //   // Get ProductViewModel
  //   final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
  //
  //   // Create a queue of restaurants to process
  //   final List<RestaurantModel> restaurantsToProcess = [...storeData!.restaurants];
  //
  //   // Process restaurants one by one to avoid overwhelming the network
  //   for (final restaurant in restaurantsToProcess) {
  //     try {
  //       AppLogger.logInfo('$TAG: Preloading products for restaurant: ${restaurant.name}');
  //       await productViewModel.fetchProducts(restaurant.storeId, forceRefresh: false);
  //       AppLogger.logInfo('$TAG: Successfully preloaded products for: ${restaurant.name}');
  //     } catch (e) {
  //       // Log error but continue with next restaurant
  //       AppLogger.logError('$TAG: Error preloading products for ${restaurant.name}: $e');
  //     }
  //
  //     // Small delay to avoid overwhelming the network
  //     await Future.delayed(const Duration(milliseconds: 300));
  //   }
  //
  //   AppLogger.logInfo('$TAG: Completed background preloading of products');
  // }
}
