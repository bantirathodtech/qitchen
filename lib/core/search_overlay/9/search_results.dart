// import 'package:flutter/material.dart';
//
// class SearchResults extends StatelessWidget {
//   final String searchQuery;
//
//   const SearchResults({super.key, required this.searchQuery});
//
//   @override
//   Widget build(BuildContext context) {
//     // Implement your search results logic here based on the searchQuery
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: 3,
//       itemBuilder: (context, index) {
//         return ListTile(
//           leading: const Icon(Icons.search, color: Colors.grey),
//           title: Text(
//             'Suggest ${index + 1}',
//             style: const TextStyle(fontSize: 16),
//           ),
//           onTap: () {
//             Navigator.pop(context);
//           },
//         );
//       },
//     );
//   }
// }