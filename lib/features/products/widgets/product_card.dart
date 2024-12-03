import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/log/loggers.dart';
import '../../../../common/styles/app_text_styles.dart';
import '../../addon/addons_screen.dart';
import '../../favorite/favorite_manager.dart';
import '../../home/cart/models/cart_item.dart';
import '../../home/cart/multiple/cart_manager.dart';
import '../model/product_model.dart';

/// ProductCard displays individual product information and handles cart interactions
class ProductCard extends StatelessWidget {
  static const String TAG = "ProductCard";
  final ProductModel product;
  final String restaurantName;
  final String csBunitId;

  const ProductCard({
    super.key,
    required this.product,
    required this.restaurantName,
    required this.csBunitId,
    required void Function() onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavoriteManager, CartManager>(
      builder: (context, favoriteManager, cartManager, child) {
        final cartItem = _findCartItem(cartManager);
        return _buildProductContainer(
            context, favoriteManager, cartManager, cartItem);
      },
    );
  }

  // UI STYLING FUNCTIONS

  /// Card container styling
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Image container styling
  BoxDecoration _imageContainerDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          spreadRadius: 1,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  /// Add button styling
  ButtonStyle _addButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF4364E8), // Brighter royal blue
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minimumSize: const Size(72, 32),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Quantity control container styling
  BoxDecoration _quantityControlDecoration() {
    return BoxDecoration(
      color: const Color(0xFF3754D3), // Match ADD button color
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF3754D3).withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // UI BUILDING FUNCTIONS

  /// Main container widget
  Widget _buildProductContainer(
    BuildContext context,
    FavoriteManager favoriteManager,
    CartManager cartManager,
    CartItem cartItem,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 0),
      padding: const EdgeInsets.all(0),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Product Image
          SizedBox(
            width: 120,
            child: _buildProductImage(),
          ),
          const SizedBox(width: 8),
          // Right side - Content
          Expanded(
            child: IntrinsicHeight(
              // This helps content take natural height
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with name and favorite
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildProductHeader(context, favoriteManager),
                      ),
                      SizedBox(
                        width: 40,
                        child: _buildFavoriteButton(context, favoriteManager),
                      ),
                    ],
                  ),
                  if (product.shortDesc != null) ...[
                    const SizedBox(height: 0),
                    Padding(
                      padding: const EdgeInsets.only(right: 2, top: 8),
                      child: _buildProductDescription(),
                    ),
                  ],
                  // const Spacer(),
                  SizedBox(
                    height: 8,
                  ),
                  _buildPriceAndCartControls(context, cartManager, cartItem),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Product image with animation
  Widget _buildProductImage() {
    return Hero(
      tag: 'product-${product.productId}',
      child: Stack(
        children: [
          Container(
            decoration: _imageContainerDecoration(),
            child: _buildMainImage(),
          ),
          _buildVegIndicator(),
        ],
      ),
    );
  }

