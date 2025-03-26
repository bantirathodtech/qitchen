import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../products/viewmodel/product_viewmodel.dart';
import '../../products/widgets/product_card.dart';
import '../../store/view/widgets/restaurant_card.dart';
import '../../store/viewmodel/home_viewmodel.dart';
import '../../products/view/product_screen.dart';
import '../../products/model/product_model.dart';
import '../../store/model/store_models.dart';
import '../../../../common/log/loggers.dart';
import '../../products/view/product_detail_screen.dart'; // Import ProductDetailScreen

// Helper function to normalize text for searching
String normalizeSearchText(String text) {
  return text
      .toLowerCase()
      .replaceAll('-', '')
      .replaceAll('_', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class SearchResults extends StatefulWidget {
  final String searchQuery;

  const SearchResults({super.key, required this.searchQuery});

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> with SingleTickerProviderStateMixin {
  static const String TAG = '[SearchResults]';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab bar for switching between restaurants and dishes
        Consumer2<HomeViewModel, ProductViewModel>(
          builder: (context, homeViewModel, productViewModel, child) {
            // Count restaurants that match the search query
            final restaurantCount = widget.searchQuery.isEmpty || homeViewModel.storeData == null
                ? 0
                : homeViewModel.searchRestaurants(widget.searchQuery).length;

            // Count dishes that match the search query
            final normalizedQuery = normalizeSearchText(widget.searchQuery);
            final dishCount = widget.searchQuery.isEmpty || productViewModel.products.isEmpty
                ? 0
                : productViewModel.products.where((product) {
              final normalizedName = normalizeSearchText(product.name);
              final normalizedMenuName = normalizeSearchText(product.menuName ?? '');
              final normalizedDescription = normalizeSearchText(product.shortDesc ?? '');

              return normalizedName.contains(normalizedQuery) ||
                  normalizedMenuName.contains(normalizedQuery) ||
                  normalizedDescription.contains(normalizedQuery);
            }).length;

            return Column(
              children: [
                // Tab bar
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  tabs: [
                    Tab(text: 'Restaurants ($restaurantCount)'),
                    Tab(text: 'Dishes ($dishCount)'),
                  ],
                ),

                // No results message when both tabs are empty
                if (restaurantCount == 0 && dishCount == 0 && widget.searchQuery.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'No matching restaurants or dishes found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        // TabBarView to show the appropriate content based on the selected tab
        // Always show the TabBarView, but with a message if search query is empty
        Container(
          height: MediaQuery.of(context).size.height * 0.7, // Set explicit height
          child: TabBarView(
            controller: _tabController,
            children: [
              // Restaurants tab content
              _buildRestaurantResults(),

              // Dishes tab content
              _buildDishResults(),
            ],
          ),
        ),
      ],
    );
  }

  // Build restaurant search results
  Widget _buildRestaurantResults() {
    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        // Debug information
        AppLogger.logInfo('$TAG: Building restaurant results for query: "${widget.searchQuery}"');
        AppLogger.logInfo('$TAG: StoreData available: ${homeViewModel.storeData != null}');

        if (widget.searchQuery.isEmpty || homeViewModel.storeData == null) {
          return const Center(child: Text('Enter a search term to find restaurants'));
        }

        // Get filtered restaurants and log count
        final filteredRestaurants = homeViewModel.searchRestaurants(widget.searchQuery);
        AppLogger.logInfo('$TAG: Found ${filteredRestaurants.length} matching restaurants');

        if (filteredRestaurants.isEmpty) {
          return const Center(
            child: Text(
              'No matching restaurants found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        // Build the list of restaurants
        return ListView.builder(
          shrinkWrap: true, // Allow the list to take only needed space
          padding: const EdgeInsets.all(16),
          itemCount: filteredRestaurants.length,
          itemBuilder: (context, index) {
            final restaurant = filteredRestaurants[index];
            AppLogger.logInfo('$TAG: Rendering restaurant: ${restaurant.name}');
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RestaurantCard(
                restaurant: restaurant,
                onTap: () {
                  _navigateToRestaurantProductScreen(context, restaurant, homeViewModel);
                },
              ),
            );
          },
        );
      },
    );
  }

  // Navigate to restaurant product screen
  void _navigateToRestaurantProductScreen(
      BuildContext context,
      RestaurantModel restaurant,
      HomeViewModel homeViewModel
      ) {
    try {
      AppLogger.logInfo('$TAG: Navigating to restaurant: ${restaurant.name}');

      // Update selected restaurant in HomeViewModel
      homeViewModel.selectRestaurant(restaurant);

      // Get restaurant status
      final status = homeViewModel.getRestaurantStatus(restaurant);

      // Close the search overlay
      Navigator.pop(context);

      // Navigate to product screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductScreen(
            storeId: restaurant.storeId,
            storeImage: restaurant.storeImage,
            restaurantName: restaurant.name,
            isOpen: status['isOpen'] as bool,
            displayTiming: status['displayTiming'] as String,
            shortDescription: restaurant.shortDescription,
          ),
        ),
      );
    } catch (e) {
      AppLogger.logError('$TAG: Error navigating to restaurant screen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error opening restaurant')),
      );
    }
  }

  // Build dish/product search results
  Widget _buildDishResults() {
    return Consumer2<HomeViewModel, ProductViewModel>(
      builder: (context, homeViewModel, productViewModel, child) {
        // Debug information
        AppLogger.logInfo('$TAG: Building dish results for query: "${widget.searchQuery}"');
        AppLogger.logInfo('$TAG: Products available: ${productViewModel.products.isNotEmpty}');

        if (widget.searchQuery.isEmpty) {
          return const Center(child: Text('Enter a search term to find dishes'));
        }

        // Check if products are loaded
        if (productViewModel.products.isEmpty) {
          return const Center(child: Text('No dishes available to search'));
        }

        // Get filtered products and log count
        final normalizedQuery = normalizeSearchText(widget.searchQuery);
        AppLogger.logInfo('$TAG: Normalized query: "$normalizedQuery"');

        final filteredProducts = productViewModel.products.where((product) {
          final normalizedName = normalizeSearchText(product.name);
          final normalizedMenuName = normalizeSearchText(product.menuName ?? '');
          final normalizedDescription = normalizeSearchText(product.shortDesc ?? '');

          // Debug a sample of matches
          if (product.name.toLowerCase().contains(widget.searchQuery.toLowerCase())) {
            AppLogger.logInfo('$TAG: Product match found: ${product.name}');
          }

          return normalizedName.contains(normalizedQuery) ||
              normalizedMenuName.contains(normalizedQuery) ||
              normalizedDescription.contains(normalizedQuery);
        }).toList();

        AppLogger.logInfo('$TAG: Found ${filteredProducts.length} matching dishes');

        if (filteredProducts.isEmpty) {
          return const Center(
            child: Text(
              'No matching dishes found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        // Build the list of dishes
        return ListView.builder(
          shrinkWrap: true, // Allow the list to take only needed space
          padding: const EdgeInsets.all(16),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            AppLogger.logInfo('$TAG: Rendering product: ${product.name}');
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ProductCard(
                product: product,
                restaurantName: product.menuName ?? '',
                onTap: () {
                  _navigateToProductDetailScreen(context, product, homeViewModel, productViewModel);
                },
              ),
            );
          },
        );
      },
    );
  }

  // Navigate to product detail screen
  void _navigateToProductDetailScreen(
      BuildContext context,
      ProductModel product,
      HomeViewModel homeViewModel,
      ProductViewModel productViewModel
      ) {
    try {
      AppLogger.logInfo('$TAG: Navigating to product details: ${product.name}');

      // Get the restaurant that contains this product
      final storeData = homeViewModel.storeData;
      if (storeData == null || storeData.restaurants.isEmpty) {
        throw Exception('Store data not available');
      }

      // Default to the first restaurant (to ensure we have a non-null value)
      RestaurantModel selectedRestaurant = storeData.restaurants.first;
      bool foundMatch = false;

      // Try to match by menu name first
      if (product.menuName != null && product.menuName!.isNotEmpty) {
        // Look for a restaurant with a name that matches the menu name
        for (var restaurant in storeData.restaurants) {
          if (restaurant.name.toLowerCase() == product.menuName!.toLowerCase()) {
            selectedRestaurant = restaurant;
            foundMatch = true;
            break;
          }
        }
      }

      // If no match by menu name, try to match by category
      if (!foundMatch && product.categoryName.isNotEmpty) {
        for (var restaurant in storeData.restaurants) {
          if (restaurant.name.toLowerCase().contains(product.categoryName.toLowerCase())) {
            selectedRestaurant = restaurant;
            foundMatch = true;
            break;
          }
        }
      }

      // Update selected restaurant in HomeViewModel
      homeViewModel.selectRestaurant(selectedRestaurant);

      // Close the search overlay
      Navigator.pop(context);

      // Navigate directly to the ProductDetailScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(
            product: product,
            restaurantName: selectedRestaurant.name,
            onBackPressed: () {
              // When coming back from details, navigate to the product screen if desired
              AppLogger.logInfo('$TAG: Returning from product details');
            },
          ),
        ),
      );

    } catch (e) {
      AppLogger.logError('$TAG: Error navigating to product screen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error opening product details')),
      );
    }
  }
}




