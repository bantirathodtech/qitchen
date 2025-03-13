// // lib/features/search/widgets/search_results_widget.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../products/products_card/card/product_card.dart';
// import '../provider/search_provider.dart';
//
// class SearchResultsWidget extends StatelessWidget {
//   const SearchResultsWidget({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<SearchProvider>(
//       builder: (context, provider, child) {
//         final state = provider.state;
//
//         if (state.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (state.error != null) {
//           return Center(child: Text(state.error!));
//         }
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (state.categoryResults.isNotEmpty) ...[
//               const Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Text(
//                   'Categories',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF413D32),
//                   ),
//                 ),
//               ),
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: state.categoryResults.length,
//                 itemBuilder: (context, index) {
//                   final category = state.categoryResults[index];
//                   return ListTile(
//                     leading: const Icon(Icons.category),
//                     title: Text(category.name),
//                     subtitle: category.parentName != null
//                         ? Text(category.parentName!)
//                         : null,
//                     onTap: () {
//                       // Handle category selection
//                     },
//                   );
//                 },
//               ),
//             ],
//             if (state.productResults.isNotEmpty) ...[
//               const Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Text(
//                   'Products',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF413D32),
//                   ),
//                 ),
//               ),
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio: 0.7,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                 ),
//                 itemCount: state.productResults.length,
//                 itemBuilder: (context, index) {
//                   final product = state.productResults[index];
//                   return ProductCard(
//                     product: product,
//                     isWishlisted: false, // You'll need to implement this
//                     onWishlistedPressed: () {
//                       // Handle wishlist
//                     },
//                     onAddToCart: (product) {
//                       // Handle add to cart
//                     },
//                     onProductTap: () {
//                       // Handle product tap
//                     },
//                   );
//                 },
//               ),
//             ],
//           ],
//         );
//       },
//     );
//   }
// }