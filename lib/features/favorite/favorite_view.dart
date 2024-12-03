// favorite_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/custom_app_bar.dart';
import '../products/widgets/product_card.dart';
import 'favorite_manager.dart';

class FavoriteView extends StatelessWidget {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        logoPath: 'assets/images/cw_image.png',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Consumer<FavoriteManager>(
        builder: (context, favoriteManager, child) {
          final favorites = favoriteManager.favorites;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Products you favorite will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final product = favorites[index];
              final storeInfo =
                  favoriteManager.getProductStoreInfo(product.productId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ProductCard(
                  product: product,
                  restaurantName:
                      storeInfo['restaurantName'] ?? 'Unknown Restaurant',
                  csBunitId: storeInfo['csBunitId'] ?? '',
                  onTap: () {}, // Handle product tap if needed
                ),
              );
            },
          );
        },
      ),
    );
  }
}
