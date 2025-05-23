import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../products/model/product_model.dart';
import '../products/viewmodel/product_viewmodel.dart';
import '../products/widgets/product_card.dart';

// Helper function to normalize text for searching
String normalizeSearchText(String text) {
  return text
      .toLowerCase()
      .replaceAll('-', '') // Remove dashes
      .replaceAll('_', '') // Remove underscores (optional)
      .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
      .trim();
}

class SearchBarSection extends StatefulWidget {
  final Function(String) onSearch;

  const SearchBarSection({
    super.key,
    required this.onSearch,
  });

  @override
  State<SearchBarSection> createState() => _SearchBarSectionState();
}

class _SearchBarSectionState extends State<SearchBarSection> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;

  void _handleSearch(String value) {
    final normalizedValue = normalizeSearchText(value);
    setState(() {
      isSearching = normalizedValue.isNotEmpty;
    });
    widget.onSearch(normalizedValue);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, productViewModel, child) {
        List<ProductModel> filteredProducts = [];

        if (isSearching && productViewModel.products != null) {
          final searchText = normalizeSearchText(_searchController.text);
          filteredProducts = productViewModel.products!.where((product) {
            final normalizedName = normalizeSearchText(product.name);
            final normalizedMenuName =
                normalizeSearchText(product.menuName ?? '');
            final normalizedDescription =
                normalizeSearchText(product.shortDesc ?? '');

            return normalizedName.contains(searchText) ||
                normalizedMenuName.contains(searchText) ||
                normalizedDescription.contains(searchText);
          }).toList();
        }

        return Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search restaurants or dishes...',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _handleSearch('');
                          },
                        )
                      : null,
                ),
                onChanged: _handleSearch,
              ),
            ),

            // Product Results
            if (isSearching && filteredProducts.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Matching Dishes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...filteredProducts.map((product) {
                return ProductCard(
                  product: product,
                  restaurantName: product.menuName ?? '',
                  // csBunitId: '',
                  onTap: () {},
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

///TODO: with this I was trying to keep modular but not able to search
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../products/model/product_model.dart';
// import '../products/viewmodel/product_viewmodel.dart';
// import '../products/widgets/product_card.dart';
// import '../store/model/store_models.dart';
// import '../store/view/widgets/restaurant_card.dart';
//
// // Helper function to normalize text for searching
// class SearchUtils {
//   static String normalizeText(String text) {
//     final spacelessVersion = text
//         .toLowerCase()
//         .replaceAll('-', '')
//         .replaceAll('_', '')
//         .replaceAll(RegExp(r'\s+'), '')
//         .trim();
//
//     final spacedVersion = text
//         .toLowerCase()
//         .replaceAll('-', ' ')
//         .replaceAll('_', ' ')
//         .replaceAll(RegExp(r'\s+'), ' ')
//         .trim();
//
//     return '$spacelessVersion $spacedVersion';
//   }
//
//   static bool matchesSearch(String source, String query) {
//     final normalizedSource = normalizeText(source);
//     final normalizedQuery = normalizeText(query);
//     return normalizedSource.contains(normalizedQuery);
//   }
// }
//
// class SearchBarSection extends StatefulWidget {
//   final Function(String) onSearch;
//   final List<RestaurantModel>? restaurants;
//   final Function(RestaurantModel)? onRestaurantSelected;
//
//   const SearchBarSection({
//     super.key,
//     required this.onSearch,
//     this.restaurants,
//     this.onRestaurantSelected,
//   });
//
//   @override
//   State<SearchBarSection> createState() => _SearchBarSectionState();
// }
//
// class _SearchBarSectionState extends State<SearchBarSection> {
//   final TextEditingController _searchController = TextEditingController();
//   bool isSearching = false;
//   List<RestaurantModel> filteredRestaurants = [];
//
//   void _handleSearch(String value) {
//     final searchText = value.trim();
//     setState(() {
//       isSearching = searchText.isNotEmpty;
//
//       // Filter restaurants if available
//       if (widget.restaurants != null) {
//         filteredRestaurants = searchText.isEmpty
//             ? []
//             : widget.restaurants!.where((restaurant) {
//                 return SearchUtils.matchesSearch(restaurant.name, searchText) ||
//                     SearchUtils.matchesSearch(
//                         restaurant.shortDescription ?? '', searchText);
//               }).toList();
//       }
//     });
//
//     widget.onSearch(searchText);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ProductViewModel>(
//       builder: (context, productViewModel, child) {
//         List<ProductModel> filteredProducts = [];
//
//         if (isSearching && productViewModel.products != null) {
//           final searchText = _searchController.text;
//           filteredProducts = productViewModel.products!.where((product) {
//             return SearchUtils.matchesSearch(product.name, searchText) ||
//                 SearchUtils.matchesSearch(product.menuName ?? '', searchText) ||
//                 SearchUtils.matchesSearch(product.shortDesc ?? '', searchText);
//           }).toList();
//         }
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Search Bar
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search restaurants or dishes...',
//                   border: InputBorder.none,
//                   prefixIcon: const Icon(Icons.search),
//                   suffixIcon: _searchController.text.isNotEmpty
//                       ? IconButton(
//                           icon: const Icon(Icons.clear),
//                           onPressed: () {
//                             _searchController.clear();
//                             _handleSearch('');
//                           },
//                         )
//                       : null,
//                 ),
//                 onChanged: _handleSearch,
//               ),
//             ),
//
//             // Restaurant Results
//             if (isSearching &&
//                 filteredRestaurants.isNotEmpty &&
//                 widget.onRestaurantSelected != null) ...[
//               const SizedBox(height: 16),
//               const Padding(
//                 padding: EdgeInsets.only(bottom: 8),
//                 child: Text(
//                   'Matching Restaurants',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               ...filteredRestaurants.map((restaurant) {
//                 return RestaurantCard(
//                   restaurant: restaurant,
//                   onTap: () => widget.onRestaurantSelected?.call(restaurant),
//                 );
//               }).toList(),
//               const SizedBox(height: 16),
//             ],
//
//             // Product Results
//             if (isSearching && filteredProducts.isNotEmpty) ...[
//               const SizedBox(height: 16),
//               const Padding(
//                 padding: EdgeInsets.only(bottom: 8),
//                 child: Text(
//                   'Matching Dishes',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               ...filteredProducts.map((product) {
//                 return ProductCard(
//                   product: product,
//                   restaurantName: product.menuName ?? '',
//                   csBunitId: '',
//                   onTap: () {},
//                 );
//               }).toList(),
//               const SizedBox(height: 16),
//             ],
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }
///TODO: with this only search with name not dash
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// //
// // import '../products/model/product_model.dart';
// // import '../products/viewmodel/product_viewmodel.dart';
// // import '../products/widgets/product_card.dart';
// //
// // class SearchBarSection extends StatefulWidget {
// //   final Function(String) onSearch;
// //
// //   const SearchBarSection({
// //     super.key,
// //     required this.onSearch,
// //   });
// //
// //   @override
// //   State<SearchBarSection> createState() => _SearchBarSectionState();
// // }
// //
// // class _SearchBarSectionState extends State<SearchBarSection> {
// //   final TextEditingController _searchController = TextEditingController();
// //   bool isSearching = false;
// //
// //   void _handleSearch(String value) {
// //     setState(() {
// //       isSearching = value.isNotEmpty;
// //     });
// //     widget.onSearch(value);
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Consumer<ProductViewModel>(
// //       builder: (context, productViewModel, child) {
// //         List<ProductModel> filteredProducts = [];
// //
// //         if (isSearching && productViewModel.products != null) {
// //           filteredProducts =
// //               productViewModel.searchProducts(_searchController.text);
// //         }
// //
// //         return Column(
// //           children: [
// //             // Search Bar
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 16),
// //               decoration: BoxDecoration(
// //                 color: Colors.grey[200],
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: TextField(
// //                 controller: _searchController,
// //                 decoration: InputDecoration(
// //                   hintText: 'Search restaurants or dishes...',
// //                   border: InputBorder.none,
// //                   prefixIcon: const Icon(Icons.search),
// //                   suffixIcon: _searchController.text.isNotEmpty
// //                       ? IconButton(
// //                           icon: const Icon(Icons.clear),
// //                           onPressed: () {
// //                             _searchController.clear();
// //                             _handleSearch('');
// //                           },
// //                         )
// //                       : null,
// //                 ),
// //                 onChanged: _handleSearch,
// //               ),
// //             ),
// //
// //             // Product Results
// //             if (isSearching && filteredProducts.isNotEmpty) ...[
// //               const SizedBox(height: 16),
// //               const Padding(
// //                 padding: EdgeInsets.only(bottom: 8),
// //                 child: Text(
// //                   'Matching Dishes',
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //               ...filteredProducts.map((product) {
// //                 return ProductCard(
// //                   product: product,
// //                   restaurantName: product.menuName ?? '',
// //                   csBunitId: '',
// //                   onTap: () {},
// //                 );
// //               }).toList(),
// //               const SizedBox(height: 16),
// //             ],
// //           ],
// //         );
// //       },
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     _searchController.dispose();
// //     super.dispose();
// //   }
// // }
