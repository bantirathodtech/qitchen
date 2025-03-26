// lib/features/history/viewmodel/order_history_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/log/loggers.dart';
import '../../../../common/routes/app_routes.dart';
import '../../../../data/db/app_preferences.dart';
import '../../../auth/verify/model/verify_model.dart';
import '../../../cart/multiple/cart_manager.dart';
import '../../../products/model/product_model.dart';
import '../../../store/provider/store_provider.dart';
import '../../../store/viewmodel/home_viewmodel.dart';
import '../cache/order_history_cache.dart';
import '../model/order_history_model.dart';
import '../repository/order_history_repository.dart';
import '../state/order_history_state.dart';

class OrderHistoryViewModel extends ChangeNotifier {
  static const String TAG = '[OrderHistoryViewModel]';

  final OrderHistoryRepository _repository;
  final OrderHistoryStateNotifier _stateNotifier;
  final CartManager _cartManager;
  String? _currentCustomerId;
  bool _isLoading = false;

  OrderHistoryViewModel({
    required OrderHistoryRepository repository,
    required OrderHistoryStateNotifier stateNotifier,
    required CartManager cartManager,
  })  : _repository = repository,
        _stateNotifier = stateNotifier,
        _cartManager = cartManager {
    // Initialize by trying to load customer data
    _initCustomerData();
  }

  OrderHistoryState get state => _stateNotifier.state;
  bool get isLoading => _isLoading;

  // Initialize by trying to load customer ID
  Future<void> _initCustomerData() async {
    try {
      final userData = await AppPreference.getUserData();
      if (userData.isNotEmpty) {
        final customer = CustomerModel.fromJson(userData);
        if (customer.b2cCustomerId != null && customer.b2cCustomerId!.isNotEmpty) {
          _currentCustomerId = customer.b2cCustomerId;
          AppLogger.logInfo('$TAG Initialized with customer ID: $_currentCustomerId');

          // Try to load cached data immediately
          await _loadCachedOrderHistory();
        }
      }
    } catch (e) {
      AppLogger.logError('$TAG Error initializing customer data: $e');
    }
  }

  // Load cached order_shared_common history data if available
  Future<void> _loadCachedOrderHistory() async {
    if (_currentCustomerId == null) return;

    try {
      AppLogger.logInfo('$TAG Attempting to load cached orders for customer: $_currentCustomerId');
      final cachedOrders = await OrderHistoryCache.getOrderHistoryData(_currentCustomerId!);

      if (cachedOrders != null && cachedOrders.isNotEmpty) {
        AppLogger.logInfo('$TAG Loaded ${cachedOrders.length} orders from cache');

        // Filter out any potential duplicates in the cache
        final uniqueOrders = _getUniqueOrders(cachedOrders);

        // Sort by date, newest first
        uniqueOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

        AppLogger.logInfo('$TAG Setting ${uniqueOrders.length} unique orders from cache to state');
        _stateNotifier.setOrders(uniqueOrders);
      } else {
        AppLogger.logInfo('$TAG No valid cached order_shared_common data found');
      }
    } catch (e) {
      AppLogger.logError('$TAG Error loading cached order_shared_common history: $e');
    }
  }

