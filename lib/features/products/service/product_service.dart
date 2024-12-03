// File: services/product_service.dart

import '../../../../common/log/loggers.dart';
import '../../../../core/api/api_base_service.dart';
import '../../../../core/api/api_url_manager.dart';
import '../model/product_model.dart';

/// Service responsible for handling all product-related API calls
class ProductService {
  static const String TAG = '[ProductService]';
  final ApiBaseService _apiBaseService;

  ProductService({required ApiBaseService apiBaseService})
      : _apiBaseService = apiBaseService;

  /// Fetch all products for a specific store
  Future<List<ProductModel>> fetchProducts(String storeId) async {
    try {
      AppLogger.logInfo('$TAG: Initiating products fetch for store: $storeId');

      // Make API call
      final response = await _apiBaseService.sendRestRequest(
        endpoint: AppUrls.getProducts,
        method: 'GET',
        queryParams: {'commerce_config_id': storeId},
      );

      AppLogger.logInfo('$TAG: Received API response');

      // Validate response
      if (!_isValidResponse(response)) {
        throw ProductServiceException('Invalid response format from API');
      }

      // Parse and validate products
      final products = _parseProducts(response);
      _validateProducts(products);

      // Log successful fetch
      AppLogger.logInfo(
          '$TAG: Successfully fetched ${products.length} products');
      _logProductDetails(products);

      return products;
    } catch (e) {
      _handleError('Failed to fetch products', e);
      rethrow;
    }
  }

  // Private helper methods
  bool _isValidResponse(dynamic response) {
    if (response == null) {
      AppLogger.logError('$TAG: Null response received');
      return false;
    }

    if (response is! List) {
      AppLogger.logError('$TAG: Response is not a list');
      return false;
    }

    AppLogger.logDebug('$TAG: Response validation successful');
    return true;
  }

  List<ProductModel> _parseProducts(List<dynamic> response) {
    try {
      AppLogger.logInfo('$TAG: Parsing product response');

      final products =
          response.map((item) => ProductModel.fromJson(item)).toList();

      AppLogger.logDebug(
          '$TAG: Successfully parsed ${products.length} products');

      return products;
    } catch (e) {
      throw ProductServiceException('Error parsing products: $e');
    }
  }

  void _validateProducts(List<ProductModel> products) {
    AppLogger.logInfo('$TAG: Validating product data');

    if (products.isEmpty) {
      AppLogger.logWarning('$TAG: No products found in response');
    }

    for (final product in products) {
      _validateProductData(product);
    }
  }

  void _validateProductData(ProductModel product) {
    final List<String> warnings = [];

    if (product.productId.isEmpty) {
      warnings.add('Product ID is empty');
    }

    if (product.name.isEmpty) {
      warnings.add('Product name is empty');
    }

    if (product.categoryId.isEmpty) {
      warnings.add('Category ID is empty');
    }

    if (product.unitprice.isEmpty || product.unitprice == '0') {
      warnings.add('Invalid unit price');
    }

    if (warnings.isNotEmpty) {
      AppLogger.logWarning(
        '$TAG: Validation warnings for product ${product.name}:'
        '\n- ${warnings.join("\n- ")}',
      );
    }
  }

  void _logProductDetails(List<ProductModel> products) {
    // Log unique menu names
    final menuNames = products
        .where((p) => p.menuName != null && p.menuName!.isNotEmpty)
        .map((p) => p.menuName!)
        .toSet();
    AppLogger.logInfo('$TAG: Found menus: $menuNames');

    // Log unique category names
    final categoryNames = products
        .where((p) => p.categoryName != null && p.categoryName!.isNotEmpty)
        .map((p) => p.categoryName!)
        .toSet();
    AppLogger.logInfo('$TAG: Found categories: $categoryNames');

    // Log product details for debugging
    products.take(5).forEach((product) {
      AppLogger.logDebug(
        '$TAG: Product Details:'
        '\n- Name: ${product.name}'
        '\n- Category: ${product.categoryName}'
        '\n- Menu: ${product.menuName}'
        '\n- Price: ${product.unitprice}',
      );
    });
  }

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