// //TODO: working well but result not opening screen
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../products/viewmodel/product_viewmodel.dart';
// import '../../products/widgets/product_card.dart';
// import '../../store/view/widgets/restaurant_card.dart';
// import '../../store/viewmodel/home_viewmodel.dart';
//
// // Helper function to normalize text for searching (unchanged)
// String normalizeSearchText(String text) {
//   return text
//       .toLowerCase()
//       .replaceAll('-', '')
//       .replaceAll('_', '')
//       .replaceAll(RegExp(r'\s+'), ' ')
//       .trim();
// }
//
// class SearchResults extends StatefulWidget {
//   final String searchQuery;
//
//   const SearchResults({super.key, required this.searchQuery});
//
//   @override
//   State<SearchResults> createState() => _SearchResultsState();
// }
//
// class _SearchResultsState extends State<SearchResults> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Tab bar for switching between restaurants and dishes
//         Consumer2<HomeViewModel, ProductViewModel>(
//           builder: (context, homeViewModel, productViewModel, child) {
//             // Count restaurants that match the search query
//             final restaurantCount = widget.searchQuery.isEmpty || homeViewModel.storeData == null
//                 ? 0
//                 : homeViewModel.searchRestaurants(widget.searchQuery).length;
//
//             // Count dishes that match the search query
//             final normalizedQuery = normalizeSearchText(widget.searchQuery);
//             final dishCount = widget.searchQuery.isEmpty || productViewModel.products == null
//                 ? 0
//                 : productViewModel.products.where((product) {
//               final normalizedName = normalizeSearchText(product.name);
//               final normalizedMenuName = normalizeSearchText(product.menuName ?? '');
//               final normalizedDescription = normalizeSearchText(product.shortDesc ?? '');
//
//               return normalizedName.contains(normalizedQuery) ||
//                   normalizedMenuName.contains(normalizedQuery) ||
//                   normalizedDescription.contains(normalizedQuery);
//             }).length;
//
//             return Column(
//               children: [
//                 // Tab bar
//                 TabBar(
//                   controller: _tabController,
//                   // labelColor: Theme.of(context).primaryColor,
//                   labelColor: Colors.black,
//                   unselectedLabelColor: Colors.grey,
//                   // indicatorColor: Theme.of(context).primaryColor,
//                   indicatorColor: Colors.black,
//                   tabs: [
//                     Tab(text: 'Restaurants ($restaurantCount)'),
//                     Tab(text: 'Dishes ($dishCount)'),
//                   ],
//                 ),
//
//                 // No results message when both tabs are empty
//                 if (restaurantCount == 0 && dishCount == 0 && widget.searchQuery.isNotEmpty)
//                   const Padding(
//                     padding: EdgeInsets.all(24.0),
//                     child: Center(
//                       child: Text(
//                         'No matching restaurants or dishes found',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           },
//         ),
//
//         // TabBarView to show the appropriate content based on the selected tab
//         if (widget.searchQuery.isNotEmpty)
//           SizedBox(
//             height: 700, // You might want to adjust this height or make it dynamic
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 // Restaurants tab content
//                 _buildRestaurantResults(),
//
//                 // Dishes tab content
//                 _buildDishResults(),
//               ],
//             ),
//           ),
//       ],
//     );
//   }
//
//   // Build restaurant search results
//   Widget _buildRestaurantResults() {
//     return Consumer<HomeViewModel>(
//       builder: (context, homeViewModel, child) {
//         if (widget.searchQuery.isEmpty || homeViewModel.storeData == null) {
//           return const Center(child: Text('Enter a search term to find restaurants'));
//         }
//
//         final filteredRestaurants = homeViewModel.searchRestaurants(widget.searchQuery);
//
//         if (filteredRestaurants.isEmpty) {
//           return const Center(
//             child: Text(
//               'No matching restaurants found',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           );
//         }
//
//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: filteredRestaurants.length,
//           itemBuilder: (context, index) {
//             final restaurant = filteredRestaurants[index];
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: RestaurantCard(
//                 restaurant: restaurant,
//                 onTap: () {
//                   homeViewModel.selectRestaurant(restaurant);
//                   Navigator.pop(context);
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // Build dish/product search results
//   Widget _buildDishResults() {
//     return Consumer<ProductViewModel>(
//       builder: (context, productViewModel, child) {
//         if (widget.searchQuery.isEmpty || productViewModel.products == null) {
//           return const Center(child: Text('Enter a search term to find dishes'));
//         }
//
//         final normalizedQuery = normalizeSearchText(widget.searchQuery);
//         final filteredProducts = productViewModel.products.where((product) {
//           final normalizedName = normalizeSearchText(product.name);
//           final normalizedMenuName = normalizeSearchText(product.menuName ?? '');
//           final normalizedDescription = normalizeSearchText(product.shortDesc ?? '');
//
//           return normalizedName.contains(normalizedQuery) ||
//               normalizedMenuName.contains(normalizedQuery) ||
//               normalizedDescription.contains(normalizedQuery);
//         }).toList();
//
//         if (filteredProducts.isEmpty) {
//           return const Center(
//             child: Text(
//               'No matching dishes found',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           );
//         }
//
//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: filteredProducts.length,
//           itemBuilder: (context, index) {
//             final product = filteredProducts[index];
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: ProductCard(
//                 product: product,
//                 restaurantName: product.menuName ?? '',
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
//
