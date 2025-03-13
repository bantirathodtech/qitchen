// File: product_state.dart
import 'package:flutter/foundation.dart';

import 'model/product_model.dart';

class ProductsNotifier extends ChangeNotifier {
  static const String TAG = '[ProductsNotifier]';

  // State Variables
  List<ProductModel> _products = [];
  Map<String, List<ProductModel>> _productsByCategory = {};
  Map<String, List<ProductModel>> _productsByMenu = {};
  bool _isVegOnly = false;
  String _selectedMenu = "All";
  String _selectedCategory = "All";
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<ProductModel> get products => _products;
  Map<String, List<ProductModel>> get productsByCategory => _productsByCategory;
  Map<String, List<ProductModel>> get productsByMenu => _productsByMenu;
  bool get isVegOnly => _isVegOnly;
  String get selectedMenu => _selectedMenu;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String get error => _error;

  // State Updates
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String value) {
    _error = value;
    notifyListeners();
  }

  void updateProducts(List<ProductModel> newProducts) {
    _products = newProducts;
    _organizeProducts();
    notifyListeners();
  }

  void setVegFilter(bool value) {
    _isVegOnly = value;
    notifyListeners();
  }

  void setSelectedMenu(String menu) {
    _selectedMenu = menu;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void resetFilters() {
    _isVegOnly = false;
    _selectedMenu = "All";
    _selectedCategory = "All";
    notifyListeners();
  }

  // Data Organization
  void _organizeProducts() {
    _organizeByCategory();
    _organizeByMenu();
  }

  void _organizeByCategory() {
    _productsByCategory = {};
    for (var product in _products) {
      final category = product.categoryName ?? 'Uncategorized';
      _productsByCategory.putIfAbsent(category, () => []).add(product);
    }
  }

  void _organizeByMenu() {
    _productsByMenu = {};
    for (var product in _products) {
      final menu = product.menuName ?? 'Default Menu';
      _productsByMenu.putIfAbsent(menu, () => []).add(product);
    }
  }

  // Data Access Methods
  List<ProductModel> getFilteredProducts() {
    return _products.where((product) {
      if (_isVegOnly && product.veg.toLowerCase() != 'y') return false;
      if (_selectedMenu != "All" && product.menuName != _selectedMenu)
        return false;
      if (_selectedCategory != "All" &&
          product.categoryName != _selectedCategory) return false;
      return true;
    }).toList();
  }

  List<String> getCategories() {
    Set<String> categories = _products
        .where((p) => p.categoryName != null)
        .map((p) => p.categoryName!)
        .toSet();
    return ["All", ...categories];
  }

  List<String> getMenus() {
    Set<String> menus = _products
        .where((p) => p.menuName != null)
        .map((p) => p.menuName!)
        .toSet();
    return ["All", ...menus];
  }

  List<ProductModel> searchProducts(String query) {
    if (query.isEmpty) return [];

    final searchQuery = query.toLowerCase();
    return _products.where((product) {
      final name = product.name.toLowerCase();
      final description = product.shortDesc?.toLowerCase() ?? '';
      return name.contains(searchQuery) || description.contains(searchQuery);
    }).toList();
  }
}

// // product_state.dart
//
// import 'package:flutter/foundation.dart';
//
// import 'model/product_model.dart';
//
// /// Notifier for managing product-related state updates
// class ProductsNotifier extends ChangeNotifier {
//   static const String TAG = '[ProductsNotifier]';
//
//   List<ProductModel> _products = [];
//   Map<String, List<ProductModel>> _productsByCategory = {};
//   Map<String, List<ProductModel>> _productsByMenu = {};
//
// // Getters
//   List<ProductModel> get products => _products;
//
//   Map<String, List<ProductModel>> get productsByCategory => _productsByCategory;
//
//   Map<String, List<ProductModel>> get productsByMenu => _productsByMenu;
//
//   /// Update products list and reorganize by category and menu
//   void updateProducts(List<ProductModel> newProducts) {
//     _products = newProducts;
//     _organizeProducts();
//     notifyListeners();
//   }
//
//   void _organizeProducts() {
// // Organize by category
//     _productsByCategory = {};
//     for (var product in _products) {
//       final category = product.categoryName ?? 'Uncategorized';
//       _productsByCategory.putIfAbsent(category, () => []).add(product);
//     }
//
// // Organize by menu
//     _productsByMenu = {};
//     for (var product in _products) {
//       final menu = product.menuName ?? 'Default Menu';
//       _productsByMenu.putIfAbsent(menu, () => []).add(product);
//     }
//   }
// }
