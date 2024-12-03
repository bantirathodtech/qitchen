// File: product_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/log/loggers.dart';
import '../../addon/addons_screen.dart';
import '../../home/cart/multiple/cart_manager.dart';
import '../../home/error_display.dart';
import '../../home/loading_indicator.dart';
import '../../home/restaurant_info.dart';
import '../../store/provider/store_provider.dart';
import '../model/product_model.dart';
import '../view/product_list.dart';
import '../viewmodel/product_viewmodel.dart';
import '../widgets/dynamic_tabs.dart';
import 'product_filters.dart';

/// ProductScreen: Main screen for displaying products with filtering and category tabs
class ProductScreen extends StatefulWidget {
  static const String TAG = '[ProductScreen]';

// Required parameters for restaurant/store information
  final String storeId;
  final String storeImage;
  final String restaurantName;
  final bool isOpen;
  final String displayTiming;
  final String? shortDescription;

  const ProductScreen({
    super.key,
    required this.storeId,
    required this.storeImage,
    required this.restaurantName,
    required this.isOpen,
    required this.displayTiming,
    this.shortDescription,
    required String csBunitId,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  static const String TAG = '[ProductScreen]';

// Controllers
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    AppLogger.logInfo(
        '$TAG: Initializing ProductScreen for ${widget.restaurantName}');
    _initializeScreen();
  }

  /// Initialize screen data and listeners
  void _initializeScreen() async {
    AppLogger.logInfo('$TAG: Loading initial data');
    await _loadProducts();
    _initializeScrollListener();
  }

  /// Load initial products data
  Future<void> _loadProducts() async {
    try {
      AppLogger.logInfo('$TAG: Loading products for store: ${widget.storeId}');
      await context.read<ProductViewModel>().fetchProducts(widget.storeId);
    } catch (e) {
      AppLogger.logError('$TAG: Error loading products: $e');
      _showError('Failed to load products');
    }
  }

  /// Initialize scroll behavior
  void _initializeScrollListener() {
    AppLogger.logDebug('$TAG: Initializing scroll listener');
    _scrollController.addListener(() {
// Add scroll-based behaviors here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<StoreProvider, ProductViewModel>(
      builder: (context, storeProvider, viewModel, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: _buildMainContent(storeProvider, viewModel),
        );
      },
    );
  }

  /// Build main screen content
  Widget _buildMainContent(
      StoreProvider storeProvider, ProductViewModel viewModel) {
    if (viewModel.isLoading) {
      return const LoadingIndicator();
    }

    if (viewModel.error.isNotEmpty) {
      return ErrorDisplay(
        error: viewModel.error,
        onRetry: _loadProducts,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _handleRefresh(viewModel),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          // _buildHeader(storeProvider),
          _buildFilters(viewModel),
          _buildCategoryTabs(viewModel),
        ],
      ),
    );
  }

