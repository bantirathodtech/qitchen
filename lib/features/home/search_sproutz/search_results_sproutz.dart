// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../products/viewmodel/product_viewmodel.dart';
// import '../../products/widgets/product_card.dart';
// import '../../store/view/widgets/restaurant_card.dart';
// import '../../store/viewmodel/home_viewmodel.dart';
//
// // Helper function to normalize text for searching
// String normalizeSearchText(String text) {
//   return text
//       .toLowerCase()
//       .replaceAll('-', '') // Remove dashes
//       .replaceAll('_', '') // Remove underscores (optional)
//       .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
//       .trim();
// }
//
// class SearchResults extends StatefulWidget {
//   final String initialQuery;
//
//   const SearchResults({super.key, required this.initialQuery});
//
//   @override
//   State<SearchResults> createState() => _SearchResultsState();
// }
//
// class _SearchResultsState extends State<SearchResults> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late TextEditingController _searchController;
//   String _searchQuery = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _searchController = TextEditingController(text: widget.initialQuery);
//     _searchQuery = widget.initialQuery;
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Search bar at the top
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: 'Search restaurants or dishes...',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               suffixIcon: IconButton(
//                 icon: const Icon(Icons.clear),
//                 onPressed: () {
//                   _searchController.clear();
//                   setState(() {
//                     _searchQuery = '';
//                   });
//                 },
//               ),
//             ),
//             onChanged: (value) {
//               setState(() {
//                 _searchQuery = value;
//               });
//             },
//           ),
//         ),
//         // Tabs below the search bar
//         TabBar(
//           controller: _tabController,
//           labelColor: Theme.of(context).primaryColor,
//           unselectedLabelColor: Colors.grey,
//           indicatorColor: Theme.of(context).primaryColor,
//           tabs: [
//             Tab(
//               child: Consumer<HomeViewModel>(
//                 builder: (context, homeViewModel, child) {
//                   final filteredRestaurants = _searchQuery.isEmpty || homeViewModel.storeData == null
//                       ? []
//                       : homeViewModel.searchRestaurants(_searchQuery);
//                   return Text('Restaurants (${filteredRestaurants.length})');
//                 },
//               ),
//             ),
//             Tab(
//               child: Consumer<ProductViewModel>(
//                 builder: (context, productViewModel, child) {
//                   final normalizedQuery = normalizeSearchText(_searchQuery);
//                   final filteredProducts = _searchQuery.isEmpty || productViewModel.products == null
//                       ? []
//                       : productViewModel.products.where((product) {
//                     final normalizedName = normalizeSearchText(product.name);
//                     final normalizedMenuName = normalizeSearchText(product.menuName ?? '');
//                     final normalizedDescription = normalizeSearchText(product.shortDesc ?? '');
//                     return normalizedName.contains(normalizedQuery) ||
//                         normalizedMenuName.contains(normalizedQuery) ||
//                         normalizedDescription.contains(normalizedQuery);
//                   }).toList();
//                   return Text('Dishes (${filteredProducts.length})');
//                 },
//               ),
//             ),
//           ],
//         ),
//         // Results below the tabs
//         Expanded(
//           child: TabBarView(
//             controller: _tabController,
//             children: [
//               // Restaurants Tab Results
//               _buildRestaurantSection(context),
//               // Dishes Tab Results
//               _buildDishesSection(context),
//             ],
//           ),
//         ),
//         // No results message
//         _buildNoResultsMessage(context),
//       ],
//     );
//   }
//
//   // Build restaurant search results section (unchanged from original working code)
//   Widget _buildRestaurantSection(BuildContext context) {
//     return Consumer<HomeViewModel>(
//       builder: (context, homeViewModel, child) {
//         if (_searchQuery.isEmpty || homeViewModel.storeData == null) {
//           return const SizedBox.shrink();
//         }
//
//         // Use HomeViewModel's searchRestaurants method to filter restaurants
//         final filteredRestaurants = homeViewModel.searchRestaurants(_searchQuery);
//
//         if (filteredRestaurants.isEmpty) {
//           return const SizedBox.shrink();
//         }
//
//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                 child: Text(
//                   'Restaurants (${filteredRestaurants.length})',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               // Content
//               ...filteredRestaurants.map((restaurant) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                   child: RestaurantCard(
//                     restaurant: restaurant,
//                     onTap: () {
//                       homeViewModel.selectRestaurant(restaurant);
//                       Navigator.pop(context);
//                     },
//                   ),
//                 );
//               }).toList(),
//               const SizedBox(height: 8),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   // Build product search results section (unchanged from original working code)
//   Widget _buildDishesSection(BuildContext context) {
//     return Consumer<ProductViewModel>(
//       builder: (context, productViewModel, child) {
//         if (_searchQuery.isEmpty || productViewModel.products == null) {
//           return const SizedBox.shrink();
//         }
//
//         final normalizedQuery = normalizeSearchText(_searchQuery);
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
//           return const SizedBox.shrink();
//         }
//
//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                 child: Text(
//                   'Dishes (${filteredProducts.length})',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               // Content
//               ...filteredProducts.map((product) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                   child: ProductCard(
//                     product: product,
//                     restaurantName: product.menuName ?? '',
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                 );
//               }).toList(),
//               const SizedBox(height: 8),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   // Show a message when no results are found in either category (unchanged from original)
//   Widget _buildNoResultsMessage(BuildContext context) {
//     return Consumer2<HomeViewModel, ProductViewModel>(
//       builder: (context, homeViewModel, productViewModel, child) {
//         if (_searchQuery.isEmpty) {
//           return const SizedBox.shrink();
//         }
//
//         final hasRestaurants = homeViewModel.storeData != null &&
//             homeViewModel.searchRestaurants(_searchQuery).isNotEmpty;
//
//         final hasProducts = productViewModel.products != null &&
//             productViewModel.products.where((product) {
//               final normalizedQuery = normalizeSearchText(_searchQuery);
//               final normalizedName = normalizeSearchText(product.name);
//               final normalizedMenuName = normalizeSearchText(product.menuName ?? '');
//               final normalizedDescription = normalizeSearchText(product.shortDesc ?? '');
//
//               return normalizedName.contains(normalizedQuery) ||
//                   normalizedMenuName.contains(normalizedQuery) ||
//                   normalizedDescription.contains(normalizedQuery);
//             }).isNotEmpty;
//
//         if (!hasRestaurants && !hasProducts) {
//           return const Padding(
//             padding: EdgeInsets.all(24.0),
//             child: Center(
//               child: Text(
//                 'No matching restaurants or dishes found',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           );
//         }
//
//         return const SizedBox.shrink();
//       },
//     );
//   }
// }



