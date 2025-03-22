import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../favorite/favorite_manager.dart';
import '../../home/cart/models/cart_item.dart';
import '../../home/cart/multiple/cart_manager.dart';
import '../model/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  static const String TAG = "ProductDetailScreen";
  final ProductModel product;
  final String restaurantName;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.restaurantName,
    required this.onBackPressed,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onBackPressed(); // Call the provided callback
        Navigator.pop(context); // Ensure pop happens regardless of callback
        return false; // Prevent default pop since we handle it manually
      },
      child: Scaffold(
        appBar: CustomAppBar(
          logoPath: 'assets/images/cw_image.png',
          onBackPressed: () {
            widget.onBackPressed(); // Call the provided callback
            Navigator.pop(context); // Ensure pop happens
          },
        ),
      // appBar: AppBar(
      //   // backgroundColor: Colors.white,
      //   title: Text(product.name),
      //   actions: [
      //     Consumer<FavoriteManager>(
      //       builder: (context, favoriteManager, _) => IconButton(
      //         icon: Icon(
      //           product.isFavorite ?? false ? Icons.favorite : Icons.favorite_border,
      //           color: product.isFavorite ?? false ? Colors.red : Colors.grey,
      //         ),
      //         onPressed: () => favoriteManager.toggleFavorite(context, product),
      //       ),
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            _buildImage(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Veg Indicator
                  Row(
                    children: [
                      _buildVegIndicator(),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Consumer<FavoriteManager>(
                        builder: (context, favoriteManager, _) => IconButton(
                          icon: Icon(
                            widget.product.isFavorite ?? false ? Icons.favorite : Icons.favorite_border,
                            color: widget.product.isFavorite ?? false ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => favoriteManager.toggleFavorite(context, widget.product),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Price
                  Row(
                    children: [
                      Text(
                        '₹${widget.product.unitprice ?? '0'}', // Default to '0' if null
                        style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if ((widget.product.listprice ?? '0') != (widget.product.unitprice ?? '0')) ...[
                        const SizedBox(width: 8),
                        Text(
                          '₹${widget.product.listprice ?? '0'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    widget.product.shortDesc?.isNotEmpty == true ? widget.product.shortDesc! : 'No description available.',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // Additional Details
                  _buildDetailRow('Category', widget.product.categoryName ?? 'Uncategorized'),
                  _buildDetailRow('SKU', widget.product.sku ?? 'N/A'),
                  _buildDetailRow('Best Seller', widget.product.bestseller == 'Y' ? 'Yes' : 'No'),
                  if (widget.product.availableStartTime != null && widget.product.availableEndTime != null)
                    _buildDetailRow(
                      'Available Time',
                      '${widget.product.availableStartTime} - ${widget.product.availableEndTime}',
                    ),
                  const SizedBox(height: 16),
                  // Tax Details
                  if (widget.product.taxCategories?.isNotEmpty == true) ...[
                    const Text(
                      'Tax Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...widget.product.taxCategories!.map((tax) => _buildDetailRow(tax.name, '${tax.taxRate}%')),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Hero(
      tag: 'product-${widget.product.productId}',
      child: widget.product.imageUrl?.isNotEmpty == true
          ? Image.network(
        widget.product.imageUrl!,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _defaultImage(),
      )
          : _defaultImage(),
    );
  }

  Widget _defaultImage() {
    return Container(
      height: 250,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, size: 50),
    );
  }

  Widget _buildVegIndicator() {
    final isVeg = (widget.product.veg ?? 'N').toLowerCase() == 'y';
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(color: isVeg ? Colors.green : Colors.red),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.circle,
          size: 12,
          color: isVeg ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Consumer<CartManager>(
      builder: (context, cartManager, _) {
        final cartItem = cartManager.cartItemsByRestaurant[widget.restaurantName]?.firstWhere(
              (item) => item.product.productId == widget.product.productId,
          orElse: () => CartItem(
            product: widget.product,
            selectedAddons: {},
            quantity: 0,
            totalPrice: 0,
          ),
        ) ??
            CartItem(
              product: widget.product,
              selectedAddons: {},
              quantity: 0,
              totalPrice: 0,
            );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)],
          ),
          child: cartItem.quantity == 0
              ? ElevatedButton(
            onPressed: () {
              final price = double.tryParse(widget.product.unitprice ?? '0') ?? 0.0;
              cartManager.addToCart(context, widget.restaurantName, widget.product, {}, 1, price);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Add to Cart', style: TextStyle(fontSize: 16, color: Colors.white)),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.green),
                onPressed: () => cartManager.decrementCartItem(widget.restaurantName, cartItem),
              ),
              const SizedBox(width: 16),
              Text(
                '${cartItem.quantity}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () {
                  final price = double.tryParse(widget.product.unitprice ?? '0') ?? 0.0;
                  cartManager.addToCart(context, widget.restaurantName, widget.product, {}, 1, price);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}