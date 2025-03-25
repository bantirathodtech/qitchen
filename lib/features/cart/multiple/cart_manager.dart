import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../common/log/loggers.dart';
import '../../../../data/db/app_preferences.dart';
import '../../products/model/product_model.dart';
import '../../store/provider/store_provider.dart';
import '../models/cart_item.dart';
import '../models/cart_validation.dart';

class CartManager with ChangeNotifier {
  static const String TAG = '[CartManager]';

  final StoreProvider storeProvider;
  Map<String, List<CartItem>> _cartItemsByRestaurant = {};

  CartManager(this.storeProvider) {
    _loadCartData();
  }

  Map<String, List<CartItem>> get cartItemsByRestaurant => _cartItemsByRestaurant;
  String? get currentRestaurant => _cartItemsByRestaurant.isEmpty ? null : _cartItemsByRestaurant.keys.first;
  List<String> get restaurants => _cartItemsByRestaurant.keys.toList();
  String? get currentBusinessUnitId => storeProvider.businessUnitId;

  Future<void> _loadCartData() async {
    try {
      final cartData = await AppPreference.getCartData();
      if (cartData != null) {
        final decodedData = json.decode(cartData) as Map<String, dynamic>;
        _cartItemsByRestaurant = decodedData.map((key, value) {
          return MapEntry(
            key,
            (value as List<dynamic>)
                .map((item) => CartItem(
              product: ProductModel.fromJson(item['product']),
              selectedAddons: (item['selectedAddons'] as Map<String, dynamic>).map(
                    (key, value) => MapEntry(
                  key,
                  (value as List).map((addon) => AddOnItem.fromJson(addon)).toList(),
                ),
              ),
              quantity: item['quantity'],
              totalPrice: item['totalPrice'],
              specialInstructions: item['specialInstructions'],
            ))
                .toList(),
          );
        });
        notifyListeners();
      }
    } catch (e) {
      AppLogger.logError('$TAG: Error loading cart data: $e');
    }
  }

  void updateItemNotes(String restaurantName, CartItem cartItem, String notes) {
    final items = _cartItemsByRestaurant[restaurantName];
    if (items != null) {
      final index = items.indexWhere((item) =>
      item.product.productId == cartItem.product.productId && item.selectedAddons == cartItem.selectedAddons);
      if (index != -1) {
        items[index] = cartItem.copyWith(specialInstructions: notes);
        _saveCartData();
        notifyListeners();
      }
    }
  }

  Future<void> _saveCartData() async {
    try {
      final encodedData = json.encode(_cartItemsByRestaurant.map((key, value) {
        return MapEntry(
          key,
          value
              .map((item) => {
            'product': item.product.toJson(),
            'selectedAddons': item.selectedAddons,
            'quantity': item.quantity,
            'totalPrice': item.totalPrice,
            'specialInstructions': item.specialInstructions,
          })
              .toList(),
        );
      }));
      await AppPreference.saveCartData(encodedData);
    } catch (e) {
      AppLogger.logError('$TAG: Error saving cart data: $e');
    }
  }

