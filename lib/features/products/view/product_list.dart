import 'package:cw_food_ordering/features/products/view/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/log/loggers.dart';
import '../../store/provider/store_provider.dart';
import '../model/product_model.dart';
import '../widgets/product_card.dart';

class ProductList extends StatelessWidget {
  static const String TAG = '[ProductList]';

  final List<ProductModel> products; // List of products from ViewModel
  final String restaurantName; // Restaurant name for context
  final Function(ProductModel) onProductSelected; // Callback for product selection

  const ProductList({
    super.key,
    required this.products,
    required this.restaurantName,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Step 1: Log build initiation
    AppLogger.logInfo('$TAG: Building product list for $restaurantName');
    AppLogger.logDebug('$TAG: Total products: ${products.length}');

    // Step 2: Use StoreProvider for business unit context
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, _) {
        AppLogger.logDebug('$TAG: BusinessUnitId: ${storeProvider.businessUnitId}');

        // Step 3: Handle empty product list
        if (products.isEmpty) {
          AppLogger.logInfo('$TAG: No products to display');
          return const Center(
            child: Text(
              'No products available',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          );
        }

        // Step 4: Build scrollable product list
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 0),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              AppLogger.logDebug('$TAG: Building card for ${product.name} at index $index');

              return Column(
                children: [
                  ProductCard(
                    key: ValueKey(product.productId),
                    product: product,
                    restaurantName: restaurantName,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          product: product,
                          restaurantName: restaurantName, onBackPressed: () {  },
                        ),
                      ),
                    ),
                  ),
                  if (index < products.length - 1) const SizedBox(height: 12),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// // File: product_list.dart
// import 'package:cw_food_ordering/features/products/view/product_detail_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../common/log/loggers.dart';
// import '../../store/provider/store_provider.dart';
// import '../model/product_model.dart';
// import '../widgets/product_card.dart';
//
// /// ProductList: Displays a scrollable list of products with consistent store information
// /// - Uses StoreProvider for business unit validation
// /// - Handles product display and selection
// /// - Manages product card creation and callbacks
// class ProductList extends StatelessWidget {
//   static const String TAG = '[ProductList]';
//
//   // Core properties
//   final List<ProductModel> products;
//   final String restaurantName;
//   final Function(ProductModel) onProductSelected;
//
//   const ProductList({
//     super.key,
//     required this.products,
//     required this.restaurantName,
//     required this.onProductSelected,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Log initial build
//     AppLogger.logInfo(
//         '$TAG: Building product list for restaurant: $restaurantName');
//     AppLogger.logDebug('$TAG: Total products to display: ${products.length}');
//
//     return Consumer<StoreProvider>(
//       builder: (context, storeProvider, _) {
//         // Log current store context
//         AppLogger.logDebug(
//             '$TAG: Current businessUnitId from StoreProvider: ${storeProvider.businessUnitId}');
//
//         if (products.isEmpty) {
//           AppLogger.logInfo('$TAG: No products available to display');
//           return const Center(
//             child: Text(
//               'No products available',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey,
//               ),
//             ),
//           );
//         }
//
//         // Build the product list
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: ListView.builder(
//             physics: const AlwaysScrollableScrollPhysics(),
//             itemCount: products.length,
//             itemBuilder: (context, index) {
//               final product = products[index];
//
//               // Log product card creation
//               AppLogger.logDebug(
//                   '$TAG: Building product card for: ${product.name} at index: $index');
//
//               return Column(
//                 children: [
//                   // ProductCard(
//                   //   key: ValueKey(product.productId),
//                   //   product: product,
//                   //   restaurantName: restaurantName,
//                   //   onTap: () => _handleProductSelection(
//                   //       context, product, storeProvider),
//                   //   csBunitId: '',
//                   // ),
//                   ProductCard(
//                     key: ValueKey(product.productId),
//                     product: product,
//                     restaurantName: restaurantName,
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ProductDetailScreen(
//                           product: product,
//                           restaurantName: restaurantName,
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Add spacing between cards
//                   if (index < products.length - 1) const SizedBox(height: 12),
//                 ],
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   /// Handles the selection of a product
//   /// Validates the selection against the current store context
//   /// Triggers the onProductSelected callback if validation passes
//   void _handleProductSelection(
//     BuildContext context,
//     ProductModel product,
//     StoreProvider storeProvider,
//   ) {
//     AppLogger.logInfo('$TAG: Product selected: ${product.name}');
//     AppLogger.logDebug(
//         '$TAG: Validating selection against businessUnitId: ${storeProvider.businessUnitId}');
//
//     try {
//       // Validate product selection
//       if (!_validateProductSelection(product, storeProvider)) {
//         AppLogger.logWarning('$TAG: Product selection validation failed');
//         _showError(
//             context, 'Unable to select product from different restaurant');
//         return;
//       }
//
//       // Trigger selection callback
//       AppLogger.logInfo(
//           '$TAG: Product selection validated, triggering callback');
//       onProductSelected(product);
//     } catch (e) {
//       AppLogger.logError('$TAG: Error handling product selection: $e');
//       _showError(context, 'Error selecting product');
//     }
//   }
//
//   /// Validates that the product belongs to the current store context
//   bool _validateProductSelection(
//     ProductModel product,
//     StoreProvider storeProvider,
//   ) {
//     AppLogger.logDebug(
//         '$TAG: Validating product: ${product.productId} for restaurant: $restaurantName');
//
//     // Add any specific validation logic here
//     return true; // Basic validation - expand based on your needs
//   }
//
//   /// Shows error message to user
//   void _showError(BuildContext context, String message) {
//     AppLogger.logWarning('$TAG: Showing error message: $message');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
// }
