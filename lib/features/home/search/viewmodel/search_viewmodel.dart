// // lib/features/search/viewmodel/search_viewmodel.dart
// import '../../../../core/api/base/result/operation_result.dart';
// import '../../../categories/model/categories_model.dart';
// import '../../../categories/viewmodel/categories_viewmodel.dart';
// import '../../../products/model/products_model.dart';
// import '../../../products/products_card/viewmodel/products_viewmodel.dart';
// import '../state/search_state.dart';
//
// class SearchViewModel {
//   final CategoriesViewModel _categoriesViewModel;
//   final ProductsViewModel _productsViewModel;
//
//   SearchViewModel(this._categoriesViewModel, this._productsViewModel);
//
//   Future<List<CategorySearchResult>> searchCategories(
//     CategoriesModel categoriesModel,
//     String query,
//   ) async {
//     if (query.isEmpty) return [];
//
//     final lowercaseQuery = query.toLowerCase();
//     final results = <CategołrySearchResult>[];
//
// // Search in first level categories
//     final firstLevelCategories =
//         _categoriesViewModel.getFirstLevelCategories(categoriesModel);
//     for (final category in firstLevelCategories) {
//       if (category.toLowerCase().contains(lowercaseQuery)) {
//         results.add(CategorySearchResult(
//           name: category,
//           level: 'first',
//         ));
//       }
//     }
//
// // Search in second level categories
//     for (final firstLevel in firstLevelCategories) {
//       final secondLevelCategories =
//           _categoriesViewModel.getSecondLevelCategories(
//         categoriesModel,
//         firstLevel,
//       );
//       for (final category in secondLevelCategories) {
//         if (category.name?.toLowerCase().contains(lowercaseQuery) ?? false) {
//           results.add(CategorySearchResult(
//             name: category.name ?? '',
//             level: 'second',
//             parentName: firstLevel,
//             categoryId: category.categoryId,
//           ));
//         }
//       }
//
// // Search in third level categories
//       for (final secondLevel in secondLevelCategories) {
//         final thirdLevelCategories =
//             _categoriesViewModel.getThirdLevelCategories(
//           categoriesModel,
//           firstLevel,
//           secondLevel.name ?? '',
//         );
//         for (final category in thirdLevelCategories) {
//           if (category.categoryName?.toLowerCase().contains(lowercaseQuery) ??
//               false) {
//             results.add(CategorySearchResult(
//               name: category.categoryName ?? '',
//               level: 'third',
//               parentName: '${firstLevel} > ${secondLevel.name}',
//               categoryId: category.categoryId,
//             ));
//           }
//         }
//       }
//     }
//
//     return results;
//   }
//
//   // Future<OperationResult<ProductsModel>> searchProducts(String query) async {
// // Implement product search using ProductsViewModel
// // You might need to add a search method in your ProductsViewModel
// //     return await _productsViewModel.searchProducts(query);
// //   }
// }
