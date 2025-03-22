import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/log/loggers.dart';
import '../../addon/addons_screen.dart';
import '../../home/cart/multiple/cart_manager.dart';
import '../../home/error_display.dart';
import '../../home/loading_indicator.dart';
import '../../home/widgets/standalone_bottom_navigation_bar.dart';
import '../../main/main_screen.dart';
import '../../store/provider/store_provider.dart';
import '../model/product_model.dart';
import '../view/product_list.dart';
import '../viewmodel/product_viewmodel.dart';
import '../widgets/dynamic_tabs.dart';
import 'product_filters.dart';

class ProductScreen extends StatefulWidget {
  static const String TAG = '[ProductScreen]';

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
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  static const String TAG = '[ProductScreen]';

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    AppLogger.logInfo('$TAG: Initializing for ${widget.restaurantName}');
    Future.microtask(() => _initializeScreen());
  }

  void _initializeScreen() async {
    AppLogger.logInfo('$TAG: Loading initial data');
    await _loadProducts();
    _initializeScrollListener();
  }

  Future<void> _loadProducts() async {
    try {
      AppLogger.logInfo('$TAG: Fetching products for store: ${widget.storeId}');
      await context.read<ProductViewModel>().fetchProducts(widget.storeId);
    } catch (e) {
      AppLogger.logError('$TAG: Error loading products: $e');
      _showError('Failed to load products');
    }
  }

  void _initializeScrollListener() {
    AppLogger.logDebug('$TAG: Initializing scroll listener');
    _scrollController.addListener(() {});
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Consumer2<StoreProvider, ProductViewModel>(
  //     builder: (context, storeProvider, viewModel, _) {
  //       return Scaffold(
  //         backgroundColor: Colors.white,
  //         body: _buildMainContent(storeProvider, viewModel),
  //       );
  //     },
  //   );
  // }

  //Product screen Build
  @override
  Widget build(BuildContext context) {
    return Consumer2<StoreProvider, ProductViewModel>(
      builder: (context, storeProvider, viewModel, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: _buildMainContent(storeProvider, viewModel),
          bottomNavigationBar: StandaloneBottomNavigationBar(
            // The default behavior will navigate to MainScreen with the selected tab
            // No need to provide custom onTap unless you want different behavior


            // currentIndex: 0, // Highlight Home tab (since it originates from HomeScreen)
            // onTap: (index) {
            //   if (index == 0) {
            //     // Go back to MainScreen's Home tab
            //     Navigator.pop(context);
            //   } else if (index == 1) {
            //     // Navigate to CartScreen
            //     Navigator.pop(context); // Pop to MainScreen
            //     context.read<MainScreenState?>()?.onItemTapped(1); // Switch to Cart tab (if MainScreen is accessible)
            //   } else if (index == 2) {
            //     // Navigate to MenuScreen
            //     Navigator.pop(context); // Pop to MainScreen
            //     context.read<MainScreenState?>()?.onItemTapped(2); // Switch to Menu tab (if MainScreen is accessible)
            //   }
            // },
            //   currentIndex: null, // No tab should be highlighted in ProductScreen
              onTap: (index) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(initialIndex: index), // Pass selected tab index
                  ),
                );
              }
          ),
        );
      },
    );
  }

  Widget _buildMainContent(StoreProvider storeProvider, ProductViewModel viewModel) {
    if (viewModel.isLoading) {
      return const LoadingIndicator();
    }
    if (viewModel.error.isNotEmpty) {
      return ErrorDisplay(error: viewModel.error, onRetry: _loadProducts);
    }
    return RefreshIndicator(
      onRefresh: () => _handleRefresh(viewModel),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(storeProvider), // Updated AppBar
          _buildFilters(viewModel),
          _buildCategoryTabs(viewModel),
        ],
      ),
    );
  }

  // Updated SliverAppBar with fixed overflow and Swiggy-inspired design
  Widget _buildAppBar(StoreProvider storeProvider) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      floating: true,
      pinned: true, // Pinned for better UX like Swiggy
      expandedHeight: 260, // Reduced height to prevent overflow
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.storeImage),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.2), // Subtle overlay
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            // Gradient Overlay (reduced opacity)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Back Button
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () {
                  AppLogger.logInfo('$TAG: User navigated back');
                  Navigator.pop(context);
                },
              ),
            ),
            // Restaurant Info Container
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildHeaderContainer(storeProvider),
            ),
          ],
        ),
      ),
    );
  }

  // Updated Header Container to fix overflow and improve design
  Widget _buildHeaderContainer(StoreProvider storeProvider) {
    return Container(
      // padding: const EdgeInsets.all(8),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Restaurant Name
              Text(
                widget.restaurantName,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(width: 8),
              // Status and Timing
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Icon(
                        widget.isOpen ? Icons.check_circle : Icons.cancel,
                        size: 11,
                        color: widget.isOpen ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        widget.isOpen ? 'Open' : 'Closed',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: widget.isOpen ? Colors.green : Colors.red,
                          // color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.displayTiming,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.black54,
                    ),
                  ),

                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Description
          Text(
            widget.shortDescription ?? "Type of restaurant",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // const SizedBox(height: 4),
          // // Status and Timing
          // Row(
          //   // mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     Column(
          //       children: [
          //         Icon(
          //           widget.isOpen ? Icons.check_circle : Icons.cancel,
          //           size: 16,
          //           color: widget.isOpen ? Colors.black : Colors.black54,
          //         ),
          //         const SizedBox(width: 4),
          //         Text(
          //           widget.isOpen ? 'Open' : 'Closed',
          //           style: const TextStyle(
          //             fontSize: 12,
          //             fontWeight: FontWeight.w600,
          //             color: Colors.black,
          //           ),
          //         ),
          //       ],
          //     ),
          //     const SizedBox(width: 8),
          //     Text(
          //       widget.displayTiming,
          //       style: const TextStyle(
          //         fontSize: 12,
          //         color: Colors.black54,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildFilters(ProductViewModel viewModel) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        child: ProductFilters(
          onVegFilterChanged: viewModel.toggleVegFilter,
          isVegOnly: viewModel.isVegOnly,
        //   onMenuSelected: (menu) {
        //     AppLogger.logInfo('$TAG: Menu selected: $menu');
        //     if (menu != null) viewModel.setSelectedMenu(menu);
        //   },
        //   selectedMenu: viewModel.selectedMenu,
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(ProductViewModel viewModel) {
    final categories = viewModel.getAllCategories();
    AppLogger.logDebug('$TAG: Building tabs: $categories');
    return SliverFillRemaining(
      child: DynamicTabs(
    // return SliverToBoxAdapter( // ✅ Changed: Directly returning SliverToBoxAdapter
    //   child: DynamicTabs(
        tabs: categories,
        selectedColor: Colors.black, // Updated to black
        unselectedColor: Colors.black54,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
        ),
        tabBuilder: (context, category) => _buildCategoryContent(viewModel, category),
      // ),
        ),
    );
  }

  Widget _buildCategoryContent(ProductViewModel viewModel, String category) {
    viewModel.setSelectedCategory(category);
    final products = viewModel.getFilteredProducts();
    return ProductList(
      products: products,
      restaurantName: widget.restaurantName,
      onProductSelected: (product) => _handleProductSelection(context, product, context.read<StoreProvider>()),
    );
  }

  void _handleProductSelection(BuildContext context, ProductModel product, StoreProvider storeProvider) async {
    AppLogger.logInfo('$TAG: Product selected: ${product.name}');
    try {
      final cartManager = context.read<CartManager>();
      if (!_validateRestaurantSelection(storeProvider, cartManager)) return;
      if (product.addOnGroups?.isNotEmpty ?? false) {
        await _showAddonsDialog(context, product);
      } else {
        _addToCart(context, product, {}, 1, double.parse(product.unitprice ?? '0'));
      }
    } catch (e) {
      AppLogger.logError('$TAG: Error handling selection: $e');
      _showError('Failed to process selection');
    }
  }

  bool _validateRestaurantSelection(StoreProvider storeProvider, CartManager cartManager) {
    final isValid = storeProvider.validateBusinessUnit(cartManager.currentBusinessUnitId);
    if (!isValid) {
      _showError('Cannot add items from different restaurant');
      return false;
    }
    return true;
  }

  Future<void> _showAddonsDialog(BuildContext context, ProductModel product) async {
    AppLogger.logInfo('$TAG: Showing addons for: ${product.name}');
    try {
      await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => AddonsBottomSheet(
          product: product,
          onAddToCart: (addons, quantity, totalPrice) => _addToCart(context, product, addons, quantity, totalPrice),
          productName: product.name,
          productPrice: double.parse(product.unitprice ?? '0'),
          imageUrl: product.imageUrl,
        ),
      );
    } catch (e) {
      AppLogger.logError('$TAG: Error showing addons: $e');
      _showError('Failed to show addons');
    }
  }

  void _addToCart(BuildContext context, ProductModel product, Map<String, List<AddOnItem>> addons, int quantity, double totalPrice) {
    try {
      final cartManager = context.read<CartManager>();
      final storeProvider = context.read<StoreProvider>();
      final restaurant = storeProvider.storeData?.restaurants.firstWhere(
            (r) => r.storeId == widget.storeId,
        orElse: () => throw Exception('Restaurant not found'),
      );
      if (restaurant != null) {
        cartManager.addToCart(context, restaurant.name, product, addons, quantity, totalPrice);
        _showSuccess('Item added to cart');
      }
    } catch (e) {
      AppLogger.logError('$TAG: Error adding to cart: $e');
      _showError('Failed to add item to cart');
    }
  }

  Future<void> _handleRefresh(ProductViewModel viewModel) async {
    AppLogger.logInfo('$TAG: Refreshing products');
    try {
      await viewModel.fetchProducts(widget.storeId, forceRefresh: true);
      AppLogger.logInfo('$TAG: Products refreshed');
    } catch (e) {
      AppLogger.logError('$TAG: Error refreshing: $e');
      _showError('Failed to refresh products');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black54,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    AppLogger.logInfo('$TAG: Disposing');
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
//
//     // Use Future.microtask to delay initialization until after build
//     Future.microtask(() => _initializeScreen());
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
//           // _buildHeader(storeProvider),
//           _buildFilters(viewModel),
//           _buildCategoryTabs(viewModel),
//         ],
//       ),
//     );
//   }
//
//
//   /// Build app bar with restaurant image and header
//   Widget _buildAppBar() {
//     return SliverAppBar(
//       automaticallyImplyLeading: false,
//       floating: true,
//       pinned: false,
//       expandedHeight: 250, // Adjust height to accommodate the header
//       flexibleSpace: FlexibleSpaceBar(
//         background: Stack(
//           children: [
//             // Restaurant image
//             Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: NetworkImage(widget.storeImage),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             // Gradient overlay
//             _buildGradientOverlay(),
//             // Back button
//             _buildBackButton(),
//             // Header positioned at the bottom
//             Positioned(
//               bottom: 0, // Align to the bottom of the app bar
//               left: 0,
//               right: 0,
//               child: Consumer<StoreProvider>(
//                 builder: (context, storeProvider, child) {
//                   return _buildHeaderContainer(storeProvider);
//                 },
//               ),
//             )
//           ],
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
//
//   /// Build header with corner radius for the app bar
//   Widget _buildHeaderContainer(StoreProvider storeProvider) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white, // Background color of the container
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(30),
//           topRight: Radius.circular(30),
//         ),
//         // boxShadow: [
//         //   BoxShadow(
//         //     color: Colors.black.withOpacity(0.1),
//         //     blurRadius: 8,
//         //     offset: const Offset(0, 4),
//         //   ),
//         // ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RestaurantInfo(
//               name: widget.restaurantName,
//               description: widget.shortDescription ?? "Type of restaurant",
//               isOpen: widget.isOpen,
//               displayTiming: widget.displayTiming,
//               businessUnitId: storeProvider.businessUnitId ?? '',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Build filter section
//   Widget _buildFilters(ProductViewModel viewModel) {
//     return SliverToBoxAdapter(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
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
//

//ℹ️ INFO [logFlow]: User data: {otp: null, token: null, b2cCustomerId: 78BAAB798BE84482854ADA9E223713B9, newCustomer: false, mobileNo: +919876543210, firstName: g, lastName: g, email: g, walletId: null, phone: , walletBalance: 0.0}// CW_250319-192319
// CW_250319-192319
// 🐛 📘 DEBUG [logFlow]: [KitchenApiService] Redis order data: {customerId: 78BAAB798BE84482854ADA9E223713B9, documentno: CW_250319-192319, cSBunitID: 6A779417308F4C08A109FDEFF4BC1225, customerName: g g, dateOrdered: 2025-03-19T19:23:20.018685, status: pending, line: [{mProductId: 02A54529B2E1431ABECAC8DED25B62A4, name: Veg Cheese Grilled, qty: 1, notes: , productioncenter: CHICKEN AFFAIR, token_number: 1, status: pending, subProducts: []}]}
// //