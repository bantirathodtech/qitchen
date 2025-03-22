// cart_bar_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/log/loggers.dart';
import '../multiple/cart_manager.dart';

class CartBarCard extends StatelessWidget {
  static const String TAG = '[CartBarCard]';

  final String restaurantName;
  final int itemCount;
  final double totalPrice;

  const CartBarCard({
    super.key,
    required this.restaurantName,
    required this.itemCount,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildLogo(),
          _buildRestaurantInfo(),
          _buildCheckoutButton(context),
          _buildClearCartButton(context),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 12),
      child: Image.asset(
        'assets/images/cwsuite.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return Expanded(
      child: Text(
        restaurantName,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _navigateToCart(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: Text(
        '$itemCount item | ₹${totalPrice.toStringAsFixed(0)}\nCheckout',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildClearCartButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete),
      color: Colors.red[500],
      onPressed: () => _showClearCartDialog(context),
    );
  }

  void _navigateToCart(BuildContext context) {
    AppLogger.logInfo('$TAG: Navigating to cart');
    Navigator.pushNamed(context, '/cart');
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
            'Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Clear'),
            onPressed: () => _clearCart(context),
          ),
        ],
      ),
    );
  }

  void _clearCart(BuildContext context) {
    AppLogger.logInfo('$TAG: Clearing cart');

    final cartManager = context.read<CartManager>();
    cartManager.clearCart();

    Navigator.pop(context);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Your cart has been cleared.'),
          duration: Duration(seconds: 2),
        ),
      );
  }
}
