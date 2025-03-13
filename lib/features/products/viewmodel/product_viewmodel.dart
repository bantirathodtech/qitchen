// File: product_viewmodel.dart
import 'package:flutter/foundation.dart';

import '../model/product_model.dart';
import '../product_state.dart';
import '../repository/product_repository.dart';

class ProductViewModel extends ChangeNotifier {
  static const String TAG = '[ProductViewModel]';

  // Dependencies
  final ProductRepository _repository;
  final ProductsNotifier _state;

  ProductViewModel({
    required ProductRepository repository,
    required ProductsNotifier state,
  })  : _repository = repository,
        _state = state {
    // Listen to state changes and notify viewmodel listeners
    _state.addListener(_onStateChanged);
  }

  // Forward state getters
  bool get isLoading => _state.isLoading;
  String get error => _state.error;
  bool get isVegOnly => _state.isVegOnly;
  String get selectedMenu => _state.selectedMenu;
  String get selectedCategory => _state.selectedCategory;
  List<ProductModel> get products => _state.products;
  Map<String, List<ProductModel>> get productsByCategory =>
      _state.productsByCategory;
  Map<String, List<ProductModel>> get productsByMenu => _state.productsByMenu;

  // Business Logic Methods
  Future<void> fetchProducts(String storeId,
      {bool forceRefresh = false}) async {
    try {
      _state.setLoading(true);
      _state.setError('');

      final products =
          await _repository.getProducts(storeId, forceRefresh: forceRefresh);
      _state.updateProducts(products);
    } catch (e) {
      _state.setError('Failed to fetch products: $e');
    } finally {
      _state.setLoading(false);
    }
  }

  // Filter Methods
  void toggleVegFilter(bool value) => _state.setVegFilter(value);
  void setSelectedMenu(String menu) => _state.setSelectedMenu(menu);
  void setSelectedCategory(String category) =>
      _state.setSelectedCategory(category);
  void resetFilters() => _state.resetFilters();

  // Data Access Methods
  List<String> getAllCategories() => _state.getCategories();
  List<String> getAllMenus() => _state.getMenus();
  List<ProductModel> getFilteredProducts() => _state.getFilteredProducts();
  List<ProductModel> searchProducts(String query) =>
      _state.searchProducts(query);

  // State change listener
  void _onStateChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    super.dispose();
  }
}

