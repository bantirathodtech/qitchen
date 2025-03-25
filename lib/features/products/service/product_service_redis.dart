import '../../../common/log/loggers.dart';
import '../../../core/services/base/api_base_service.dart';
import '../../../core/services/endpoints/api_url_manager.dart';
import '../model/product_model.dart';

class ProductService {
  static const String TAG = '[ProductService]';
  final ApiBaseService _apiBaseService;

  ProductService({required ApiBaseService apiBaseService})
      : _apiBaseService = apiBaseService;

  // Step 1: Fetch products from API
  Future<List<ProductModel>> fetchProducts(String storeId) async {
    try {
      AppLogger.logInfo('$TAG: Initiating products fetch for store: $storeId');

      // Step 2: Make API call with query parameters
      final response = await _apiBaseService.sendRestRequest(
        endpoint: AppUrls.getProducts, // Ensure this matches "https://hub.caftrix.cwcloud.in/api/food-ordering/products"
        method: 'GET',
        queryParams: {'commerce_config_id': storeId}, // Matches API structure
      );

      AppLogger.logInfo('$TAG: Received API response');

      // Step 3: Validate response
      if (!_isValidResponse(response)) {
        throw ProductServiceException('Invalid response format');
      }

      // Step 4: Parse products from response
      final products = _parseProducts(response);
      _validateProducts(products);

      AppLogger.logInfo('$TAG: Successfully fetched ${products.length} products');
      _logProductDetails(products);

      return products;
    } catch (e) {
      _handleError('Failed to fetch products', e);
      rethrow;
    }
  }

  // Step 5: Validate API response structure
  bool _isValidResponse(dynamic response) {
    if (response == null) {
      AppLogger.logError('$TAG: Null response received');
      return false;
    }
    try {
      if (response is List) { // API returns a flat list of products
        AppLogger.logDebug('$TAG: Valid flat list response');
        return true;
      }
      AppLogger.logError('$TAG: Invalid response structure - expected a List');
      return false;
    } catch (e) {
      AppLogger.logError('$TAG: Error validating response: $e');
      return false;
    }
  }

  // Step 6: Parse products from response
  List<ProductModel> _parseProducts(dynamic response) {
    try {
      AppLogger.logInfo('$TAG: Parsing product response');
      if (response is! List) {
        AppLogger.logError('$TAG: Expected a List but got ${response.runtimeType}');
        throw ProductServiceException('Invalid response format: Expected List');
      }

      final productList = response;
      final products = <ProductModel>[];

      for (int i = 0; i < productList.length; i++) {
        try {
          AppLogger.logDebug('$TAG: Processing product at index $i');
          final item = productList[i];
          if (item is! Map<String, dynamic>) {
            AppLogger.logError('$TAG: Invalid product format at index $i: ${item.runtimeType}');
            continue;
          }
          final product = ProductModel.fromJson(item);
          products.add(product);
        } catch (parseError) {
          AppLogger.logError('$TAG: Error creating ProductModel at index $i: $parseError');
        }
      }

      AppLogger.logDebug('$TAG: Successfully parsed ${products.length} products');
      return products;
    } catch (e) {
      AppLogger.logError('$TAG: Error in _parseProducts: $e');
      throw ProductServiceException('Error parsing products: $e');
    }
  }

  // Step 7: Validate parsed products
  void _validateProducts(List<ProductModel> products) {
    AppLogger.logInfo('$TAG: Validating product data');
    if (products.isEmpty) {
      AppLogger.logWarning('$TAG: No products found in response');
    }
    for (final product in products) {
      _validateProductData(product);
    }
  }

  // Step 8: Validate individual product data
  void _validateProductData(ProductModel product) {
    final List<String> warnings = [];
    if (product.productId == 'UNKNOWN_ID') warnings.add('Product ID is missing');
    if (product.name == 'Unnamed Product') warnings.add('Product name is missing');
    if (product.categoryId == 'UNKNOWN_CATEGORY') warnings.add('Category ID is missing');
    if (product.unitprice == '0') warnings.add('Invalid unit price');
    if (warnings.isNotEmpty) {
      AppLogger.logWarning('$TAG: Validation warnings for product ${product.name}:\n- ${warnings.join("\n- ")}');
    }
  }

  // Step 9: Log product details for debugging
  void _logProductDetails(List<ProductModel> products) {
    final categoryNames = products.map((p) => p.categoryName).toSet();
    AppLogger.logInfo('$TAG: Found categories: $categoryNames');
    products.take(5).forEach((product) {
      AppLogger.logDebug(
        '$TAG: Product Details:'
            '\n- Name: ${product.name}'
            '\n- Category: ${product.categoryName}'
            '\n- Price: ${product.unitprice}',
      );
    });
  }

  // Step 10: Handle errors
  void _handleError(String context, Object error) {
    final message = '$context: $error';
    AppLogger.logError('$TAG: $message');
    throw ProductServiceException(message);
  }
}

/// Custom exception for product service errors
class ProductServiceException implements Exception {
  final String message;

  ProductServiceException(this.message);

  @override
  String toString() => 'ProductServiceException: $message';
}

