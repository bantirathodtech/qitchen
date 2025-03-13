// import 'package:flutter/material.dart';
//
// import '../8/recent_searches.dart';
// import '../9/search_results.dart';
//
// class SearchOverlayBody extends StatelessWidget {
//   final String searchQuery;
//
//   const SearchOverlayBody({super.key, required this.searchQuery});
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const RecentSearches(),
//           if (searchQuery.isNotEmpty) SearchResults(searchQuery: searchQuery),
//         ],
//       ),
//     );
//   }
// }