  /// Main product image
  Widget _buildMainImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: product.imageUrl != null
          ? Image.network(
              product.imageUrl!,
              width: 130,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, size: 80, color: Colors.red),
            )
          : Container(
              width: 130,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image_not_supported, size: 40),
            ),
    );
  }

  /// Veg/non-veg indicator
  Widget _buildVegIndicator() {
    return Positioned(
      top: 5,
      right: 5,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          border: Border.all(
            color: product.veg == 'N' ? Colors.red : Colors.green,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Icon(
            Icons.circle,
            color: product.veg == 'N' ? Colors.red : Colors.green,
            size: 12,
          ),
        ),
      ),
    );
  }

  // /// Product header with name and favorite
  // Widget _buildProductHeader(
  //     BuildContext context, FavoriteManager favoriteManager) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Expanded(
  //         child: MultiLineTextDisplay(
  //           text: product.name,
  //           style: AppTextStyles.h4,
  //           thresholdLength: 20,
  //         ),
  //       ),
  //       // _buildFavoriteButton(context, favoriteManager),
  //     ],
  //   );
  // }

  /// Product header with name
  Widget _buildProductHeader(
      BuildContext context, FavoriteManager favoriteManager) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 12),
      child: Text(
        product.name,
        style: AppTextStyles.h4.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        softWrap: true,
        maxLines: null, // Let it take natural height
        overflow: TextOverflow.visible, // Allow text to be fully visible
      ),
    );
  }

  /// Favorite toggle button
  Widget _buildFavoriteButton(
      BuildContext context, FavoriteManager favoriteManager) {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(
        product.isFavorite ?? false ? Icons.favorite : Icons.favorite_border,
        color: product.isFavorite ?? false ? Colors.red : Colors.grey,
        size: 22,
      ),
      onPressed: () => favoriteManager.toggleFavorite(context, product),
    );
  }

  /// Product description
  Widget _buildProductDescription() {
    return Text(
      product.shortDesc!,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black54,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Price and cart controls section
  Widget _buildPriceAndCartControls(
    BuildContext context,
    CartManager cartManager,
    CartItem cartItem,
  ) {
    return SizedBox(
      height: 32, // Fixed height container
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '₹${product.unitprice}',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          cartItem.quantity == 0
              ? _buildAddButton(context, cartManager)
              : _buildQuantityControl(context, cartManager, cartItem),
        ],
      ),
    );
  }

  /// Add button
  Widget _buildAddButton(BuildContext context, CartManager cartManager) {
    return ElevatedButton(
      onPressed: () => _handleAddToCart(context, cartManager),
      style: _addButtonStyle(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'ADD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            ' +',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// Quantity control
  Widget _buildQuantityControl(
    BuildContext context,
    CartManager cartManager,
    CartItem cartItem,
  ) {
    return Container(
      height: 32, // Match ADD button height
      decoration: _quantityControlDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnimatedIconButton(
            Icons.remove,
            () {
              if (cartItem.quantity > 1) {
                cartManager.decrementCartItem(restaurantName, cartItem);
              } else {
                cartManager.removeFromCart(restaurantName, cartItem);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${cartItem.quantity}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
          _buildAnimatedIconButton(
            Icons.add,
            () => _handleAddToCart(context, cartManager),
          ),
        ],
      ),
    );
  }

  /// Animated icon button
  Widget _buildAnimatedIconButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }

  // BUSINESS LOGIC FUNCTIONS

  /// Find existing cart item
  CartItem _findCartItem(CartManager cartManager) {
    final defaultCartItem = CartItem(
      product: product,
      selectedAddons: {},
      quantity: 0,
      totalPrice: 0,
    );

    if (!cartManager.cartItemsByRestaurant.containsKey(restaurantName)) {
      return defaultCartItem;
    }

    try {
      return cartManager.cartItemsByRestaurant[restaurantName]!.firstWhere(
        (item) => item.product.productId == product.productId,
        orElse: () => defaultCartItem,
      );
    } catch (e) {
      AppLogger.logError('Error finding cart item: $e');
      return defaultCartItem;
    }
  }

  /// Handle adding to cart
  Future<void> _handleAddToCart(
      BuildContext context, CartManager cartManager) async {
    try {
      if (product.addOnGroups?.isNotEmpty ?? false) {
        await _handleProductWithAddons(context, cartManager);
      } else {
        _handleSimpleProduct(context, cartManager);
      }
    } catch (e) {
      _showSnackBar(context, 'Failed to add item to cart');
    }
  }

  /// Handle product with addons
  Future<void> _handleProductWithAddons(
      BuildContext context, CartManager cartManager) async {
    try {
      AppLogger.logInfo(
          '$TAG: Showing addons bottom sheet for: ${product.name}');

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        builder: (context) => AddonsBottomSheet(
          product: product,
          productName: product.name,
          productPrice: double.tryParse(product.unitprice) ?? 0.0,
          imageUrl: product.imageUrl,
          isVeg: product.veg == 'N' ? false : true,
          rating: 4.5,
          onAddToCart: (addons, quantity, totalPrice) {
            cartManager.addToCart(
              context,
              restaurantName,
              product,
              addons,
              quantity,
              totalPrice,
            );
            Navigator.pop(context);
          },
        ),
      );
    } catch (e) {
      AppLogger.logError('$TAG: Error showing addons bottom sheet: $e');
      _showError(context, 'Failed to show addons');
    }
  }

  /// Handle simple product
  void _handleSimpleProduct(BuildContext context, CartManager cartManager) {
    final basePrice = double.tryParse(product.unitprice) ?? 0.0;
    cartManager.addToCart(
      context,
      restaurantName,
      product,
      {},
      1,
      basePrice,
    );
  }

  /// Show snackbar message
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Show error message
  void _showError(BuildContext context, String message) {
    AppLogger.logWarning('$TAG: Showing error: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
