// lib/common/cache/app_prefetch_manager.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/log/loggers.dart';
import '../../features/history/order_history/viewmodel/order_history_viewmodel.dart';
import '../../features/history/wallet_history/viewmodel/wallet_history_viewmodel.dart';
import '../../features/ordering/wallet/viewmodel/wallet_viewmodel.dart';
import '../../features/products/viewmodel/product_viewmodel.dart';
import '../../features/store/provider/store_provider.dart';
import '../../features/store/viewmodel/home_viewmodel.dart';
import '../db/app_preferences.dart';

/// Manages prefetching of application data to improve performance
/// Loads essential data in the background during app startup
class AppPrefetchManager {
  static const String TAG = '[AppPrefetchManager]';

  /// Prefetch essential app data in the background
  /// Call this from main screen initialization or splash screen
  static Future<void> prefetchAppData(BuildContext context) async {
    AppLogger.logInfo('$TAG Starting background prefetch of app data');

    // Use a delayed execution to avoid blocking the UI thread during app startup
    Future.delayed(const Duration(milliseconds: 100), () {
      _prefetchAll(context);
    });
  }

  /// Prefetch all data types in parallel after store data is loaded
  static Future<void> _prefetchAll(BuildContext context) async {
    try {
      // Step 1: Prefetch store data first as it's a dependency for product data
      // Prefetch store data first (highest priority)
      await _prefetchStoreData(context);

      // Start other prefetches in parallel to speed up loading
      await Future.wait([
        // Then prefetch products for the selected store (if any)
       // _prefetchProductData(context),
        _prefetchProductsForAllRestaurants(context),
        // Prefetch user-specific data
       _prefetchOrderHistory(context),
       _prefetchWalletHistory(context),
        _prefetchWalletBalance(context), // Added wallet balance prefetch

      ], eagerError: false); // Continue even if one fails


      AppLogger.logInfo('$TAG Completed background prefetch of app data');
    } catch (e) {
      // Log errors but don't interrupt the app startup flow
      AppLogger.logError('$TAG Error during background prefetch: $e');
    }
  }

  /// Prefetch products for multiple restaurants
  static Future<void> _prefetchProductsForAllRestaurants(BuildContext context) async {
    try {
      // Get store provider
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);

      // Skip if store data isn't loaded yet
      if (storeProvider.storeData == null || storeProvider.storeData!.restaurants.isEmpty) {
        AppLogger.logInfo('$TAG No restaurant data available for product prefetch');
        return;
      }

      // Get product view model
      final productViewModel = Provider.of<ProductViewModel>(context, listen: false);

      // Get list of restaurant store IDs - limit to first 6 restaurants to avoid overloading
      final restaurants = storeProvider.storeData!.restaurants.take(6).toList();
      AppLogger.logInfo('$TAG Starting product prefetch for ${restaurants.length} restaurants');

      // Prefetch products for each restaurant sequentially (to avoid overwhelming the network)
      for (final restaurant in restaurants) {
        if (restaurant.storeId.isEmpty) continue;

        try {
          AppLogger.logInfo('$TAG Prefetching products for: ${restaurant.name} (${restaurant.storeId})');
          await productViewModel.fetchProducts(restaurant.storeId, forceRefresh: false);
          AppLogger.logInfo('$TAG Successfully prefetched products for: ${restaurant.name}');

          // Add a small delay between requests to avoid overwhelming the API
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (e) {
          // Log error but continue with other restaurants
          AppLogger.logError('$TAG Error prefetching products for ${restaurant.name}: $e');
        }
      }

      AppLogger.logInfo('$TAG Completed product prefetch for ${restaurants.length} restaurants');
    } catch (e) {
      AppLogger.logError('$TAG Error in product prefetch: $e');
    }
  }

  /// Prefetch store data (highest priority)
  static Future<void> _prefetchStoreData(BuildContext context) async {
    try {
      final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);

      // Check if store data is already loaded
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      if (storeProvider.storeData != null) {
        AppLogger.logInfo('$TAG Store data already loaded, skipping prefetch');
        return;
      }

      AppLogger.logInfo('$TAG Prefetching store data');
      await homeViewModel.fetchStores();
    } catch (e) {
      AppLogger.logError('$TAG Error prefetching store data: $e');
    }
  }

  static Future<void> _prefetchProductData(BuildContext context) async {
    try {
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);

      // Skip if no store is selected yet
      if (storeProvider.storeData == null || storeProvider.selectedRestaurant == null) {
        AppLogger.logInfo('$TAG No store selected yet, skipping product prefetch');
        return;
      }

      final productViewModel = Provider.of<ProductViewModel>(context, listen: false);

      // Use the store ID from the selected restaurant with null check
      final restaurant = storeProvider.selectedRestaurant;
      if (restaurant == null) {
        AppLogger.logInfo('$TAG No restaurant selected, skipping product prefetch');
        return;
      }

      final storeId = restaurant.storeId;
      if (storeId == null || storeId.isEmpty) {
        AppLogger.logInfo('$TAG Invalid store ID, skipping product prefetch');
        return;
      }

      AppLogger.logInfo('$TAG Prefetching product data for store: $storeId');
      await productViewModel.fetchProducts(storeId, forceRefresh: false);
    } catch (e) {
      AppLogger.logError('$TAG Error prefetching product data: $e');
    }
  }

  /// Prefetch order_shared_common history data
  static Future<void> _prefetchOrderHistory(BuildContext context) async {
    try {
      final orderHistoryViewModel = Provider.of<OrderHistoryViewModel>(context, listen: false);
      AppLogger.logInfo('$TAG Prefetching order_shared_common history data');
      await orderHistoryViewModel.prefetchOrderHistory();
    } catch (e) {
      AppLogger.logError('$TAG Error prefetching order_shared_common history data: $e');
    }
  }

  static Future<void> _prefetchWalletHistory(BuildContext context) async {
    try {
      final walletHistoryViewModel = Provider.of<WalletHistoryViewModel>(context, listen: false);
      AppLogger.logInfo('$TAG Prefetching wallet transaction data');
      await walletHistoryViewModel.prefetchWalletHistory();
    } catch (e) {
      AppLogger.logError('$TAG Error prefetching wallet transaction data: $e');
    }
  }

  // Prefetch wallet balance
  /// Flow: Get user data → Extract ID → Fetch balance
  static Future<void> _prefetchWalletBalance(BuildContext context) async {
    try {
      // Step 1: Get wallet view model
      final walletViewModel = Provider.of<WalletViewModel>(context, listen: false);

      // Step 2: Get user data - we need customer ID for the ViewModel
      // (even though the actual API doesn't use it)
      final userData = await AppPreference.getUserData();
      if (userData == null) {
        AppLogger.logInfo('$TAG No user data available, skipping wallet balance prefetch');
        return;
      }

      // Step 3: Get the customer ID
      final customerId = userData['b2c_Customer_Id'];
      if (customerId == null || customerId.isEmpty) {
        AppLogger.logInfo('$TAG No customer ID available, skipping wallet balance prefetch');
        return;
      }

      // Step 4: Fetch wallet balance
      AppLogger.logInfo('$TAG Prefetching wallet balance data');
      await walletViewModel.fetchWalletBalance(customerId);
      AppLogger.logInfo('$TAG Successfully prefetched wallet balance');
    } catch (e) {
      AppLogger.logError('$TAG Error prefetching wallet balance: $e');
    }
  }
}