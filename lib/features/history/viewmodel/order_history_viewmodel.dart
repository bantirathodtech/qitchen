import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/log/loggers.dart';
import '../../../common/routes/app_routes.dart';
import '../../home/cart/multiple/cart_manager.dart';
import '../../products/model/product_model.dart';
import '../../store/provider/store_provider.dart';
import '../../store/viewmodel/home_viewmodel.dart';
import '../model/order_history_model.dart';
import '../repository/order_history_repository.dart';
import '../state/order_history_state.dart';

class OrderHistoryViewModel extends ChangeNotifier {
  static const String TAG = '[OrderHistoryViewModel]';

  final OrderHistoryRepository _repository;
  final OrderHistoryStateNotifier _stateNotifier;
  final CartManager _cartManager;

  OrderHistoryViewModel({
    required OrderHistoryRepository repository,
    required OrderHistoryStateNotifier stateNotifier,
    required CartManager cartManager,
  })  : _repository = repository,
        _stateNotifier = stateNotifier,
        _cartManager = cartManager;

  OrderHistoryState get state => _stateNotifier.state;

  Future<void> loadOrderHistory(String customerId) async {
    try {
      _stateNotifier.setLoading();
      final orders = await _repository.getOrderHistory(customerId);
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      _stateNotifier.setOrders(orders);
    } catch (e) {
      AppLogger.logError('$TAG Error loading order history: $e');
      _stateNotifier.setError(e.toString());
    }
  }

  Future<void> reorderItems(BuildContext context, OrderHistory order) async {
    try {
      AppLogger.logInfo(
          '$TAG Starting reorder process for order: ${order.orderId}');

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

      // Add each item from the order to cart
      for (var historyItem in order.items) {
        // Convert historical addons to cart format
        final addons = _convertAddonsToCartFormat(historyItem.addons);

        // // Create product model from historical data
        // final product = ProductModel(
        //   productId: historyItem.productId,
        //   categoryId: '',
        //   name: historyItem.productName,
        //   veg: 'N',
        //   unitprice: historyItem.unitPrice.toString(),
        //   productionCenter: restaurant.name,
        //   imageUrl: '',
        //   shortDesc: '',
        //   addOnGroups: [],
        // )
        // below added at 13/03/25
        final product = ProductModel(
          productId: historyItem.productId,
          categoryId: '',
          categoryName: '', // Add this required parameter
          name: historyItem.productName,
          veg: 'N',
          unitprice: historyItem.unitPrice.toString(),
          preorder: 'N', // Add this required parameter
          listprice: '0', // Add this required parameter
          bestseller: 'N', // Add this required parameter
          productioncenter: restaurant.name, // Change from productionCenter to productioncenter
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