// import '../../../common/log/loggers.dart';
// import '../../../core/api/api_base_service.dart';
// import '../../../core/api/api_url_manager.dart';
// import '../model/product_model.dart';
//
// class ProductService {
//   static const String TAG = '[ProductService]';
//   final ApiBaseService _apiBaseService;
//
//   ProductService({required ApiBaseService apiBaseService})
//       : _apiBaseService = apiBaseService;
//
//   /// Fetch all products for a specific store
//   Future<List<ProductModel>> fetchProducts(String storeId) async {
//     try {
//       AppLogger.logInfo('$TAG: Initiating products fetch for store: $storeId');
//
//       // Make API call using query parameters instead of path
//       final response = await _apiBaseService.sendRestRequest(
//         endpoint: AppUrls.getProducts,
//         method: 'GET',
//         queryParams: {'commerce_config_id': storeId},  // Use as query parameter
//       );
//
//       AppLogger.logInfo('$TAG: Received API response');
//
//       // Validate response
//       if (!_isValidResponse(response)) {
//         throw ProductServiceException('Invalid response format');
//       }
//
//       // Parse products
//       final products = _parseProducts(response);
//       _validateProducts(products);
//
//       AppLogger.logInfo('$TAG: Successfully fetched ${products.length} products');
//       _logProductDetails(products);
//
//       return products;
//     } catch (e) {
//       _handleError('Failed to fetch products', e);
//       rethrow;
//     }
//   }
//
//   bool _isValidResponse(dynamic response) {
//     if (response == null) {
//       AppLogger.logError('$TAG: Null response received');
//       return false;
//     }
//
//     try {
//       if (response is List) {
//         AppLogger.logDebug('$TAG: Valid flat list response');
//         return true;
//       }
//
//       // Check if it might be a JSON object with a result array
//       if (response is Map<String, dynamic> && response.containsKey('result') && response['result'] is List) {
//         AppLogger.logDebug('$TAG: Found a result array in the response');
//         return true;
//       }
//
//       AppLogger.logError('$TAG: Invalid response structure - expected a List or an object with a result array');
//       return false;
//     } catch (e) {
//       AppLogger.logError('$TAG: Error validating response: $e');
//       return false;
//     }
//   }
//   List<ProductModel> _parseProducts(dynamic response) {
//     try {
//       AppLogger.logInfo('$TAG: Parsing product response');
//       AppLogger.logDebug('$TAG: Response type: ${response.runtimeType}');
//
//       // Ensure response is a valid list structure
//       if (response is! List) {
//         AppLogger.logError('$TAG: Expected a List but got ${response.runtimeType}');
//         throw ProductServiceException('Invalid response format: Expected List but got ${response.runtimeType}');
//       }
//
//       final productList = response;
//       final products = <ProductModel>[];
//
//       for (int i = 0; i < productList.length; i++) {
//         try {
//           AppLogger.logDebug('$TAG: Processing product at index $i');
//           final item = productList[i];
//
//           // Check if item is a map
//           if (item is! Map<String, dynamic>) {
//             AppLogger.logError('$TAG: Invalid product format at index $i: ${item.runtimeType}');
//             continue;
//           }
//
//           // Wrap in a try-catch to isolate issues with individual products
//           try {
//             final product = ProductModel.fromJson(item);
//             products.add(product);
//           } catch (parseError) {
//             AppLogger.logError('$TAG: Error creating ProductModel: $parseError');
//           }
//         } catch (indexError) {
//           AppLogger.logError('$TAG: Error accessing product at index $i: $indexError');
//         }
//       }
//
//       AppLogger.logDebug('$TAG: Successfully parsed ${products.length} products');
//       return products;
//     } catch (e) {
//       AppLogger.logError('$TAG: Error in _parseProducts: $e');
//       throw ProductServiceException('Error parsing products: $e');
//     }
//   }
//   void _validateProducts(List<ProductModel> products) {
//     AppLogger.logInfo('$TAG: Validating product data');
//
//     if (products.isEmpty) {
//       AppLogger.logWarning('$TAG: No products found in response');
//     }
//
//     for (final product in products) {
//       _validateProductData(product);
//     }
//   }
//
//   void _validateProductData(ProductModel product) {
//     final List<String> warnings = [];
//
//     if (product.productId.isEmpty) {
//       warnings.add('Product ID is empty');
//     }
//
//     if (product.name.isEmpty) {
//       warnings.add('Product name is empty');
//     }
//
//     if (product.categoryId.isEmpty) {
//       warnings.add('Category ID is empty');
//     }
//
//     if (product.unitprice.isEmpty || product.unitprice == '0') {
//       warnings.add('Invalid unit price');
//     }
//
//     if (warnings.isNotEmpty) {
//       AppLogger.logWarning(
//         '$TAG: Validation warnings for product ${product.name}:'
//             '\n- ${warnings.join("\n- ")}',
//       );
//     }
//   }
//
//   void _logProductDetails(List<ProductModel> products) {
//     final menuNames = products
//         .where((p) => p.menuName != null && p.menuName!.isNotEmpty)
//         .map((p) => p.menuName!)
//         .toSet();
//     AppLogger.logInfo('$TAG: Found menus: $menuNames');
//
//     final categoryNames = products
//         .where((p) => p.categoryName != null && p.categoryName.isNotEmpty)
//         .map((p) => p.categoryName)
//         .toSet();
//     AppLogger.logInfo('$TAG: Found categories: $categoryNames');
//
//     products.take(5).forEach((product) {
//       AppLogger.logDebug(
//         '$TAG: Product Details:'
//             '\n- Name: ${product.name}'
//             '\n- Category: ${product.categoryName}'
//             '\n- Menu: ${product.menuName}'
//             '\n- Price: ${product.unitprice}',
//       );
//     });
//   }
//
//   void _handleError(String context, Object error) {
//     final message = '$context: $error';
//     AppLogger.logError('$TAG: $message');
//     throw ProductServiceException(message);
//   }
// }
//
// /// Custom exception for product service errors
// class ProductServiceException implements Exception {
//   final String message;
//
//   ProductServiceException(this.message);
//
//   @override
//   String toString() => 'ProductServiceException: $message';
// }