// import 'package:flutter/foundation.dart';
//
// import '../5. products/model/product_model.dart';
//
// class FavoriteViewModel extends ChangeNotifier {
//   final Map<String, ProductModel> _favorites = {};
//
//   List<ProductModel> get favorites => _favorites.values.toList();
//
//   void toggleFavorite(ProductModel product) {
//     if (_favorites.containsKey(product.productId)) {
//       _favorites.remove(product.productId);
//     } else {
//       _favorites[product.productId] = product.copyWith(isFavorite: true);
//     }
//     notifyListeners();
//   }
//
//   bool isFavorite(String productId) {
//     return _favorites.containsKey(productId);
//   }
//
//   void addToFavorites(ProductModel product) {
//     if (!_favorites.containsKey(product.productId)) {
//       _favorites[product.productId] = product.copyWith(isFavorite: true);
//       notifyListeners();
//     }
//   }
//
//   void removeFromFavorites(String productId) {
//     if (_favorites.containsKey(productId)) {
//       _favorites.remove(productId);
//       notifyListeners();
//     }
//   }
// }
