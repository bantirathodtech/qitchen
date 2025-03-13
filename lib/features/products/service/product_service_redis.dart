import '../../../common/log/loggers.dart';
import '../../../core/api/api_base_service.dart';
import '../../../core/api/api_url_manager.dart';
import '../model/product_model.dart';

class ProductService {
  static const String TAG = '[ProductService]';
  final ApiBaseService _apiBaseService;

  ProductService({required ApiBaseService apiBaseService})
      : _apiBaseService = apiBaseService;

  /// Fetch all products for a specific store from Typesense
  Future<List<ProductModel>> fetchProducts(String storeId) async {
    try {
      AppLogger.logInfo(
          '$TAG: Initiating products fetch from Typesense for store: $storeId');

      // Make API call to Typesense endpoint
      final response = await _apiBaseService.sendRestRequest(
        endpoint: AppUrls.getProducts + '/$storeId', // Updated endpoint format
        method: 'GET',
      );

      AppLogger.logInfo('$TAG: Received Typesense API response');

      // Validate response
      if (!_isValidTypesenseResponse(response)) {
        throw ProductServiceException('Invalid Typesense response format');
      }

      // Parse and validate products
      final products = _parseTypesenseProducts(response);
      _validateProducts(products);

      AppLogger.logInfo(
          '$TAG: Successfully fetched ${products.length} products');
      _logProductDetails(products);

      return products;
    } catch (e) {
      _handleError('Failed to fetch products from Typesense', e);
      rethrow;
    }
  }

  bool _isValidTypesenseResponse(dynamic response) {
    if (response == null) {
      AppLogger.logError('$TAG: Null response received');
      return false;
    }

    if (!(response is Map && response.containsKey('hits'))) {
      AppLogger.logError('$TAG: Invalid Typesense response structure');
      return false;
    }

    AppLogger.logDebug('$TAG: Typesense response validation successful');
    return true;
  }

  List<ProductModel> _parseTypesenseProducts(Map<String, dynamic> response) {
    try {
      AppLogger.logInfo('$TAG: Parsing Typesense product response');

      final hits = response['hits'] as List;
      final products = hits
          .map((hit) {
            // Extract items from the document
            final document = hit['document'];
            if (document is Map && document.containsKey('items')) {
              final items = document['items'] as List;
              return items.map((item) => ProductModel.fromJson(item)).toList();
            }
            return <ProductModel>[];
          })
          .expand((x) => x)
          .toList();

      AppLogger.logDebug(
          '$TAG: Successfully parsed ${products.length} products');
      return products;
    } catch (e) {
      throw ProductServiceException('Error parsing Typesense products: $e');
    }
  }

  // Existing validation methods remain the same
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
    final menuNames = products
        .where((p) => p.menuName != null && p.menuName!.isNotEmpty)
        .map((p) => p.menuName!)
        .toSet();
    AppLogger.logInfo('$TAG: Found menus: $menuNames');

    final categoryNames = products
        .where((p) => p.categoryName != null && p.categoryName!.isNotEmpty)
        .map((p) => p.categoryName!)
        .toSet();
    AppLogger.logInfo('$TAG: Found categories: $categoryNames');

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