//TODO: UI portion of SearchResults widget to display in expandable sections


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../products/viewmodel/product_viewmodel.dart';
import '../../products/widgets/product_card.dart';
import '../../store/view/widgets/restaurant_card.dart';
import '../../store/viewmodel/home_viewmodel.dart';


// Helper function to normalize text for searching
String normalizeSearchText(String text) {
  return text
      .toLowerCase()
      .replaceAll('-', '') // Remove dashes
      .replaceAll('_', '') // Remove underscores (optional)
      .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
      .trim();
}

class SearchResults extends StatefulWidget {
  final String searchQuery;

  const SearchResults({super.key, required this.searchQuery});

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  bool _isRestaurantsExpanded = true;
  bool _isDishesExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Restaurant search results expandable section
        _buildRestaurantSection(context),

        // Product/dish search results expandable section
        _buildDishesSection(context),

        // No results message if needed
        _buildNoResultsMessage(context),
      ],
    );
  }

  // Build restaurant search results section with expandable button
  Widget _buildRestaurantSection(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        if (widget.searchQuery.isEmpty || homeViewModel.storeData == null) {
          return const SizedBox.shrink();
        }

        // Use HomeViewModel's searchRestaurants method to filter restaurants
        final filteredRestaurants = homeViewModel.searchRestaurants(widget.searchQuery);

        if (filteredRestaurants.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expandable header
            InkWell(
              onTap: () {
                setState(() {
                  _isRestaurantsExpanded = !_isRestaurantsExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Restaurants (${filteredRestaurants.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      _isRestaurantsExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            // Expandable content
            if (_isRestaurantsExpanded)
              ...filteredRestaurants.map((restaurant) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: RestaurantCard(
                    restaurant: restaurant,
                    onTap: () {
                      // Handle restaurant selection
                      homeViewModel.selectRestaurant(restaurant);
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),

            if (_isRestaurantsExpanded) const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  // Build product search results section with expandable button
  Widget _buildDishesSection(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, productViewModel, child) {
        if (widget.searchQuery.isEmpty || productViewModel.products == null) {
          return const SizedBox.shrink();
        }

        final normalizedQuery = normalizeSearchText(widget.searchQuery);
        final filteredProducts = productViewModel.products.where((product) {
          final normalizedName = normalizeSearchText(product.name);
          final normalizedMenuName = normalizeSearchText(product.menuName ?? '');
          final normalizedDescription = normalizeSearchText(product.shortDesc ?? '');

          return normalizedName.contains(normalizedQuery) ||
              normalizedMenuName.contains(normalizedQuery) ||
              normalizedDescription.contains(normalizedQuery);
        }).toList();

        if (filteredProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expandable header
            InkWell(
              onTap: () {
                setState(() {
                  _isDishesExpanded = !_isDishesExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dishes (${filteredProducts.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      _isDishesExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            // Expandable content
            if (_isDishesExpanded)
              ...filteredProducts.map((product) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ProductCard(
                    product: product,
                    restaurantName: product.menuName ?? '',
                    // csBunitId: '',
                    onTap: () {
                      // Close search and potentially navigate
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),

            if (_isDishesExpanded) const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  // Show a message when no results are found in either category
  Widget _buildNoResultsMessage(BuildContext context) {
    return Consumer2<HomeViewModel, ProductViewModel>(
      builder: (context, homeViewModel, productViewModel, child) {
        if (widget.searchQuery.isEmpty) {
          return const SizedBox.shrink();
        }

        final hasRestaurants = homeViewModel.storeData != null &&
            homeViewModel.searchRestaurants(widget.searchQuery).isNotEmpty;

        final hasProducts = productViewModel.products != null &&
            productViewModel.products.where((product) {
              final normalizedQuery = normalizeSearchText(widget.searchQuery);
              final normalizedName = normalizeSearchText(product.name);
              final normalizedMenuName = normalizeSearchText(product.menuName ?? '');
              final normalizedDescription = normalizeSearchText(product.shortDesc ?? '');

              return normalizedName.contains(normalizedQuery) ||
                  normalizedMenuName.contains(normalizedQuery) ||
                  normalizedDescription.contains(normalizedQuery);
            }).isNotEmpty;

        if (!hasRestaurants && !hasProducts) {
          return const Padding(
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
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}