  // Main method to load order_shared_common history
  // Future<void> loadOrderHistory(String customerId) async {
  //   if (_isLoading) {
  //     AppLogger.logInfo('$TAG Already loading data, ignoring request');
  //     return; // Prevent multiple simultaneous loads
  //   }
  //
  //   try {
  //     _isLoading = true;
  //     _currentCustomerId = customerId;
  //     AppLogger.logInfo('$TAG Loading order_shared_common history for customer: $customerId');
  //     _stateNotifier.setLoading();
  //
  //     // First try to load from cache
  //     final cachedOrders = await OrderHistoryCache.getOrderHistoryData(customerId);
  //
  //     if (cachedOrders != null && cachedOrders.isNotEmpty) {
  //       AppLogger.logInfo('$TAG Using cached order_shared_common history data (${cachedOrders.length} orders)');
  //
  //       // Filter and sort cached orders
  //       final uniqueCachedOrders = _getUniqueOrders(cachedOrders);
  //       uniqueCachedOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
  //
  //       // Update UI with cached data while we fetch fresh data
  //       _stateNotifier.setOrders(uniqueCachedOrders);
  //     }
  //
  //     // Then fetch fresh data from server
  //     AppLogger.logInfo('$TAG Fetching fresh order_shared_common history data from server');
  //     final orders = await _repository.getOrderHistory(customerId);
  //
  //     // Ensure we have unique orders and sort them
  //     final uniqueOrders = _getUniqueOrders(orders);
  //     uniqueOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
  //
  //     AppLogger.logInfo('$TAG Fetched ${orders.length} orders, filtered to ${uniqueOrders.length} unique orders');
  //
  //     // Set orders only if they're different from what's in state
  //     if (!_ordersEqual(uniqueOrders, _stateNotifier.state.orders)) {
  //       AppLogger.logInfo('$TAG Orders changed, updating state');
  //       _stateNotifier.setOrders(uniqueOrders);
  //     } else {
  //       AppLogger.logInfo('$TAG Orders unchanged, not updating state');
  //     }
  //
  //     // Cache the fetched data
  //     AppLogger.logInfo('$TAG Caching ${uniqueOrders.length} orders');
  //     await OrderHistoryCache.saveOrderHistoryData(customerId, uniqueOrders);
  //   } catch (e) {
  //     AppLogger.logError('$TAG Error loading order_shared_common history: $e');
  //     _stateNotifier.setError(e.toString());
  //   } finally {
  //     _isLoading = false;
  //   }
  // }

  // In order_history_viewmodel.dart, ensure orders are sorted correctly in loadOrderHistory method

