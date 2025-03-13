// // lib/features/search/state/search_state.dart
// import 'package:flutter/foundation.dart';
// // import '../../../products/model/document.dart';
//
// @immutable
// class SearchState {
//   final bool isLoading;
//   final String searchQuery;
//   // final List<Document> productResults;
//   final List<CategorySearchResult> categoryResults;
//   final String? error;
//
//   const SearchState({
//     this.isLoading = false,
//     this.searchQuery = '',
//     // this.productResults = const [],
//     this.categoryResults = const [],
//     this.error,
//   });
//
//   SearchState copyWith({
//     bool? isLoading,
//     String? searchQuery,
//     // List<Document>? productResults,
//     List<CategorySearchResult>? categoryResults,
//     String? error,
//   }) {
//     return SearchState(
//       isLoading: isLoading ?? this.isLoading,
//       searchQuery: searchQuery ?? this.searchQuery,
//       // productResults: productResults ?? this.productResults,
//       categoryResults: categoryResults ?? this.categoryResults,
//       error: error ?? this.error,
//     );
//   }
// }
//
// class CategorySearchResult {
//   final String name;
//   final String level;
//   final String? parentName;
//   final String? categoryId;
//
//   CategorySearchResult({
//     required this.name,
//     required this.level,
//     this.parentName,
//     this.categoryId,
//   });
// }