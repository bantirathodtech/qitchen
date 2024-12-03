// favorite_manager.dart
import 'package:flutter/material.dart';

import '../products/model/product_model.dart';
import '../store/provider/store_provider.dart';

class FavoriteManager extends ChangeNotifier {
  final List<ProductModel> _favorites = [];
  final StoreProvider _storeProvider;
  final Map<String, Map<String, String>> _productStoreInfo = {};

  FavoriteManager(this._storeProvider);

  List<ProductModel> get favorites => _favorites;

  Future<bool> showConfirmationDialog(
      BuildContext context, bool isAdding, String productName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              isAdding ? 'Add to Favorites' : 'Remove from Favorites',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              isAdding
                  ? 'Do you want to add "$productName" to your favorites?'
                  : 'Do you want to remove "$productName" from your favorites?',
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text(
                  isAdding ? 'Add' : 'Remove',
                  style: TextStyle(
                    color: isAdding ? Colors.blue : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> toggleFavorite(
      BuildContext context, ProductModel product) async {
    final isCurrentlyFavorite = product.isFavorite ?? false;
    final confirmed = await showConfirmationDialog(
        context, !isCurrentlyFavorite, product.name);

    if (confirmed) {
      // Update the UI state
      product.isFavorite = !isCurrentlyFavorite;

      final existingIndex =
          _favorites.indexWhere((p) => p.productId == product.productId);

      if (existingIndex != -1) {
        // Remove from favorites
        _favorites.removeAt(existingIndex);
        _productStoreInfo.remove(product.productId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} removed from favorites'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Add to favorites
        final storeDetails = _storeProvider.activeStoreDetails;
        _productStoreInfo[product.productId] = storeDetails;
        _favorites.insert(0, product);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to favorites'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      notifyListeners();
    }
  }

  bool isFavorite(String productId) {
    return _favorites.any((product) => product.productId == productId);
  }

  void addToFavorites(ProductModel product) {
    if (!isFavorite(product.productId)) {
      _favorites.insert(0, product);
      product.isFavorite = true;
      final storeDetails = _storeProvider.activeStoreDetails;
      _productStoreInfo[product.productId] = storeDetails;
      notifyListeners();
    }
  }

  void removeFromFavorites(String productId) {
    final index =
        _favorites.indexWhere((product) => product.productId == productId);
    if (index != -1) {
      _favorites[index].isFavorite = false;
      _favorites.removeAt(index);
      _productStoreInfo.remove(productId);
      notifyListeners();
    }
  }

  Map<String, String> getProductStoreInfo(String productId) {
    return _productStoreInfo[productId] ??
        {
          'restaurantName': 'Unknown Restaurant',
          'csBunitId': '',
          'storeId': '',
        };
  }
}
