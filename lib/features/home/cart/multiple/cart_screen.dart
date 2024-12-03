import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/log/loggers.dart';
import '../../../../common/styles/ElevatedButton.dart';
import '../../../../common/styles/app_text_styles.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../order/payment_screen.dart';
import '../../../store/provider/store_provider.dart';
import '../models/cart_item.dart';
import 'cart_manager.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback onBackPressed;
  static const String TAG = "CartScreen";

  const CartScreen({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        onBackPressed();
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          logoPath: 'assets/images/cw_image.png',
          onBackPressed: onBackPressed,
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer2<StoreProvider, CartManager>(
      builder: (context, storeProvider, cartManager, _) {
        final cartItemsByRestaurant = cartManager.cartItemsByRestaurant;

        // Debug logging for Restaurant Info
        AppLogger.logInfo('$TAG: Cart Restaurant Info:');
        AppLogger.logInfo(
            '$TAG: Cart Items By Restaurant: ${cartItemsByRestaurant.keys.join(', ')}');
        AppLogger.logInfo('$TAG: Store Provider Restaurants:');
        storeProvider.storeData?.restaurants.forEach((r) {
          AppLogger.logInfo(
              '$TAG: - ${r.name} (ID: ${r.storeId}, CSBunit: ${r.businessUnit.name})');
        });

        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              child: cartItemsByRestaurant.isNotEmpty
                  ? _buildCartWithItems(
                      context, cartManager, cartItemsByRestaurant)
                  : _buildEmptyCartUI(),
            ),
            _buildNextButtonPosition(context, storeProvider, cartManager),
          ],
        );
      },
    );
  }

  Widget _buildCartWithItems(
    BuildContext context,
    CartManager cartManager,
    Map<String, List<CartItem>> cartItemsByRestaurant,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...cartItemsByRestaurant.entries
              .map((entry) => _buildRestaurantSection(
                    context,
                    cartManager,
                    entry.key,
                    entry.value,
                  )),
          const SizedBox(height: 16),
          // _buildLoyaltyPoints(),
          const SizedBox(height: 16),
          _buildBillDetails(cartManager),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildRestaurantSection(
    BuildContext context,
    CartManager cartManager,
    String restaurantName,
    List<CartItem> cartItems,
  ) {
    return Column(
      children: [
        _buildRestaurantHeader(restaurantName),
        const SizedBox(height: 16),
        ...cartItems.map((item) => Column(
              children: [
                _buildCartItem(context, cartManager, restaurantName, item),
                const SizedBox(height: 6),
              ],
            )),
      ],
    );
  }

  Widget _buildRestaurantHeader(String restaurantName) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Card(
        color: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                restaurantName,
                style: AppTextStyles.h5,
                textAlign: TextAlign.center,
              ),
              Text(
                'Biryani . Tandoor . Kebabs',
                style: AppTextStyles.h6,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartManager cartManager,
    String restaurantName,
    CartItem cartItem,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cartItem.product.name, style: AppTextStyles.h5b),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              _buildQuantityControl(
                  context, cartManager, restaurantName, cartItem),
              SizedBox(
                width: 80,
                child: Text(
                  '₹${cartItem.totalPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.h5b,
                ),
              ),
            ],
          ),
          if (cartItem.selectedAddons.isNotEmpty) _buildAddonsList(cartItem),
          _buildNotesField(context, cartManager, restaurantName, cartItem),
        ],
      ),
    );
  }

  // Add new method for notes field
  Widget _buildNotesField(
    BuildContext context,
    CartManager cartManager,
    String restaurantName,
    CartItem cartItem,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.note_add_outlined, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => _showNotesDialog(
                context,
                cartManager,
                restaurantName,
                cartItem,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  cartItem.specialInstructions?.isNotEmpty == true
                      ? cartItem.specialInstructions!
                      : 'Add Notes',
                  style: TextStyle(
                    color: cartItem.specialInstructions?.isNotEmpty == true
                        ? Colors.black87
                        : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => _showNotesDialog(
              context,
              cartManager,
              restaurantName,
              cartItem,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotesDialog(
    BuildContext context,
    CartManager cartManager,
    String restaurantName,
    CartItem cartItem,
  ) {
    final notesController =
        TextEditingController(text: cartItem.specialInstructions);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Special Instructions'),
        content: TextField(
          controller: notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter any special instructions or notes...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cartManager.updateItemNotes(
                restaurantName,
                cartItem,
                notesController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(
    BuildContext context,
    CartManager cartManager,
    String restaurantName,
    CartItem cartItem,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          iconSize: 16,
          onPressed: () =>
              cartManager.decrementCartItem(restaurantName, cartItem),
        ),
        Text('${cartItem.quantity}'),
        IconButton(
          icon: const Icon(Icons.add),
          iconSize: 16,
          onPressed: () =>
              cartManager.incrementCartItem(restaurantName, cartItem),
        ),
      ],
    );
  }

  Widget _buildAddonsList(CartItem cartItem) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cartItem.selectedAddons.entries
            .expand(
              (entry) => entry.value.map(
                (addon) => Text(
                  '• ${addon.name}',
                  style: AppTextStyles.smallText,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildLoyaltyPoints() {
    return Row(
      children: [
        Checkbox(
          value: true,
          onChanged: (value) {},
        ),
        const Text('Loyalty Points'),
        const Spacer(),
        const Text('-₹8'),
      ],
    );
  }

  Widget _buildBillDetails(CartManager cartManager) {
    final taxes = cartManager.getTotalTaxesByCategory();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bill Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildBillRow('Subtotal', cartManager.subtotal),
          ...taxes.entries.map(
            (entry) => _buildBillRow(entry.key, entry.value),
          ),
          const Divider(),
          _buildBillRow('Total', cartManager.total, isBold: true),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, num amount, {bool isBold = false}) {
    final textStyle = isBold ? AppTextStyles.h5 : AppTextStyles.h6;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: textStyle,
          ),
        ],
      ),
    );
  }

// Update the position widget to pass required parameters
  Widget _buildNextButtonPosition(BuildContext context,
      StoreProvider storeProvider, CartManager cartManager) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: _buildNextButton(context, storeProvider, cartManager),
    );
  }

// Update the next button to handle both providers
  Widget _buildNextButton(BuildContext context, StoreProvider storeProvider,
      CartManager cartManager) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
      child: CustomElevatedButton(
        onPressed: () =>
            _navigateToPayment(context, storeProvider, cartManager),
        color: Colors.deepOrangeAccent,
        text: 'Next',
      ),
    );
  }

  // lib/features/home/cart/multiple/cart_screen.dart
  void _navigateToPayment(BuildContext context, StoreProvider storeProvider,
      CartManager cartManager) {
    try {
      if (cartManager.cartItemsByRestaurant.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart is empty')),
        );
        return;
      }

      final firstRestaurant = cartManager.cartItemsByRestaurant.entries.first;
      final cartRestaurantName = firstRestaurant.key;

      // Find restaurant using exact name match with store config
      final matchingRestaurant =
          storeProvider.storeData?.restaurants.firstWhere(
        (r) => r.name == cartRestaurantName,
        orElse: () => throw Exception('Restaurant not found'),
      );

      final businessUnitId = matchingRestaurant?.businessUnit.csBunitId;

      // Validate business unit
      if (businessUnitId == null || businessUnitId.isEmpty) {
        throw Exception('Invalid business unit ID');
      }

      // Navigate to payment
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            totalAmount: cartManager.total.toDouble(),
            businessUnitId: businessUnitId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to proceed with payment: $e')),
      );
    }
  }

  // Widget _buildEmptyCartUI() {
  //   return const Center(
  //     child: Text('Your cart is empty'),
  //   );
  // }
  Widget _buildEmptyCartUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty cart illustration/icon with 3D effect
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 24,
              color: Colors.blue.shade300,
            ),
          ),
          const SizedBox(height: 24),

          // Main message
          Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),

          // Supportive text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Looks like you haven\'t added anything to your cart yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Call to action button
          ElevatedButton(
            onPressed: () {
              // Navigate to menu/products screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade400,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                ),
                // const SizedBox(width: 8),
                // const Text(
                //   'Browse Menu',
                //   style: TextStyle(
                //     fontSize: 16,
                //     color: Colors.white,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
              ],
            ),
          ),

          // Optional: Add quick category chips
          // const SizedBox(height: 24),
          // SingleChildScrollView(
          //   scrollDirection: Axis.horizontal,
          //   padding: const EdgeInsets.symmetric(horizontal: 20),
          //   child: Row(
          //     children: [
          //       _buildQuickCategoryChip('Popular'),
          //       _buildQuickCategoryChip('Today\'s Special'),
          //       _buildQuickCategoryChip('Recommended'),
          //       _buildQuickCategoryChip('Trending'),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildQuickCategoryChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        labelStyle: TextStyle(
          color: Colors.blue.shade700,
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: Colors.blue.shade50,
        side: BorderSide(
          color: Colors.blue.shade100,
        ),
        onPressed: () {
          // Navigate to specific category
        },
      ),
    );
  }

// Optional: Add this animation when the cart becomes empty
  Widget _buildEmptyCartUIWithAnimation() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildEmptyCartUI(),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
    );
  }
}
