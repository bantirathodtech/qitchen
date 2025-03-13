// // lib/features/search/provider/search_provider.dart
// import 'package:flutter/material.dart';
// import 'dart:async';
// import '../../../categories/provider/categories_provider.dart';
// import '../../../products/model/document.dart';
// import '../state/search_state.dart';
// import '../viewmodel/search_viewmodel.dart';
//
// class SearchProvider extends ChangeNotifier {
//   final SearchViewModel _viewModel;
//   final CategoriesProvider _categoriesProvider;
//   SearchState _state = const SearchState();
//
//   SearchProvider(this._viewModel, this._categoriesProvider);
//
//   SearchState get state => _state;
//   Timer? _debounceTimer;
//
//   void updateSearchQuery(String query) {
//     _state = _state.copyWith(searchQuery: query);
//     notifyListeners();
//
//     _debounceTimer?.cancel();
//     _debounceTimer = Timer(const Duration(milliseconds: 300), () {
//       performSearch(query);
//     });
//   }
//
//   Future<void> performSearch(String query) async {
//     if (query.isEmpty) {
//       _state = const SearchState();
//       notifyListeners();
//       return;
//     }
//
//     _state = _state.copyWith(isLoading: true);
//     notifyListeners();
//
//     try {
//       // Get current categories model from provider
//       final categoriesModel = _categoriesProvider.state.data;
//       if (categoriesModel != null) {
//         final categoryResults = await _viewModel.searchCategories(
//           categoriesModel,
//           query,
//         );
//
//         final productResult = await _viewModel.searchProducts(query);
//
//         final products = productResult.when(
//           success: (data) => data.hits
//               ?.map((hit) => Document.fromJson(hit.document!.toJson() ?? {}))
//               .toList() ?? [],
//           failure: (message, code) {
//             _state = _state.copyWith(error: message);
//             return <Document>[];
//           },
//           loading: () => <Document>[],
//         );
//
//         _state = _state.copyWith(
//           isLoading: false,
//           productResults: products,
//           categoryResults: categoryResults,
//           error: null,
//         );
//       }
//     } catch (e) {
//       _state = _state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//     }
//     notifyListeners();
//   }
//
//   @override
//   void dispose() {
//     _debounceTimer?.cancel();
//     super.dispose();
//   }
// }
// // class SearchProvider extends ChangeNotifier {
// //   final SearchViewModel _viewModel;
// //   SearchState _state = const SearchState();
// //   Timer? _debounceTimer;
// //
// //   SearchProvider(this._viewModel);
// //
// //   SearchState get state => _state;
// //
// //   void updateSearchQuery(String query) {
// //     _state = _state.copyWith(searchQuery: query);
// //     notifyListeners();
// //
// //     // Debounce search
// //     _debounceTimer?.cancel();
// //     _debounceTimer = Timer(const Duration(milliseconds: 300), () {
// //       performSearch(query);
// //     });
// //   }
// //
// //   Future<void> performSearch(String query) async {
// //     if (query.isEmpty) {
// //       _state = const SearchState();
// //       notifyListeners();
// //       return;
// //     }
// //
// //     _state = _state.copyWith(isLoading: true);
// //     notifyListeners();
// //
// //     try {
// //       // Search categories
// //       final categoryResults = await _viewModel.searchCategories(
// //         categoriesModel, // You'll need to get this from somewhere
// //         query,
// //       );
// //
// //       // Search products
// //       final productResult = await _viewModel.searchProducts(query);
// //
// //       final products = productResult.when(
// //         success: (data) => data.hits
// //             ?.map((hit) => Document.fromJson(hit.document!.toJson() ?? {}))
// //             .toList() ?? [],
// //         failure: (message, code) {
// //           _state = _state.copyWith(error: message);
// //           return <Document>[];
// //         },
// //         loading: () => <Document>[],
// //       );
// //
// //       _state = _state.copyWith(
// //         isLoading: false,
// //         productResults: products,
// //         categoryResults: categoryResults,
// //         error: null,
// //       );
// //     } catch (e) {
// //       _state = _state.copyWith(
// //         isLoading: false,
// //         error: e.toString(),
// //       );
// //     }
// //     notifyListeners();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _debounceTimer?.cancel();
// //     super.dispose();
// //   }
// // }