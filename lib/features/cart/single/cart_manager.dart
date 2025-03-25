// import 'package:flutter/material.dart';
//
// import '../../../../common/log/loggers.dart';
// import '../../products/model/product_model.dart';
// import '../models/cart_item.dart';
// import '../models/cart_validation.dart';
//
// // to allow adding products from single restaurants only
// class CartManager extends ChangeNotifier {
//   static const String TAG = '[CartManager]';
//
//   final Map<String, List<CartItem>> _cartItemsByRestaurant = {};
//   String? _currentRestaurant;
//
//   // Getters
//   Map<String, List<CartItem>> get cartItemsByRestaurant =>
//       _cartItemsByRestaurant;
//
//   String? get currentRestaurant => _currentRestaurant;
//
//   double getTotalPrice(String restaurantName) {
//     return _cartItemsByRestaurant[restaurantName]?.fold(
//           0.0,
//           (sum, item) => sum! + (item.totalPrice * item.quantity),
//         ) ??
//         0.0;
//   }
//
//   int getItemCount(String restaurantName) {
//     return _cartItemsByRestaurant[restaurantName]?.length ?? 0;
//   }
//
//   void addToCart(
//     BuildContext context,
//     String restaurantName,
//     ProductModel product,
//     Map<String, List<AddOnItem>> selectedAddons,
//     int quantity,
//     double totalPrice,
//   ) {
//     try {
//       AppLogger.logInfo('$TAG: Adding ${product.name} to cart');
//
//       if (_currentRestaurant != null && _currentRestaurant != restaurantName) {
//         _showError(context, 'Please clear your current cart first');
//         return;
//       }
//
//       _currentRestaurant ??= restaurantName;
//       final items =
//           _cartItemsByRestaurant.putIfAbsent(restaurantName, () => []);
//
//       _updateOrAddItem(items, product, selectedAddons, quantity, totalPrice);
//
//       notifyListeners();
//     } catch (e) {
//       AppLogger.logError('$TAG: Error adding to cart: $e');
//       _showError(context, 'Failed to add item to cart');
//     }
//   }
//
//   void decrementCartItem(String restaurantName, CartItem cartItem) {
//     try {
//       final items = _cartItemsByRestaurant[restaurantName];
//       if (items == null) return;
//
//       final index = _findItemIndex(items, cartItem.product.productId);
//       if (index == -1) return;
//
//       if (cartItem.quantity > 1) {
//         items[index] = items[index].copyWith(
//           quantity: items[index].quantity - 1,
//         );
//       } else {
//         items.removeAt(index);
//       }
//
//       if (items.isEmpty) {
//         _cartItemsByRestaurant.remove(restaurantName);
//         _currentRestaurant = null;
//       }
//
//       notifyListeners();
//     } catch (e) {
//       AppLogger.logError('$TAG: Error decrementing cart item: $e');
//     }
//   }
//
//   void removeFromCart(String restaurantName, CartItem cartItem) {
//     try {
//       AppLogger.logInfo('$TAG: Removing item from cart');
//
//       final items = _cartItemsByRestaurant[restaurantName];
//       if (items == null) return;
//
//       items.remove(cartItem);
//
//       if (items.isEmpty) {
//         _cartItemsByRestaurant.remove(restaurantName);
//         _currentRestaurant = null;
//       }
//
//       notifyListeners();
//     } catch (e) {
//       AppLogger.logError('$TAG: Error removing item from cart: $e');
//     }
//   }
//
//   void clearCart() {
//     AppLogger.logInfo('$TAG: Clearing cart');
//     _cartItemsByRestaurant.clear();
//     _currentRestaurant = null;
//     notifyListeners();
//   }
//
//   CartValidation validateForAddToCart(String csBunitId) {
//     if (_currentRestaurant != null && csBunitId.isEmpty) {
//       return CartValidation(
//         isValid: false,
//         message: 'Invalid restaurant business unit',
//       );
//     }
//     return CartValidation(isValid: true);
//   }
//
//   // Private helper methods
//   void _updateOrAddItem(
//     List<CartItem> items,
//     ProductModel product,
//     Map<String, List<AddOnItem>> selectedAddons,
//     int quantity,
//     double totalPrice,
//   ) {
//     final index = _findItemIndex(items, product.productId);
//
//     if (index != -1) {
//       items[index] = items[index].copyWith(
//         quantity: items[index].quantity + quantity,
//       );
//     } else {
//       items.add(CartItem(
//         product: product,
//         selectedAddons: selectedAddons,
//         quantity: quantity,
//         totalPrice: totalPrice,
//       ));
//     }
//   }
//
//   int get itemCount {
//     return _cartItemsByRestaurant.values.fold(
//       0,
//       (sum, items) => sum + items.length,
//     );
//   }
//
//   int _findItemIndex(List<CartItem> items, String productId) {
//     return items.indexWhere((item) => item.product.productId == productId);
//   }
//
//   void _showError(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
// }