  // /// Build app bar with restaurant image
  // Widget _buildAppBar() {
  //   return SliverAppBar(
  //     automaticallyImplyLeading: false,
  //     floating: true,
  //     pinned: false,
  //     expandedHeight: 200,
  //     flexibleSpace: FlexibleSpaceBar(
  //       background: Container(
  //         decoration: BoxDecoration(
  //           image: DecorationImage(
  //             image: NetworkImage(widget.storeImage),
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //         child: Stack(
  //           children: [
  //             _buildGradientOverlay(),
  //             _buildBackButton(),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  /// Build app bar with restaurant image and header
  Widget _buildAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      floating: true,
      pinned: false,
      expandedHeight: 250, // Adjust height to accommodate the header
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Restaurant image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.storeImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient overlay
            _buildGradientOverlay(),
            // Back button
            _buildBackButton(),
            // Header positioned at the bottom
            Positioned(
              bottom: 0, // Align to the bottom of the app bar
              left: 0,
              right: 0,
              child: Consumer<StoreProvider>(
                builder: (context, storeProvider, child) {
                  return _buildHeaderContainer(storeProvider);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Build gradient overlay for app bar
  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
    );
  }

  /// Build back button
  Widget _buildBackButton() {
    return Positioned(
      top: 40,
      left: 16,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          AppLogger.logInfo('$TAG: User navigated back');
          Navigator.pop(context);
        },
      ),
    );
  }

  // /// Build restaurant header information
  // Widget _buildHeader(StoreProvider storeProvider) {
  //   return SliverToBoxAdapter(
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Container(
  //         decoration: BoxDecoration(
  //           color: Colors.white, // Optional: Set background color
  //           borderRadius: BorderRadius.circular(20), // Adjust radius as needed
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black
  //                   .withOpacity(0.1), // Optional: Add shadow for depth
  //               blurRadius: 8,
  //               offset: Offset(0, 4), // Optional: Adjust shadow offset
  //             ),
  //           ],
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               RestaurantInfo(
  //                 name: widget.restaurantName,
  //                 description: widget.shortDescription ?? "Type of restaurant",
  //                 isOpen: widget.isOpen,
  //                 displayTiming: widget.displayTiming,
  //                 businessUnitId: storeProvider.businessUnitId ?? '',
  //               ),
  //               const SizedBox(height: 16),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  /// Build header with corner radius for the app bar
  Widget _buildHeaderContainer(StoreProvider storeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background color of the container
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.1),
        //     blurRadius: 8,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantInfo(
              name: widget.restaurantName,
              description: widget.shortDescription ?? "Type of restaurant",
              isOpen: widget.isOpen,
              displayTiming: widget.displayTiming,
              businessUnitId: storeProvider.businessUnitId ?? '',
            ),
          ],
        ),
      ),
    );
  }

  /// Build filter section
  Widget _buildFilters(ProductViewModel viewModel) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        child: ProductFilters(
          onVegFilterChanged: (value) {
            AppLogger.logInfo('$TAG: Veg filter changed to: $value');
            viewModel.toggleVegFilter(value);
          },
          isVegOnly: viewModel.isVegOnly,
          onMenuSelected: (menu) {
            AppLogger.logInfo('$TAG: Menu selected: $menu');
            if (menu != null) viewModel.setSelectedMenu(menu);
          },
          selectedMenu: viewModel.selectedMenu,
        ),
      ),
    );
  }

  /// Build category tabs
  Widget _buildCategoryTabs(ProductViewModel viewModel) {
    final categories = viewModel.getAllCategories();
    AppLogger.logDebug('$TAG: Building category tabs: $categories');

    return SliverFillRemaining(
      child: DynamicTabs(
        tabs: categories,
        selectedColor: Colors.blue,
        unselectedColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
        ),
        tabBuilder: (context, category) {
          return _buildCategoryContent(viewModel, category);
        },
      ),
    );
  }

  /// Build content for each category tab
  Widget _buildCategoryContent(ProductViewModel viewModel, String category) {
    viewModel.setSelectedCategory(category);
    final products = viewModel.getFilteredProducts();

    return ProductList(
      products: products,
      restaurantName: widget.restaurantName,
      onProductSelected: (product) => _handleProductSelection(
        context,
        product,
        context.read<StoreProvider>(),
      ),
    );
  }

  /// Handle product selection
  void _handleProductSelection(
    BuildContext context,
    ProductModel product,
    StoreProvider storeProvider,
  ) async {
    AppLogger.logInfo('$TAG: Product selected: ${product.name}');

    try {
      final cartManager = context.read<CartManager>();

      if (!_validateRestaurantSelection(storeProvider, cartManager)) {
        return;
      }

      if (product.addOnGroups?.isNotEmpty ?? false) {
        await _showAddonsDialog(context, product);
      } else {
        _addToCart(
          context,
          product,
          {},
          1,
          double.parse(product.unitprice),
        );
      }
    } catch (e) {
      AppLogger.logError('$TAG: Error handling product selection: $e');
      _showError('Failed to process selection');
    }
  }

  /// Validate restaurant selection
  bool _validateRestaurantSelection(
    StoreProvider storeProvider,
    CartManager cartManager,
  ) {
    final isValid =
        storeProvider.validateBusinessUnit(cartManager.currentBusinessUnitId);

    if (!isValid) {
      _showError('Cannot add items from different restaurant');
      return false;
    }

    return true;
  }

  /// Show addons dialog
  Future<void> _showAddonsDialog(
      BuildContext context, ProductModel product) async {
    AppLogger.logInfo('$TAG: Showing addons bottom sheet for: ${product.name}');

    try {
      await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        builder: (context) => AddonsBottomSheet(
          product: product,
          onAddToCart: (addons, quantity, totalPrice) {
            _addToCart(context, product, addons, quantity, totalPrice);
          },
          productName: product.name,
          productPrice: double.parse(product.unitprice),
          imageUrl: product.imageUrl,
        ),
      );
    } catch (e) {
      AppLogger.logError('$TAG: Error showing addons bottom sheet: $e');
      _showError('Failed to show addons');
    }
  }

  /// Add product to cart
  void _addToCart(
    BuildContext context,
    ProductModel product,
    Map<String, List<AddOnItem>> addons,
    int quantity,
    double totalPrice,
  ) {
    try {
      final cartManager = context.read<CartManager>();
      final storeProvider = context.read<StoreProvider>();

      final restaurant = storeProvider.storeData?.restaurants.firstWhere(
        (r) => r.storeId == widget.storeId,
        orElse: () => throw Exception('Restaurant not found'),
      );

      if (restaurant != null) {
        cartManager.addToCart(
          context,
          restaurant.name,
          product,
          addons,
          quantity,
          totalPrice,
        );
        _showSuccess('Item added to cart');
      }
    } catch (e) {
      AppLogger.logError('$TAG: Error adding to cart: $e');
      _showError('Failed to add item to cart');
    }
  }

  /// Handle refresh action
  Future<void> _handleRefresh(ProductViewModel viewModel) async {
    AppLogger.logInfo('$TAG: Refreshing products');

    try {
      await viewModel.fetchProducts(widget.storeId, forceRefresh: true);
      AppLogger.logInfo('$TAG: Products refreshed successfully');
    } catch (e) {
      AppLogger.logError('$TAG: Error refreshing products: $e');
      _showError('Failed to refresh products');
    }
  }

  /// Show error message
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Show success message
  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    AppLogger.logInfo('$TAG: Disposing ProductScreen');
    _scrollController.dispose();
    super.dispose();
  }
}