// // File: product_viewmodel.dart
//
// import 'package:flutter/foundation.dart';
//
// import '../../../../common/log/loggers.dart';
// import '../../store/provider/store_provider.dart';
// import '../model/product_model.dart';
// import '../repository/product_repository.dart';
//
// class ProductViewModel extends ChangeNotifier {
//   static const String TAG = '[ProductViewModel]';
//
//   // Dependencies
//   final ProductRepository _repository;
//   final StoreProvider _storeProvider;
//
//   // State variables
//   List<ProductModel>? _products;
//   bool _isLoading = false;
//   String _error = '';
//   bool _isVegOnly = false;
//   // String? _selectedMenu;
//   // Map<String, List<ProductModel>> _categorizedProducts = {};
//   String _selectedMenu = "All"; // Default menu selection is "All"
//   String _selectedCategory = "All"; // Default category selection is "All"
//   DateTime? _lastFetchTime;
//
//   // Constructor
//   ProductViewModel({
//     required ProductRepository repository,
//     required StoreProvider storeProvider,
//   })  : _repository = repository,
//         _storeProvider = storeProvider {
//     AppLogger.logInfo('$TAG: Initializing ProductViewModel');
//     _initializeState();
//   }
//
//   // Getters
//   List<ProductModel>? get products => _products;
//   bool get isLoading => _isLoading;
//   String get error => _error;
//   bool get isVegOnly => _isVegOnly;
//   String? get selectedMenu => _selectedMenu;
//   String get selectedCategory => _selectedCategory;
//
//   // Get all menus including "All" (for top filter)
//   List<String> getAllMenus() {
//     if (_products == null || _products!.isEmpty) {
//       return ["All"];
//     }
//
//     Set<String> uniqueMenus = _products!
//         .where((p) => p.menuName != null && p.menuName!.isNotEmpty)
//         .map((p) => p.menuName!)
//         .toSet();
//
//     List<String> menuList = ["All", ...uniqueMenus.toList()];
//     AppLogger.logDebug('$TAG: Available menus: $menuList');
//     return menuList;
//   }
//
//   // Get all categories including "All" (for tabs)
//   List<String> getAllCategories() {
//     if (_products == null || _products!.isEmpty) {
//       return ["All"];
//     }
//
//     Set<String> uniqueCategories = _products!
//         .where((p) => p.categoryName != null && p.categoryName!.isNotEmpty)
//         .map((p) => p.categoryName!)
//         .toSet();
//
//     List<String> categoryList = ["All", ...uniqueCategories.toList()];
//     AppLogger.logDebug('$TAG: Available categories: $categoryList');
//     return categoryList;
//   }
//
//   // Get filtered products based on menu and category selection
//   List<ProductModel> getFilteredProducts() {
//     if (_products == null) return [];
//
//     return _products!.where((product) {
//       // Apply veg filter
//       if (_isVegOnly && product.veg.toLowerCase() != 'y') {
//         return false;
//       }
//
//       // Apply menu filter
//       if (_selectedMenu != "All") {
//         if (product.menuName != _selectedMenu) {
//           return false;
//         }
//       }
//
//       // Apply category filter
//       if (_selectedCategory != "All") {
//         if (product.categoryName != _selectedCategory) {
//           return false;
//         }
//       }
//
//       return true;
//     }).toList();
//   }
//
//   // Set selected menu (for top filter)
//   void setSelectedMenu(String menu) {
//     AppLogger.logInfo('$TAG: Setting selected menu to: $menu');
//     _selectedMenu = menu;
//     notifyListeners();
//   }
//
//   // Set selected category (for tabs)
//   void setSelectedCategory(String category) {
//     AppLogger.logInfo('$TAG: Setting selected category to: $category');
//     _selectedCategory = category;
//     notifyListeners();
//   }
//
//   // Toggle veg filter
//   void toggleVegFilter(bool value) {
//     AppLogger.logInfo('$TAG: Toggling veg filter: $value');
//     _isVegOnly = value;
//     notifyListeners();
//   }
//
//   // Reset all filters
//   void resetFilters() {
//     _selectedMenu = "All";
//     _selectedCategory = "All";
//     _isVegOnly = false;
//     notifyListeners();
//   }
//
//   // Fetch products
//   Future<void> fetchProducts(String storeId,
//       {bool forceRefresh = false}) async {
//     try {
//       _setLoading(true);
//       _clearError();
//
//       final products =
//           await _repository.getProducts(storeId, forceRefresh: forceRefresh);
//       _products = products;
//       _lastFetchTime = DateTime.now();
//
//       AppLogger.logInfo(
//           '$TAG: Successfully fetched ${products.length} products');
//     } catch (e) {
//       _handleError('Failed to fetch products', e);
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Add to ProductViewModel
//   // In ProductViewModel, update the searchProducts method
//   List<ProductModel> searchProducts(String query) {
//     if (_products == null) return [];
//
//     if (query.isEmpty) {
//       notifyListeners();
//       return [];
//     }
//
//     final searchQuery = query.toLowerCase();
//     final results = _products!.where((product) {
//       final name = product.name.toLowerCase();
//       final description = product.shortDesc?.toLowerCase() ?? '';
//       return name.contains(searchQuery) || description.contains(searchQuery);
//     }).toList();
//
//     notifyListeners();
//     return results;
//   }
//
//   /// Initialize the view model state
//   void _initializeState() {
//     AppLogger.logDebug('$TAG: Initializing state');
//     _selectedMenu = "All";
//     _selectedCategory = "All";
//     _lastFetchTime = null;
//   }
//
//   /// Set loading state
//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }
//
//   /// Clear error state
//   void _clearError() {
//     _error = '';
//   }
//
//   /// Handle and log errors
//   void _handleError(String context, Object error) {
//     final message = '$context: $error';
//     AppLogger.logError('$TAG: $message');
//     _error = message;
//     notifyListeners();
//   }
//
//   /// Cleanup resources
// // @override
// // void dispose() {
// //   AppLogger.logInfo('$TAG: Disposing ProductViewModel');
// //   _products = null;
// //   _categorizedProducts.clear();
// //   super.dispose();
// // }
// }
