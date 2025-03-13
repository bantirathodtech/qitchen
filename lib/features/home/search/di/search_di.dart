// // lib/features/search/di/search_di.dart
// import 'package:get_it/get_it.dart';
// import '../viewmodel/search_viewmodel.dart';
// import '../provider/search_provider.dart';
//
// class SearchDI {
//   static void init(GetIt getIt) {
//     // ViewModels
//     getIt.registerFactory<SearchViewModel>(
//       () => SearchViewModel(
//         getIt(), // CategoriesViewModel
//         getIt(), // ProductsViewModel
//       ),
//     );
//
//     // Providers
//     getIt.registerFactory<SearchProvider>(
//       () => SearchProvider(getIt(), getIt()),
//     );
//   }
// }