// // File: product_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../common/log/loggers.dart';
// import '../../addon/addons_screen.dart';
// import '../../home/cart/multiple/cart_manager.dart';
// import '../../home/error_display.dart';
// import '../../home/loading_indicator.dart';
// import '../../home/restaurant_info.dart';
// import '../../store/provider/store_provider.dart';
// import '../model/product_model.dart';
// import '../view/product_list.dart';
// import '../viewmodel/product_viewmodel.dart';
// import '../widgets/dynamic_tabs.dart';
// import 'product_filters.dart';
//
// /// ProductScreen: Main screen for displaying products with filtering and category tabs
// class ProductScreen extends StatefulWidget {
//   static const String TAG = '[ProductScreen]';
//
// // Required parameters for restaurant/store information
//   final String storeId;
//   final String storeImage;
//   final String restaurantName;
//   final bool isOpen;
//   final String displayTiming;
//   final String? shortDescription;
//
//   const ProductScreen({
//     super.key,
//     required this.storeId,
//     required this.storeImage,
//     required this.restaurantName,
//     required this.isOpen,
//     required this.displayTiming,
//     this.shortDescription,
//     required String csBunitId,
//   });
//
//   @override
//   State<ProductScreen> createState() => _ProductScreenState();
// }
//
// class _ProductScreenState extends State<ProductScreen> {
//   static const String TAG = '[ProductScreen]';
//
// // Controllers
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     AppLogger.logInfo(
//         '$TAG: Initializing ProductScreen for ${widget.restaurantName}');
//     _initializeScreen();
//   }
//
//   /// Initialize screen data and listeners
//   void _initializeScreen() async {
//     AppLogger.logInfo('$TAG: Loading initial data');
//     await _loadProducts();
//     _initializeScrollListener();
//   }
//
//   /// Load initial products data
//   Future<void> _loadProducts() async {
//     try {
//       AppLogger.logInfo('$TAG: Loading products for store: ${widget.storeId}');
//       await context.read<ProductViewModel>().fetchProducts(widget.storeId);
//     } catch (e) {
//       AppLogger.logError('$TAG: Error loading products: $e');
//       _showError('Failed to load products');
//     }
//   }
//
//   /// Initialize scroll behavior
//   void _initializeScrollListener() {
//     AppLogger.logDebug('$TAG: Initializing scroll listener');
//     _scrollController.addListener(() {
// // Add scroll-based behaviors here
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer2<StoreProvider, ProductViewModel>(
//       builder: (context, storeProvider, viewModel, _) {
//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: _buildMainContent(storeProvider, viewModel),
//         );
//       },
//     );
//   }
//
//   /// Build main screen content
//   Widget _buildMainContent(
//       StoreProvider storeProvider, ProductViewModel viewModel) {
//     if (viewModel.isLoading) {
//       return const LoadingIndicator();
//     }
//
//     if (viewModel.error.isNotEmpty) {
//       return ErrorDisplay(
//         error: viewModel.error,
//         onRetry: _loadProducts,
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: () => _handleRefresh(viewModel),
//       child: CustomScrollView(
//         controller: _scrollController,
//         slivers: [
//           _buildAppBar(),
//           _buildHeader(storeProvider),
//           _buildFilters(viewModel),
//           _buildCategoryTabs(viewModel),
//         ],
//       ),
//     );
//   }
//
//   /// Build app bar with restaurant image
//   Widget _buildAppBar() {
//     return SliverAppBar(
//       automaticallyImplyLeading: false,
//       floating: true,
//       pinned: false,
//       expandedHeight: 200,
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: NetworkImage(widget.storeImage),
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: Stack(
//             children: [
//               _buildGradientOverlay(),
//               _buildBackButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// Build gradient overlay for app bar
//   Widget _buildGradientOverlay() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.black.withOpacity(0.7),
//             Colors.transparent,
//             Colors.black.withOpacity(0.7),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Build back button
//   Widget _buildBackButton() {
//     return Positioned(
//       top: 40,
//       left: 16,
//       child: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Colors.white),
//         onPressed: () {
//           AppLogger.logInfo('$TAG: User navigated back');
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }
//
//   /// Build restaurant header information
//   Widget _buildHeader(StoreProvider storeProvider) {
//     return SliverToBoxAdapter(
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white, // Optional: Set background color
//             borderRadius: BorderRadius.circular(20), // Adjust radius as needed
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black
//                     .withOpacity(0.1), // Optional: Add shadow for depth
//                 blurRadius: 8,
//                 offset: Offset(0, 4), // Optional: Adjust shadow offset
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 RestaurantInfo(
//                   name: widget.restaurantName,
//                   description: widget.shortDescription ?? "Type of restaurant",
//                   isOpen: widget.isOpen,
//                   displayTiming: widget.displayTiming,
//                   businessUnitId: storeProvider.businessUnitId ?? '',
//                 ),
//                 const SizedBox(height: 16),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// Build filter section
//   Widget _buildFilters(ProductViewModel viewModel) {
//     return SliverToBoxAdapter(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: ProductFilters(
//           onVegFilterChanged: (value) {
//             AppLogger.logInfo('$TAG: Veg filter changed to: $value');
//             viewModel.toggleVegFilter(value);
//           },
//           isVegOnly: viewModel.isVegOnly,
//           onMenuSelected: (menu) {
//             AppLogger.logInfo('$TAG: Menu selected: $menu');
//             if (menu != null) viewModel.setSelectedMenu(menu);
//           },
//           selectedMenu: viewModel.selectedMenu,
//         ),
//       ),
//     );
//   }
//
//   /// Build category tabs
//   Widget _buildCategoryTabs(ProductViewModel viewModel) {
//     final categories = viewModel.getAllCategories();
//     AppLogger.logDebug('$TAG: Building category tabs: $categories');
//
//     return SliverFillRemaining(
//       child: DynamicTabs(
//         tabs: categories,
//         selectedColor: Colors.blue,
//         unselectedColor: Colors.grey,
//         selectedLabelStyle: const TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 14,
//         ),
//         unselectedLabelStyle: const TextStyle(
//           fontSize: 14,
//         ),
//         tabBuilder: (context, category) {
//           return _buildCategoryContent(viewModel, category);
//         },
//       ),
//     );
//   }
//
//   /// Build content for each category tab
//   Widget _buildCategoryContent(ProductViewModel viewModel, String category) {
//     viewModel.setSelectedCategory(category);
//     final products = viewModel.getFilteredProducts();
//
//     return ProductList(
//       products: products,
//       restaurantName: widget.restaurantName,
//       onProductSelected: (product) => _handleProductSelection(
//         context,
//         product,
//         context.read<StoreProvider>(),
//       ),
//     );
//   }
//
//   /// Handle product selection
//   void _handleProductSelection(
//     BuildContext context,
//     ProductModel product,
//     StoreProvider storeProvider,
//   ) async {
//     AppLogger.logInfo('$TAG: Product selected: ${product.name}');
//
//     try {
//       final cartManager = context.read<CartManager>();
//
//       if (!_validateRestaurantSelection(storeProvider, cartManager)) {
//         return;
//       }
//
//       if (product.addOnGroups?.isNotEmpty ?? false) {
//         await _showAddonsDialog(context, product);
//       } else {
//         _addToCart(
//           context,
//           product,
//           {},
//           1,
//           double.parse(product.unitprice),
//         );
//       }
//     } catch (e) {
//       AppLogger.logError('$TAG: Error handling product selection: $e');
//       _showError('Failed to process selection');
//     }
//   }
//
//   /// Validate restaurant selection
//   bool _validateRestaurantSelection(
//     StoreProvider storeProvider,
//     CartManager cartManager,
//   ) {
//     final isValid =
//         storeProvider.validateBusinessUnit(cartManager.currentBusinessUnitId);
//
//     if (!isValid) {
//       _showError('Cannot add items from different restaurant');
//       return false;
//     }
//
//     return true;
//   }
//
//   /// Show addons dialog
//   Future<void> _showAddonsDialog(
//       BuildContext context, ProductModel product) async {
//     AppLogger.logInfo('$TAG: Showing addons bottom sheet for: ${product.name}');
//
//     try {
//       await showModalBottomSheet<Map<String, dynamic>>(
//         context: context,
//         isScrollControlled: true,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(24),
//             topRight: Radius.circular(24),
//           ),
//         ),
//         builder: (context) => AddonsBottomSheet(
//           product: product,
//           onAddToCart: (addons, quantity, totalPrice) {
//             _addToCart(context, product, addons, quantity, totalPrice);
//           },
//           productName: product.name,
//           productPrice: double.parse(product.unitprice),
//           imageUrl: product.imageUrl,
//         ),
//       );
//     } catch (e) {
//       AppLogger.logError('$TAG: Error showing addons bottom sheet: $e');
//       _showError('Failed to show addons');
//     }
//   }
//
//   /// Add product to cart
//   void _addToCart(
//     BuildContext context,
//     ProductModel product,
//     Map<String, List<AddOnItem>> addons,
//     int quantity,
//     double totalPrice,
//   ) {
//     try {
//       final cartManager = context.read<CartManager>();
//       final storeProvider = context.read<StoreProvider>();
//
//       final restaurant = storeProvider.storeData?.restaurants.firstWhere(
//         (r) => r.storeId == widget.storeId,
//         orElse: () => throw Exception('Restaurant not found'),
//       );
//
//       if (restaurant != null) {
//         cartManager.addToCart(
//           context,
//           restaurant.name,
//           product,
//           addons,
//           quantity,
//           totalPrice,
//         );
//         _showSuccess('Item added to cart');
//       }
//     } catch (e) {
//       AppLogger.logError('$TAG: Error adding to cart: $e');
//       _showError('Failed to add item to cart');
//     }
//   }
//
//   /// Handle refresh action
//   Future<void> _handleRefresh(ProductViewModel viewModel) async {
//     AppLogger.logInfo('$TAG: Refreshing products');
//
//     try {
//       await viewModel.fetchProducts(widget.storeId, forceRefresh: true);
//       AppLogger.logInfo('$TAG: Products refreshed successfully');
//     } catch (e) {
//       AppLogger.logError('$TAG: Error refreshing products: $e');
//       _showError('Failed to refresh products');
//     }
//   }
//
//   /// Show error message
//   void _showError(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
//
//   /// Show success message
//   void _showSuccess(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     AppLogger.logInfo('$TAG: Disposing ProductScreen');
//     _scrollController.dispose();
//     super.dispose();
//   }
// }

// // File: product_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../common/log/loggers.dart';
// import '../../addon/addons_screen.dart';
// import '../../home/cart/multiple/cart_manager.dart';
// import '../../home/error_display.dart';
// import '../../home/loading_indicator.dart';
// import '../../home/restaurant_info.dart';
// import '../../store/provider/store_provider.dart';
// import '../model/product_model.dart';
// import '../view/product_list.dart';
// import '../viewmodel/product_viewmodel.dart';
// import '../widgets/dynamic_tabs.dart';
// import 'product_filters.dart';
//
// class ProductScreen extends StatefulWidget {
//   static const String TAG = '[ProductScreen]';
//
//   final String storeId;
//   final String storeImage;
//   final String restaurantName;
//   final bool isOpen;
//   final String displayTiming;
//   final String? shortDescription;
//
//   const ProductScreen({
//     super.key,
//     required this.storeId,
//     required this.storeImage,
//     required this.restaurantName,
//     required this.isOpen,
//     required this.displayTiming,
//     this.shortDescription,
//     required String csBunitId,
//   });
//
//   @override
//   State<ProductScreen> createState() => _ProductScreenState();
// }
//
// class _ProductScreenState extends State<ProductScreen> {
//   static const String TAG = '[ProductScreen]';
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     AppLogger.logInfo(
//         '$TAG: Initializing ProductScreen for restaurant: ${widget.restaurantName}');
//     _initializeScreen();
//   }
//
//   void _initializeScreen() async {
//     AppLogger.logInfo('$TAG: Loading initial data');
//     await _loadProducts();
//     _initializeScrollListener();
//   }
//
//   Future<void> _loadProducts() async {
//     try {
//       AppLogger.logInfo('$TAG: Loading products for store: ${widget.storeId}');
//       await context.read<ProductViewModel>().fetchProducts(widget.storeId);
//     } catch (e) {
//       AppLogger.logError('$TAG: Error loading products: $e');
//       _showError('Failed to load products');
//     }
//   }
//
//   void _initializeScrollListener() {
//     AppLogger.logDebug('$TAG: Initializing scroll listener');
//     _scrollController.addListener(() {
//       // Add any scroll-based behaviors here
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     AppLogger.logDebug('$TAG: Building ProductScreen');
//
//     return Consumer2<StoreProvider, ProductViewModel>(
//       builder: (context, storeProvider, viewModel, _) {
//         AppLogger.logDebug(
//             '$TAG: Building with businessUnitId: ${storeProvider.businessUnitId}');
//
//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: _buildMainContent(storeProvider, viewModel),
//         );
//       },
//     );
//   }
//
//   Widget _buildMainContent(
//       StoreProvider storeProvider, ProductViewModel viewModel) {
//     if (viewModel.isLoading) {
//       AppLogger.logDebug('$TAG: Showing loading indicator');
//       return const LoadingIndicator();
//     }
//
//     if (viewModel.error.isNotEmpty) {
//       AppLogger.logWarning('$TAG: Showing error: ${viewModel.error}');
//       return ErrorDisplay(
//         error: viewModel.error,
//         onRetry: _loadProducts,
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: () => _handleRefresh(viewModel),
//       child: CustomScrollView(
//         controller: _scrollController,
//         slivers: [
//           _buildAppBar(),
//           _buildHeader(storeProvider),
//           _buildFilters(viewModel),
//           // _buildProductList(storeProvider, viewModel),
//           _buildCategoryTabs(viewModel),
//         ],
//       ),
//     );
//   }
//
//   // New method to build category tabs
//   Widget _buildCategoryTabs(ProductViewModel viewModel) {
//     final categories = viewModel.getAllCategories();
//     AppLogger.logDebug('$TAG: Building category tabs: $categories');
//
//     return SliverFillRemaining(
//       child: DynamicTabs(
//         tabs: categories,
//         selectedColor: Colors.blue,
//         unselectedColor: Colors.grey,
//         selectedLabelStyle: const TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 14,
//         ),
//         unselectedLabelStyle: const TextStyle(
//           fontSize: 14,
//         ),
//         tabBuilder: (context, category) {
//           return _buildCategoryContent(viewModel, category);
//         },
//       ),
//     );
//   }
//
//   Widget _buildCategoryContent(ProductViewModel viewModel, String category) {
//     viewModel.setSelectedCategory(category);
//     final products = viewModel.getFilteredProducts();
//
//     return ProductList(
//       products: products,
//       restaurantName: widget.restaurantName,
//       onProductSelected: (product) => _handleProductSelection(
//         context,
//         product,
//         context.read<StoreProvider>(),
//       ),
//     );
//   }
//
//   Widget _buildAppBar() {
//     return SliverAppBar(
//       automaticallyImplyLeading: false, // Disable default back button
//       floating: true,
//       pinned: false,
//       expandedHeight: 200,
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: NetworkImage(widget.storeImage),
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: Stack(
//             children: [
//               // Gradient overlay
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.black.withOpacity(0.7),
//                       Colors.transparent,
//                       Colors.black.withOpacity(0.7),
//                     ],
//                   ),
//                 ),
//               ),
//               // Back button
//               Positioned(
//                 top: 40,
//                 left: 16,
//                 child: IconButton(
//                   icon: const Icon(Icons.arrow_back, color: Colors.white),
//                   onPressed: () {
//                     AppLogger.logInfo(
//                         '${ProductScreen.TAG}: User navigated back');
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(StoreProvider storeProvider) {
//     return SliverToBoxAdapter(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RestaurantInfo(
//               name: widget.restaurantName,
//               description: widget.shortDescription,
//               isOpen: widget.isOpen,
//               displayTiming: widget.displayTiming,
//               businessUnitId: storeProvider.businessUnitId ?? '',
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFilters(ProductViewModel viewModel) {
//     return SliverToBoxAdapter(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: ProductFilters(
//           onVegFilterChanged: (value) {
//             AppLogger.logInfo('$TAG: Veg filter changed to: $value');
//             viewModel.toggleVegFilter(value);
//           },
//           isVegOnly: viewModel.isVegOnly,
//           onMenuSelected: (menu) {
//             AppLogger.logInfo('$TAG: Menu selected: $menu');
//             if (menu != null) viewModel.setSelectedMenu(menu);
//           },
//           selectedMenu: viewModel.selectedMenu,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProductList(
//       StoreProvider storeProvider, ProductViewModel viewModel) {
//     final products = viewModel.getFilteredProducts();
//     AppLogger.logDebug(
//         '$TAG: Building product list with ${products.length} products');
//
//     if (products.isEmpty) {
//       return const SliverFillRemaining(
//         child: Center(child: Text('No products available')),
//       );
//     }
//
//     return SliverFillRemaining(
//       child: ProductList(
//         products: products,
//         restaurantName: widget.restaurantName,
//         onProductSelected: (product) => _handleProductSelection(
//           context,
//           product,
//           storeProvider,
//         ),
//       ),
//     );
//   }
//
//   void _handleProductSelection(
//     BuildContext context,
//     ProductModel product,
//     StoreProvider storeProvider,
//   ) async {
//     AppLogger.logInfo('$TAG: Product selected: ${product.name}');
//
//     try {
//       final cartManager = context.read<CartManager>();
//
//       // Validate restaurant selection
//       if (!_validateRestaurantSelection(storeProvider, cartManager)) {
//         return;
//       }
//
//       if (product.addOnGroups?.isNotEmpty ?? false) {
//         await _showAddonsDialog(context, product);
//       } else {
//         _addToCart(
//           context,
//           product,
//           {},
//           1,
//           double.parse(product.unitprice),
//         );
//       }
//     } catch (e) {
//       AppLogger.logError('$TAG: Error handling product selection: $e');
//       _showError('Failed to process selection');
//     }
//   }
//
//   bool _validateRestaurantSelection(
//     StoreProvider storeProvider,
//     CartManager cartManager,
//   ) {
//     final isValid =
//         storeProvider.validateBusinessUnit(cartManager.currentBusinessUnitId);
//
//     if (!isValid) {
//       AppLogger.logWarning(
//           '$TAG: Invalid restaurant selection - current: ${cartManager.currentBusinessUnitId}, '
//           'selected: ${storeProvider.businessUnitId}');
//       _showError('Cannot add items from different restaurant');
//       return false;
//     }
//
//     return true;
//   }
//
//   Future<void> _showAddonsDialog(
//       BuildContext context, ProductModel product) async {
//     AppLogger.logInfo('$TAG: Showing addons bottom sheet for: ${product.name}');
//
//     try {
//       final result = await showModalBottomSheet<Map<String, dynamic>>(
//         context: context,
//         isScrollControlled: true,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(24),
//             topRight: Radius.circular(24),
//           ),
//         ),
//         builder: (context) => AddonsBottomSheet(
//           product: product,
//           onAddToCart: (addons, quantity, totalPrice) {
//             _addToCart(context, product, addons, quantity, totalPrice);
//           },
//           productName: product.name,
//           productPrice: double.parse(product.unitprice),
//           imageUrl: product.imageUrl,
//         ),
//       );
//
//       if (result != null) {
//         AppLogger.logInfo('$TAG: Addons selected successfully');
//       }
//     } catch (e) {
//       AppLogger.logError('$TAG: Error showing addons bottom sheet: $e');
//       _showError('Failed to show addons');
//     }
//   }
//
//   // Future<void> _showAddonsDialog(
//   //     BuildContext context, ProductModel product) async {
//   //   AppLogger.logInfo('$TAG: Showing addons dialog for: ${product.name}');
//   //
//   //   try {
//   //     final result = await showModalBottomSheet<Map<String, dynamic>>(
//   //       context: context,
//   //       isScrollControlled: true,
//   //       backgroundColor: Colors.white,
//   //       shape: const RoundedRectangleBorder(
//   //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//   //       ),
//   //       builder: (context) => AddonsScreen(
//   //         product: product,
//   //         onAddToCart: (addons, quantity, totalPrice) {
//   //           _addToCart(context, product, addons, quantity, totalPrice);
//   //         },
//   //         productName: product.name,
//   //         productPrice: double.parse(product.unitprice),
//   //         imageUrl: product.imageUrl,
//   //       ),
//   //     );
//   //
//   //     if (result != null) {
//   //       AppLogger.logInfo('$TAG: Addons selected successfully');
//   //     }
//   //   } catch (e) {
//   //     AppLogger.logError('$TAG: Error showing addons dialog: $e');
//   //     _showError('Failed to show addons');
//   //   }
//   // }
//
//   // In ProductScreen:
//   void _addToCart(
//     BuildContext context,
//     ProductModel product,
//     Map<String, List<AddOnItem>> addons,
//     int quantity,
//     double totalPrice,
//   ) {
//     try {
//       final cartManager = context.read<CartManager>();
//       final storeProvider = context.read<StoreProvider>();
//
//       // Log names for debugging
//       final restaurant = storeProvider.storeData?.restaurants.firstWhere(
//         (r) => r.storeId == widget.storeId,
//         orElse: () => throw Exception('Restaurant not found'),
//       );
//
//       if (restaurant != null) {
//         AppLogger.logInfo('$TAG: Restaurant from store config:');
//         AppLogger.logInfo(
//             '$TAG: - Store Config name: ${restaurant.name}'); // Food Court-X
//         AppLogger.logInfo(
//             '$TAG: - CSBunit name: ${restaurant.businessUnit.name}'); // Actual outlet name
//         AppLogger.logInfo('$TAG: - Widget name: ${widget.restaurantName}');
//       }
//
//       // Use store config name for cart
//       cartManager.addToCart(
//         context,
//         restaurant!.name, // Use "Food Court-X" name
//         product,
//         addons,
//         quantity,
//         totalPrice,
//       );
//
//       _showSuccess('Item added to cart');
//     } catch (e) {
//       AppLogger.logError('$TAG: Error adding to cart: $e');
//       _showError('Failed to add item to cart');
//     }
//   }
//
//   Future<void> _handleRefresh(ProductViewModel viewModel) async {
//     AppLogger.logInfo('$TAG: Refreshing products');
//
//     try {
//       await viewModel.fetchProducts(widget.storeId, forceRefresh: true);
//       AppLogger.logInfo('$TAG: Products refreshed successfully');
//     } catch (e) {
//       AppLogger.logError('$TAG: Error refreshing products: $e');
//       _showError('Failed to refresh products');
//     }
//   }
//
//   void _showError(String message) {
//     AppLogger.logWarning('$TAG: Showing error message: $message');
//     if (!mounted) return;
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
//
//   void _showSuccess(String message) {
//     AppLogger.logInfo('$TAG: Showing success message: $message');
//     if (!mounted) return;
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     AppLogger.logInfo('$TAG: Disposing ProductScreen');
//     _scrollController.dispose();
//     super.dispose();
//   }
// }