  Future<void> loadOrderHistory(String customerId) async {
    if (_isLoading) {
      AppLogger.logInfo('$TAG Already loading data, ignoring request');
      return; // Prevent multiple simultaneous loads
    }

    try {
      _isLoading = true;
      _currentCustomerId = customerId;
      AppLogger.logInfo('$TAG Loading order history for customer: $customerId');
      _stateNotifier.setLoading();

      // First try to load from cache
      final cachedOrders = await OrderHistoryCache.getOrderHistoryData(customerId);

      if (cachedOrders != null && cachedOrders.isNotEmpty) {
        AppLogger.logInfo('$TAG Using cached order history data (${cachedOrders.length} orders)');

        // Filter and sort cached orders - NEWEST FIRST
        final uniqueCachedOrders = _getUniqueOrders(cachedOrders);
        uniqueCachedOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

        // Update UI with cached data while we fetch fresh data
        _stateNotifier.setOrders(uniqueCachedOrders);
      }

      // Then fetch fresh data from server
      AppLogger.logInfo('$TAG Fetching fresh order history data from server');
      final orders = await _repository.getOrderHistory(customerId);

      // Ensure we have unique orders and sort them - NEWEST FIRST
      final uniqueOrders = _getUniqueOrders(orders);
      uniqueOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

      AppLogger.logInfo('$TAG Fetched ${orders.length} orders, filtered to ${uniqueOrders.length} unique orders');

      // Set orders only if they're different from what's in state
      if (!_ordersEqual(uniqueOrders, _stateNotifier.state.orders)) {
        AppLogger.logInfo('$TAG Orders changed, updating state');
        _stateNotifier.setOrders(uniqueOrders);
      } else {
        AppLogger.logInfo('$TAG Orders unchanged, not updating state');
      }

      // Cache the fetched data
      AppLogger.logInfo('$TAG Caching ${uniqueOrders.length} orders');
      await OrderHistoryCache.saveOrderHistoryData(customerId, uniqueOrders);
    } catch (e) {
      AppLogger.logError('$TAG Error loading order history: $e');
      _stateNotifier.setError(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  // Prefetch order_shared_common history in the background (can be called from app startup or main tab)
  Future<void> prefetchOrderHistory() async {
    try {
      if (_currentCustomerId == null) {
        final userData = await AppPreference.getUserData();
        if (userData.isNotEmpty) {
          final customer = CustomerModel.fromJson(userData);
          if (customer.b2cCustomerId != null && customer.b2cCustomerId!.isNotEmpty) {
            _currentCustomerId = customer.b2cCustomerId;
          } else {
            AppLogger.logInfo('$TAG No customer ID available for prefetch');
            return; // No customer ID available
          }
        } else {
          AppLogger.logInfo('$TAG No user data available for prefetch');
          return; // No user data available
        }
      }

      // First check if we have cached data that is still valid
      final cachedOrders = await OrderHistoryCache.getOrderHistoryData(_currentCustomerId!);
      if (cachedOrders != null && cachedOrders.isNotEmpty) {
        AppLogger.logInfo('$TAG Using existing valid cached data for prefetch');
        return; // Skip prefetch if we have valid cache
      }

      // Otherwise fetch in background
      AppLogger.logInfo('$TAG Prefetching order_shared_common history data for customer: $_currentCustomerId');
      final orders = await _repository.getOrderHistory(_currentCustomerId!);
      final uniqueOrders = _getUniqueOrders(orders);
      await OrderHistoryCache.saveOrderHistoryData(_currentCustomerId!, uniqueOrders);
      AppLogger.logInfo('$TAG Successfully prefetched and cached ${uniqueOrders.length} orders');
    } catch (e) {
      AppLogger.logError('$TAG Error prefetching order_shared_common history: $e');
      // Don't update UI state for background prefetch errors
    }
  }

  // Helper method to filter unique orders by orderId
  List<OrderHistory> _getUniqueOrders(List<OrderHistory> orders) {
    final uniqueOrders = <OrderHistory>[];
    final orderIds = <String>{};

    for (final order in orders) {
      if (!orderIds.contains(order.orderId)) {
        orderIds.add(order.orderId);
        uniqueOrders.add(order);
      }
    }

    return uniqueOrders;
  }

  // Helper method to deeply compare order_shared_common lists
  bool _ordersEqual(List<OrderHistory> a, List<OrderHistory> b) {
    if (a.length != b.length) return false;

    // Convert to Set of orderIds for quick comparison
    final aIds = a.map((order) => order.orderId).toSet();
    final bIds = b.map((order) => order.orderId).toSet();

    return setEquals(aIds, bIds);
  }

  // Helper to compare sets
  bool setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  Future<void> reorderItems(BuildContext context, OrderHistory order) async {
    try {
      AppLogger.logInfo(
          '$TAG Starting reorder process for order_shared_common: ${order.orderId}');

      final storeProvider = context.read<StoreProvider>();
      final homeViewModel = context.read<HomeViewModel>();

      // Ensure store data is loaded
      if (storeProvider.storeData == null) {
        AppLogger.logInfo('$TAG Loading store data first');
        await homeViewModel.fetchStores();
      }

      if (storeProvider.storeData == null) {
        throw Exception('Unable to load store data');
      }

      // Find matching restaurant with more detailed logging
      AppLogger.logInfo('$TAG Looking for restaurant: ${order.storeName}');
      AppLogger.logInfo(
          '$TAG Available restaurants: ${storeProvider.storeData?.restaurants.map((r) => r.name).join(', ')}');

      final restaurant = storeProvider.storeData!.restaurants.firstWhere(
            (r) =>
        r.name.trim().toLowerCase() == order.storeName.trim().toLowerCase(),
        orElse: () {
          AppLogger.logError('$TAG Restaurant not found: ${order.storeName}');
          throw Exception(
              'Restaurant "${order.storeName}" is currently unavailable');
        },
      );

      // Validate business unit
      if (!storeProvider
          .validateBusinessUnit(restaurant.businessUnit.csBunitId)) {
        throw Exception('Cannot mix items from different business units');
      }

      // Clear existing cart after confirmation
      _cartManager.clearCart();

      // Add each item from the order_shared_common to cart
      for (var historyItem in order.items) {
        // Convert historical addons to cart format
        final addons = _convertAddonsToCartFormat(historyItem.addons);

        final product = ProductModel(
          productId: historyItem.productId,
          categoryId: '',
          categoryName: '',
          name: historyItem.productName,
          veg: 'N',
          unitprice: historyItem.unitPrice.toString(),
          preorder: 'N',
          listprice: '0',
          bestseller: 'N',
          productioncenter: restaurant.name,
          imageUrl: '',
          shortDesc: '',
          addOnGroups: [],
        );

        // Add to cart using CartManager
        _cartManager.addToCart(
          context,
          restaurant.name,
          product,
          addons,
          historyItem.quantity,
          historyItem.totalPrice,
        );

        AppLogger.logInfo(
            '$TAG Added item to cart: ${product.name} x ${historyItem.quantity}');
      }

      // Show success message
      _showSuccess(context, 'Items added to cart successfully');

      // Navigate to cart
      Routes.navigateToCartTab(context);
    } catch (e) {
      AppLogger.logError('$TAG Error during reorder: $e');
      _showError(context, e.toString());
    }
  }

  Map<String, List<AddOnItem>> _convertAddonsToCartFormat(
      List<OrderAddon> historyAddons) {
    if (historyAddons.isEmpty) return {};

    return {
      'default': historyAddons
          .map((addon) => AddOnItem(
        id: addon.addonId,
        name: addon.name,
        price: addon.price.toString(),
      ))
          .toList(),
    };
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> refreshOrders(String customerId) async {
    await loadOrderHistory(customerId);
  }

  @override
  void dispose() {
    _stateNotifier.dispose();
    super.dispose();
  }
}

// // lib/features/history/viewmodel/order_history_viewmodel.dart - Updated version
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../common/log/loggers.dart';
// import '../../../../common/routes/app_routes.dart';
// import '../../../../data/db/app_preferences.dart';
// import '../../../auth/verify/model/verify_model.dart';
// import '../../../cart/multiple/cart_manager.dart';
// import '../../../products/model/product_model.dart';
// import '../../../store/provider/store_provider.dart';
// import '../../../store/viewmodel/home_viewmodel.dart';
// import '../cache/order_history_cache.dart';
// import '../model/order_history_model.dart';
// import '../repository/order_history_repository.dart';
// import '../state/order_history_state.dart';
//
// class OrderHistoryViewModel extends ChangeNotifier {
//   static const String TAG = '[OrderHistoryViewModel]';
//
//   final OrderHistoryRepository _repository;
//   final OrderHistoryStateNotifier _stateNotifier;
//   final CartManager _cartManager;
//   String? _currentCustomerId;
//   bool _isLoading = false;
//
//   OrderHistoryViewModel({
//     required OrderHistoryRepository repository,
//     required OrderHistoryStateNotifier stateNotifier,
//     required CartManager cartManager,
//   })  : _repository = repository,
//         _stateNotifier = stateNotifier,
//         _cartManager = cartManager {
//     // Initialize by trying to load customer data
//     _initCustomerData();
//   }
//
//   OrderHistoryState get state => _stateNotifier.state;
//   bool get isLoading => _isLoading;
//
//   // Initialize by trying to load customer ID
//   Future<void> _initCustomerData() async {
//     try {
//       final userData = await AppPreference.getUserData();
//       if (userData.isNotEmpty) {
//         final customer = CustomerModel.fromJson(userData);
//         if (customer.b2cCustomerId != null && customer.b2cCustomerId!.isNotEmpty) {
//           _currentCustomerId = customer.b2cCustomerId;
//
//           // Try to load cached data immediately
//           _loadCachedOrderHistory();
//         }
//       }
//     } catch (e) {
//       AppLogger.logError('$TAG Error initializing customer data: $e');
//     }
//   }
//
//   // Load cached order_shared_common history data if available
//   Future<void> _loadCachedOrderHistory() async {
//     if (_currentCustomerId == null) return;
//
//     try {
//       final cachedOrders = await OrderHistoryCache.getOrderHistoryData(_currentCustomerId!);
//
//       if (cachedOrders != null && cachedOrders.isNotEmpty) {
//         AppLogger.logInfo('$TAG Loaded ${cachedOrders.length} orders from cache');
//         cachedOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
//         _stateNotifier.setOrders(cachedOrders);
//       }
//     } catch (e) {
//       AppLogger.logError('$TAG Error loading cached order_shared_common history: $e');
//     }
//   }
//
//   // Main method to load order_shared_common history
//   Future<void> loadOrderHistory(String customerId) async {
//     if (_isLoading) return; // Prevent multiple simultaneous loads
//
//     try {
//       _isLoading = true;
//       _currentCustomerId = customerId;
//       _stateNotifier.setLoading();
//
//       // First try to load from cache
//       final cachedOrders = await OrderHistoryCache.getOrderHistoryData(customerId);
//
//       if (cachedOrders != null && cachedOrders.isNotEmpty) {
//         AppLogger.logInfo('$TAG Using cached order_shared_common history data for customer: $customerId');
//         cachedOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
//         _stateNotifier.setOrders(cachedOrders);
//       }
//
//       // Then fetch fresh data from server
//       final orders = await _repository.getOrderHistory(customerId);
//       orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
//
//       // Set orders only if state has changed
//       if (!_listEquals(orders, _stateNotifier.state.orders)) {
//         _stateNotifier.setOrders(orders);
//       }
//
//       // Cache the fetched data
//       await OrderHistoryCache.saveOrderHistoryData(customerId, orders);
//     } catch (e) {
//       AppLogger.logError('$TAG Error loading order_shared_common history: $e');
//       _stateNotifier.setError(e.toString());
//     } finally {
//       _isLoading = false;
//     }
//   }
//
//   // Prefetch order_shared_common history in the background (can be called from app startup or main tab)
//   Future<void> prefetchOrderHistory() async {
//     try {
//       if (_currentCustomerId == null) {
//         final userData = await AppPreference.getUserData();
//         if (userData.isNotEmpty) {
//           final customer = CustomerModel.fromJson(userData);
//           if (customer.b2cCustomerId != null && customer.b2cCustomerId!.isNotEmpty) {
//             _currentCustomerId = customer.b2cCustomerId;
//           } else {
//             return; // No customer ID available
//           }
//         } else {
//           return; // No user data available
//         }
//       }
//
//       // First check if we have cached data that is still valid
//       final cachedOrders = await OrderHistoryCache.getOrderHistoryData(_currentCustomerId!);
//       if (cachedOrders != null && cachedOrders.isNotEmpty) {
//         AppLogger.logInfo('$TAG Using existing valid cached data for prefetch');
//         return; // Skip prefetch if we have valid cache
//       }
//
//       // Otherwise fetch in background
//       AppLogger.logInfo('$TAG Prefetching order_shared_common history data for customer: $_currentCustomerId');
//       final orders = await _repository.getOrderHistory(_currentCustomerId!);
//       await OrderHistoryCache.saveOrderHistoryData(_currentCustomerId!, orders);
//       AppLogger.logInfo('$TAG Successfully prefetched and cached ${orders.length} orders');
//     } catch (e) {
//       AppLogger.logError('$TAG Error prefetching order_shared_common history: $e');
//       // Don't update UI state for background prefetch errors
//     }
//   }
//
//   Future<void> reorderItems(BuildContext context, OrderHistory order_shared_common) async {
//     try {
//       AppLogger.logInfo(
//           '$TAG Starting reorder process for order_shared_common: ${order_shared_common.orderId}');
//
//       final storeProvider = context.read<StoreProvider>();
//       final homeViewModel = context.read<HomeViewModel>();
//
//       // Ensure store data is loaded
//       if (storeProvider.storeData == null) {
//         AppLogger.logInfo('$TAG Loading store data first');
//         await homeViewModel.fetchStores();
//       }
//
//       if (storeProvider.storeData == null) {
//         throw Exception('Unable to load store data');
//       }
//
//       // Find matching restaurant with more detailed logging
//       AppLogger.logInfo('$TAG Looking for restaurant: ${order_shared_common.storeName}');
//       AppLogger.logInfo(
//           '$TAG Available restaurants: ${storeProvider.storeData?.restaurants.map((r) => r.name).join(', ')}');
//
//       final restaurant = storeProvider.storeData!.restaurants.firstWhere(
//             (r) =>
//         r.name.trim().toLowerCase() == order_shared_common.storeName.trim().toLowerCase(),
//         orElse: () {
//           AppLogger.logError('$TAG Restaurant not found: ${order_shared_common.storeName}');
//           throw Exception(
//               'Restaurant "${order_shared_common.storeName}" is currently unavailable');
//         },
//       );
//
//       // Validate business unit
//       if (!storeProvider
//           .validateBusinessUnit(restaurant.businessUnit.csBunitId)) {
//         throw Exception('Cannot mix items from different business units');
//       }
//
//       // Clear existing cart after confirmation
//       _cartManager.clearCart();
//
//       // Add each item from the order_shared_common to cart
//       for (var historyItem in order_shared_common.items) {
//         // Convert historical addons to cart format
//         final addons = _convertAddonsToCartFormat(historyItem.addons);
//
//         final product = ProductModel(
//           productId: historyItem.productId,
//           categoryId: '',
//           categoryName: '',
//           name: historyItem.productName,
//           veg: 'N',
//           unitprice: historyItem.unitPrice.toString(),
//           preorder: 'N',
//           listprice: '0',
//           bestseller: 'N',
//           productioncenter: restaurant.name,
//           imageUrl: '',
//           shortDesc: '',
//           addOnGroups: [],
//         );
//
//         // Add to cart using CartManager
//         _cartManager.addToCart(
//           context,
//           restaurant.name,
//           product,
//           addons,
//           historyItem.quantity,
//           historyItem.totalPrice,
//         );
//
//         AppLogger.logInfo(
//             '$TAG Added item to cart: ${product.name} x ${historyItem.quantity}');
//       }
//
//       // Show success message
//       _showSuccess(context, 'Items added to cart successfully');
//
//       // Navigate to cart
//       Routes.navigateToCartTab(context);
//     } catch (e) {
//       AppLogger.logError('$TAG Error during reorder: $e');
//       _showError(context, e.toString());
//     }
//   }
//
//   Map<String, List<AddOnItem>> _convertAddonsToCartFormat(
//       List<OrderAddon> historyAddons) {
//     if (historyAddons.isEmpty) return {};
//
//     return {
//       'default': historyAddons
//           .map((addon) => AddOnItem(
//         id: addon.addonId,
//         name: addon.name,
//         price: addon.price.toString(),
//       ))
//           .toList(),
//     };
//   }
//
//   void _showError(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
//
//   void _showSuccess(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
//
//   Future<void> refreshOrders(String customerId) async {
//     await loadOrderHistory(customerId);
//   }
//
//   // Helper method to compare lists of OrderHistory objects
//   bool _listEquals(List<OrderHistory> a, List<OrderHistory> b) {
//     if (a.length != b.length) return false;
//
//     for (int i = 0; i < a.length; i++) {
//       if (a[i].orderId != b[i].orderId) return false;
//     }
//
//     return true;
//   }
//
//   @override
//   void dispose() {
//     _stateNotifier.dispose();
//     super.dispose();
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../common/log/loggers.dart';
// import '../../../common/routes/app_routes.dart';
// import '../../home/cart/multiple/cart_manager.dart';
// import '../../products/model/product_model.dart';
// import '../../store/provider/store_provider.dart';
// import '../../store/viewmodel/home_viewmodel.dart';
// import '../model/order_history_model.dart';
// import '../repository/order_history_repository.dart';
// import '../state/order_history_state.dart';
//
// class OrderHistoryViewModel extends ChangeNotifier {
//   static const String TAG = '[OrderHistoryViewModel]';
//
//   final OrderHistoryRepository _repository;
//   final OrderHistoryStateNotifier _stateNotifier;
//   final CartManager _cartManager;
//
//   OrderHistoryViewModel({
//     required OrderHistoryRepository repository,
//     required OrderHistoryStateNotifier stateNotifier,
//     required CartManager cartManager,
//   })  : _repository = repository,
//         _stateNotifier = stateNotifier,
//         _cartManager = cartManager;
//
//   OrderHistoryState get state => _stateNotifier.state;
//
//   Future<void> loadOrderHistory(String customerId) async {
//     try {
//       _stateNotifier.setLoading();
//       final orders = await _repository.getOrderHistory(customerId);
//       orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
//       _stateNotifier.setOrders(orders);
//     } catch (e) {
//       AppLogger.logError('$TAG Error loading order_shared_common history: $e');
//       _stateNotifier.setError(e.toString());
//     }
//   }
//
//   Future<void> reorderItems(BuildContext context, OrderHistory order_shared_common) async {
//     try {
//       AppLogger.logInfo(
//           '$TAG Starting reorder process for order_shared_common: ${order_shared_common.orderId}');
//
//       final storeProvider = context.read<StoreProvider>();
//       final homeViewModel = context.read<HomeViewModel>();
//
//       // Ensure store data is loaded
//       if (storeProvider.storeData == null) {
//         AppLogger.logInfo('$TAG Loading store data first');
//         await homeViewModel.fetchStores();
//       }
//
//       if (storeProvider.storeData == null) {
//         throw Exception('Unable to load store data');
//       }
//
//       // Find matching restaurant with more detailed logging
//       AppLogger.logInfo('$TAG Looking for restaurant: ${order_shared_common.storeName}');
//       AppLogger.logInfo(
//           '$TAG Available restaurants: ${storeProvider.storeData?.restaurants.map((r) => r.name).join(', ')}');
//
//       final restaurant = storeProvider.storeData!.restaurants.firstWhere(
//         (r) =>
//             r.name.trim().toLowerCase() == order_shared_common.storeName.trim().toLowerCase(),
//         orElse: () {
//           AppLogger.logError('$TAG Restaurant not found: ${order_shared_common.storeName}');
//           throw Exception(
//               'Restaurant "${order_shared_common.storeName}" is currently unavailable');
//         },
//       );
//
//       // Validate business unit
//       if (!storeProvider
//           .validateBusinessUnit(restaurant.businessUnit.csBunitId)) {
//         throw Exception('Cannot mix items from different business units');
//       }
//
//       // Clear existing cart after confirmation
//       _cartManager.clearCart();
//
//       // Add each item from the order_shared_common to cart
//       for (var historyItem in order_shared_common.items) {
//         // Convert historical addons to cart format
//         final addons = _convertAddonsToCartFormat(historyItem.addons);
//
//         // // Create product model from historical data
//         // final product = ProductModel(
//         //   productId: historyItem.productId,
//         //   categoryId: '',
//         //   name: historyItem.productName,
//         //   veg: 'N',
//         //   unitprice: historyItem.unitPrice.toString(),
//         //   productionCenter: restaurant.name,
//         //   imageUrl: '',
//         //   shortDesc: '',
//         //   addOnGroups: [],
//         // )
//         // below added at 13/03/25
//         final product = ProductModel(
//           productId: historyItem.productId,
//           categoryId: '',
//           categoryName: '', // Add this required parameter
//           name: historyItem.productName,
//           veg: 'N',
//           unitprice: historyItem.unitPrice.toString(),
//           preorder: 'N', // Add this required parameter
//           listprice: '0', // Add this required parameter
//           bestseller: 'N', // Add this required parameter
//           productioncenter: restaurant.name, // Change from productionCenter to productioncenter
//           imageUrl: '',
//           shortDesc: '',
//           addOnGroups: [],
//         );
//
//         // Add to cart using CartManager
//         _cartManager.addToCart(
//           context,
//           restaurant.name,
//           product,
//           addons,
//           historyItem.quantity,
//           historyItem.totalPrice,
//         );
//
//         AppLogger.logInfo(
//             '$TAG Added item to cart: ${product.name} x ${historyItem.quantity}');
//       }
//
//       // Show success message
//       _showSuccess(context, 'Items added to cart successfully');
//
//       // Navigate to cart
//       Routes.navigateToCartTab(context);
//     } catch (e) {
//       AppLogger.logError('$TAG Error during reorder: $e');
//       _showError(context, e.toString());
//     }
//   }
//
//   Map<String, List<AddOnItem>> _convertAddonsToCartFormat(
//       List<OrderAddon> historyAddons) {
//     if (historyAddons.isEmpty) return {};
//
//     return {
//       'default': historyAddons
//           .map((addon) => AddOnItem(
//                 id: addon.addonId,
//                 name: addon.name,
//                 price: addon.price.toString(),
//               ))
//           .toList(),
//     };
//   }
//
//   void _showError(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
//
//   void _showSuccess(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
//
//   Future<void> refreshOrders(String customerId) async {
//     await loadOrderHistory(customerId);
//   }
//
//   @override
//   void dispose() {
//     _stateNotifier.dispose();
//     super.dispose();
//   }
// }