  void addToCart(
      BuildContext context,
      String restaurantName,
      ProductModel product,
      Map<String, List<AddOnItem>> addons,
      int quantity,
      double totalPrice,
      ) {
    try {
      AppLogger.logInfo('$TAG: Adding to cart - Product: ${product.name}, Quantity: $quantity, Price: $totalPrice');
      final restaurantValidation = validateRestaurant(restaurantName);
      AppLogger.logDebug('$TAG: Restaurant validation result: ${restaurantValidation.isValid}');
      if (!restaurantValidation.isValid) {
        _showError(context, restaurantValidation.message ?? 'Invalid restaurant selection');
        return;
      }
      if (product.addOnGroups?.isNotEmpty ?? false) {
        final addonValidation = validateAddons(product, addons);
        AppLogger.logDebug('$TAG: Addon validation result: ${addonValidation.isValid}');
        if (!addonValidation.isValid) {
          _showError(context, addonValidation.message ?? 'Invalid addon selection');
          return;
        }
      }
      final existingItem = _findCartItem(restaurantName, product);
      if (existingItem != null) {
        final updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
          totalPrice: existingItem.totalPrice + totalPrice,
        );
        _updateCartItem(restaurantName, updatedItem);
      } else {
        final newItem = CartItem(
          product: product,
          selectedAddons: addons,
          quantity: quantity,
          totalPrice: totalPrice,
        );
        _addCartItem(restaurantName, newItem);
      }
      _saveCartData();
      notifyListeners();
    } catch (e) {
      AppLogger.logError('$TAG: Error adding to cart: $e');
      _showError(context, 'Failed to add to cart');
    }
  }

  CartItem? _findCartItem(String restaurantName, ProductModel product) {
    final items = _cartItemsByRestaurant[restaurantName];
    if (items == null) return null;
    try {
      return items.firstWhere((item) => item.product.productId == product.productId);
    } catch (e) {
      return null;
    }
  }

  void _updateCartItem(String restaurantName, CartItem updatedItem) {
    final items = _cartItemsByRestaurant[restaurantName];
    if (items == null) return;
    final index = items.indexWhere((item) => item.product.productId == updatedItem.product.productId);
    if (index != -1) {
      items[index] = updatedItem;
    }
  }

  void _addCartItem(String restaurantName, CartItem newItem) {
    if (!_cartItemsByRestaurant.containsKey(restaurantName)) {
      _cartItemsByRestaurant[restaurantName] = [];
    }
    _cartItemsByRestaurant[restaurantName]!.add(newItem);
  }

  CartValidation validateRestaurant(String restaurantName) {
    return const CartValidation(isValid: true);
  }

  CartValidation validateAddons(ProductModel product, Map<String, List<AddOnItem>> addons) {
    try {
      for (var group in product.addOnGroups ?? []) {
        if (group.name == "Customes") continue;
        final selectedAddons = addons[group.id] ?? [];
        if (selectedAddons.length < group.minqty || selectedAddons.length > group.maxqty) {
          return CartValidation(
            isValid: false,
            message: 'Invalid selection for addon group: ${group.name}',
          );
        }
      }
      return const CartValidation(isValid: true);
    } catch (e) {
      AppLogger.logError('$TAG: Error validating addons: $e');
      return const CartValidation(isValid: false);
    }
  }

  void incrementCartItem(String restaurantName, CartItem cartItem) {
    final items = _cartItemsByRestaurant[restaurantName];
    if (items == null) return;
    final index = items.indexOf(cartItem);
    if (index != -1) {
      items[index] = cartItem.copyWith(
        quantity: cartItem.quantity + 1,
        totalPrice: cartItem.totalPrice * ((cartItem.quantity + 1) / cartItem.quantity),
      );
      _saveCartData();
      notifyListeners();
    }
  }

  void decrementCartItem(String restaurantName, CartItem cartItem) {
    final items = _cartItemsByRestaurant[restaurantName];
    if (items == null) return;
    if (cartItem.quantity > 1) {
      final index = items.indexOf(cartItem);
      if (index != -1) {
        items[index] = cartItem.copyWith(
          quantity: cartItem.quantity - 1,
          totalPrice: cartItem.totalPrice * ((cartItem.quantity - 1) / cartItem.quantity),
        );
      }
    } else {
      removeFromCart(restaurantName, cartItem);
    }
    _saveCartData();
    notifyListeners();
  }

  void removeFromCart(String restaurantName, CartItem cartItem) {
    _cartItemsByRestaurant[restaurantName]?.remove(cartItem);
    if (_cartItemsByRestaurant[restaurantName]?.isEmpty ?? false) {
      _cartItemsByRestaurant.remove(restaurantName);
    }
    _saveCartData();
    notifyListeners();
  }

  void clearRestaurantCart(String restaurantName) {
    _cartItemsByRestaurant.remove(restaurantName);
    _saveCartData();
    notifyListeners();
  }

  void clearCart() {
    _cartItemsByRestaurant.clear();
    AppPreference.clearCartData();
    notifyListeners();
  }

  num getTotalPrice(String restaurantName) {
    return _cartItemsByRestaurant[restaurantName]?.fold<num>(0, (sum, item) => sum + item.totalPrice) ?? 0;
  }

  num get subtotal {
    return _cartItemsByRestaurant.values.expand((items) => items).fold<num>(0, (sum, item) => sum + item.totalPrice);
  }

  Map<String, num> getTotalTaxesByCategory() {
    return {'GST (5%)': subtotal * 0.05};
  }

  num get total {
    final taxes = getTotalTaxesByCategory().values.fold<num>(0, (sum, tax) => sum + tax);
    return subtotal + taxes;
  }

  num get itemCount {
    return _cartItemsByRestaurant.values.expand((items) => items).fold<num>(0, (sum, item) => sum + item.quantity);
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
