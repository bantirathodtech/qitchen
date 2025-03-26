import '../../../../common/log/loggers.dart';

class ProductModel {
  static const String TAG = '[ProductModel]';

  final String productId; // Unique identifier for the product
  final String categoryId; // Category ID of the product
  final String categoryName; // Name of the category (e.g., "Breakfast")
  final String? groupId; // Group ID, nullable as it’s often null in response
  final String? locationId; // Location ID, nullable
  final String? sku; // Stock Keeping Unit, nullable with default
  final String name; // Product name (e.g., "GHEE RAVA PODI DOSA")
  final String? menuName; // Menu name, nullable
  final String? availableStartTime; // Start time of availability, nullable
  final String? availableEndTime; // End time of availability, nullable
  final List<TaxCategory>? taxCategories; // List of tax categories, nullable
  final String? productioncenter; // Production center, nullable
  final String? preparationtime; // Preparation time, nullable
  final String preorder; // Preorder status (e.g., "N" or "Y")
  final String? shortDesc; // Short description, nullable with default
  final String veg; // Vegetarian status (e.g., "N" or "Y")
  final String unitprice; // Unit price, defaults to "0" if null
  final String listprice; // List price, defaults to "0" if null
  final String? imageUrl; // Image URL, nullable
  final String bestseller; // Bestseller status (e.g., "N" or "Y")
  final String? available; // Availability status, nullable
  final String? availableFrom; // Availability start date, nullable
  final String? availableTo; // Availability end date, nullable
  final String? nextAvailableFrom; // Next availability start, nullable
  final String? nextAvailableTo; // Next availability end, nullable
  final List<AddOnGroup>? addOnGroups; // Add-on groups, nullable
  final List<AttributeGroup>? attributeGroups; // Attribute groups, nullable
  final List<String>? ingredients; // Ingredients list, nullable
  bool? isFavorite; // Favorite status, nullable

  ProductModel({
    required this.productId,
    required this.categoryId,
    required this.categoryName,
    this.groupId,
    this.locationId,
    this.sku,
    required this.name,
    this.menuName,
    this.availableStartTime,
    this.availableEndTime,
    this.taxCategories,
    this.productioncenter,
    this.preparationtime,
    required this.preorder,
    this.shortDesc,
    required this.veg,
    required this.unitprice,
    required this.listprice,
    this.imageUrl,
    required this.bestseller,
    this.available,
    this.availableFrom,
    this.availableTo,
    this.nextAvailableFrom,
    this.nextAvailableTo,
    this.addOnGroups,
    this.attributeGroups,
    this.ingredients,
    this.isFavorite,
  });

  // Step 1: Factory constructor to parse JSON response into ProductModel
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    AppLogger.logDebug('$TAG: Creating ProductModel from JSON');

    try {
      return ProductModel(
        // Step 2: Parse required fields with defaults if null
        productId: json['product_id']?.toString() ?? 'UNKNOWN_ID', // Default if null
        categoryId: json['category_id']?.toString() ?? 'UNKNOWN_CATEGORY', // Default if null
        categoryName: json['categoryName']?.toString() ?? 'Uncategorized', // Default from response
        // Step 3: Nullable fields remain as-is
        groupId: json['group_id']?.toString(),
        locationId: json['location_id']?.toString(),
        sku: json['sku']?.toString() ?? 'N/A', // Default if null
        name: json['name']?.toString() ?? 'Unnamed Product', // Default if null
        menuName: json['menuName']?.toString(),
        availableStartTime: json['available_start_time']?.toString(),
        availableEndTime: json['available_end_time']?.toString(),
        // Step 4: Parse nested tax categories
        taxCategories: _parseTaxCategories(json['taxCategories']),
        productioncenter: json['productioncenter']?.toString(),
        preparationtime: json['preparationtime']?.toString(),
        preorder: json['preorder']?.toString() ?? 'N', // Default to "N" if null
        shortDesc: json['short_desc']?.toString() ?? 'No description available', // Default if null
        veg: json['veg']?.toString() ?? 'N', // Default to "N" if null (assuming non-veg by default)
        unitprice: json['unitprice']?.toString() ?? '0', // Default to "0" if null
        listprice: json['listprice']?.toString() ?? '0', // Default to "0" if null
        imageUrl: json['imageUrl']?.toString(),
        bestseller: json['bestseller']?.toString() ?? 'N', // Default to "N" if null
        available: json['available']?.toString() ?? 'Y', // Default to "Y" if null (assuming available)
        availableFrom: json['available_from']?.toString(),
        availableTo: json['available_to']?.toString(),
        nextAvailableFrom: json['next_available_from']?.toString(),
        nextAvailableTo: json['next_available_to']?.toString(),
        // Step 5: Parse nested lists
        addOnGroups: _parseAddOnGroups(json['add_on_group']),
        attributeGroups: _parseAttributeGroups(json['attributeGroup']),
        ingredients: (() {
          try {
            final ingredientsData = json['ingredients'];
            if (ingredientsData == null) return null;
            if (ingredientsData is List) {
              return List<String>.from(ingredientsData.map((i) => i?.toString() ?? ''));
            } else {
              AppLogger.logWarning('$TAG: Ingredients is not a List: ${ingredientsData.runtimeType}');
              return null;
            }
          } catch (e) {
            AppLogger.logError('$TAG: Error parsing ingredients: $e');
            return null;
          }
        })(),
        // Step 6: Parse optional favorite status
        isFavorite: json['isFavorite'] == 'true' || json['isFavorite'] == true,
      );
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing ProductModel: $e');
      rethrow;
    }
  }

  // Step 7: Convert ProductModel back to JSON for serialization
  Map<String, dynamic> toJson() {
    AppLogger.logDebug('$TAG: Converting ProductModel to JSON');
    return {
      'product_id': productId,
      'category_id': categoryId,
      'categoryName': categoryName,
      'group_id': groupId,
      'location_id': locationId,
      'sku': sku,
      'name': name,
      'menuName': menuName,
      'available_start_time': availableStartTime,
      'available_end_time': availableEndTime,
      'taxCategories': taxCategories?.map((e) => e.toJson()).toList(),
      'productioncenter': productioncenter,
      'preparationtime': preparationtime,
      'preorder': preorder,
      'short_desc': shortDesc,
      'veg': veg,
      'unitprice': unitprice,
      'listprice': listprice,
      'imageUrl': imageUrl,
      'bestseller': bestseller,
      'available': available,
      'available_from': availableFrom,
      'available_to': availableTo,
      'next_available_from': nextAvailableFrom,
      'next_available_to': nextAvailableTo,
      'add_on_group': addOnGroups?.map((e) => e.toJson()).toList(),
      'attributeGroup': attributeGroups?.map((e) => e.toJson()).toList(),
      'ingredients': ingredients,
      'isFavorite': isFavorite == true ? 'true' : 'false',
    };
  }

  // Step 8: Helper method to parse tax categories
  static List<TaxCategory>? _parseTaxCategories(dynamic json) {
    if (json == null) {
      AppLogger.logDebug('$TAG: No tax categories to parse');
      return null;
    }
    try {
      AppLogger.logDebug('$TAG: Parsing tax categories');
      if (json is! List) {
        AppLogger.logError('$TAG: Expected List for taxCategories but got ${json.runtimeType}');
        return null;
      }
      final result = <TaxCategory>[];
      for (int i = 0; i < json.length; i++) {
        try {
          final item = json[i];
          if (item is Map<String, dynamic>) {
            result.add(TaxCategory.fromJson(item));
          } else {
            AppLogger.logError('$TAG: Invalid tax category format at index $i: ${item.runtimeType}');
          }
        } catch (itemError) {
          AppLogger.logError('$TAG: Error parsing tax category at index $i: $itemError');
        }
      }
      return result;
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing tax categories: $e');
      return null;
    }
  }

  // Step 9: Helper method to parse add-on groups
  static List<AddOnGroup>? _parseAddOnGroups(dynamic json) {
    if (json == null) {
      AppLogger.logDebug('$TAG: No addon groups to parse');
      return null;
    }
    try {
      AppLogger.logDebug('$TAG: Parsing addon groups');
      if (json is! List) {
        AppLogger.logError('$TAG: Expected List for addon groups but got ${json.runtimeType}');
        return null;
      }
      return json.map((e) => AddOnGroup.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing addon groups: $e');
      return null;
    }
  }

  // Step 10: Helper method to parse attribute groups
  static List<AttributeGroup>? _parseAttributeGroups(dynamic json) {
    if (json == null) {
      AppLogger.logDebug('$TAG: No attribute groups to parse');
      return null;
    }
    try {
      AppLogger.logDebug('$TAG: Parsing attribute groups');
      if (json is! List) {
        AppLogger.logError('$TAG: Expected List for attribute groups but got ${json.runtimeType}');
        return null;
      }
      return json.map((e) => AttributeGroup.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing attribute groups: $e');
      return null;
    }
  }
}

// Step 11: TaxCategory class for nested tax data
class TaxCategory {
  static const String TAG = '[TaxCategory]';

  final String name; // Tax name (e.g., "GST 5%")
  final double taxRate; // Tax rate (e.g., 5.0)
  final String csTaxcategoryID; // Tax category ID
  final String? parentTaxId; // Parent tax ID, nullable

  TaxCategory({
    required this.name,
    required this.taxRate,
    required this.csTaxcategoryID,
    this.parentTaxId,
  });

  factory TaxCategory.fromJson(Map<String, dynamic> json) {
    AppLogger.logDebug('$TAG: Creating TaxCategory from JSON');
    try {
      return TaxCategory(
        name: json['name']?.toString() ?? 'Unknown Tax', // Default if null
        taxRate: (json['taxRate'] is num)
            ? json['taxRate'].toDouble()
            : double.tryParse(json['taxRate']?.toString() ?? '0') ?? 0.0, // Default to 0.0
        csTaxcategoryID: json['csTaxcategoryID']?.toString() ?? 'UNKNOWN_TAX_ID', // Default if null
        parentTaxId: json['parentTaxId']?.toString(),
      );
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing TaxCategory: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    AppLogger.logDebug('$TAG: Converting TaxCategory to JSON');
    return {
      'name': name,
      'taxRate': taxRate,
      'csTaxcategoryID': csTaxcategoryID,
      'parentTaxId': parentTaxId,
    };
  }
}

// Step 12: AddOnGroup class (unchanged as API response has null add_on_group)
class AddOnGroup {
  static const String TAG = '[AddOnGroup]';
  final String id;
  final String type;
  final String name;
  final int minqty;
  final int maxqty;
  final List<AddOnItem> addOnItems;

  AddOnGroup({
    required this.id,
    required this.type,
    required this.name,
    required this.minqty,
    required this.maxqty,
    required this.addOnItems,
  });

  factory AddOnGroup.fromJson(Map<String, dynamic> json) {
    AppLogger.logDebug('$TAG: Creating AddOnGroup from JSON');
    try {
      return AddOnGroup(
        id: json['id']?.toString() ?? 'UNKNOWN_ADDON_ID', // Default if null
        type: json['type']?.toString() ?? 'Unknown', // Default if null
        name: json['name']?.toString() ?? 'Unnamed AddOn', // Default if null
        minqty: _parseInt(json['minqty']) ?? 0, // Default to 0
        maxqty: _parseInt(json['maxqty']) ?? 0, // Default to 0
        addOnItems: _parseAddOnItems(json['addOnItems']),
      );
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing AddOnGroup: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    AppLogger.logDebug('$TAG: Converting AddOnGroup to JSON');
    return {
      'id': id,
      'type': type,
      'name': name,
      'minqty': minqty,
      'maxqty': maxqty,
      'addOnItems': addOnItems.map((item) => item.toJson()).toList(),
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static List<AddOnItem> _parseAddOnItems(dynamic json) {
    if (json == null) {
      AppLogger.logDebug('$TAG: No addon items to parse');
      return [];
    }
    try {
      AppLogger.logDebug('$TAG: Parsing addon items');
      if (json is! List) {
        AppLogger.logError('$TAG: Expected List for addon items but got ${json.runtimeType}');
        return [];
      }
      return json.map((e) => AddOnItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing addon items: $e');
      return [];
    }
  }
}

// Step 13: AddOnItem class (unchanged)
class AddOnItem {
  static const String TAG = '[AddOnItem]';
  final String id;
  final String name;
  final String price;

  AddOnItem({
    required this.id,
    required this.name,
    required this.price,
  });

  factory AddOnItem.fromJson(Map<String, dynamic> json) {
    AppLogger.logDebug('$TAG: Creating AddOnItem from JSON');
    try {
      return AddOnItem(
        id: json['id']?.toString() ?? 'UNKNOWN_ITEM_ID', // Default if null
        name: json['name']?.toString() ?? 'Unnamed Item', // Default if null
        price: json['price']?.toString() ?? '0', // Default to "0"
      );
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing AddOnItem: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    AppLogger.logDebug('$TAG: Converting AddOnItem to JSON');
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}

// Step 14: AttributeGroup class (unchanged as API response has null attributeGroup)
class AttributeGroup {
  static const String TAG = '[AttributeGroup]';
  final String id;
  final String name;
  final List<Attribute> attributes;

  AttributeGroup({
    required this.id,
    required this.name,
    required this.attributes,
  });

  factory AttributeGroup.fromJson(Map<String, dynamic> json) {
    AppLogger.logDebug('$TAG: Creating AttributeGroup from JSON');
    try {
      return AttributeGroup(
        id: json['id']?.toString() ?? 'UNKNOWN_ATTR_ID', // Default if null
        name: json['name']?.toString() ?? 'Unnamed Attribute', // Default if null
        attributes: _parseAttributes(json['attribute']),
      );
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing AttributeGroup: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    AppLogger.logDebug('$TAG: Converting AttributeGroup to JSON');
    return {
      'id': id,
      'name': name,
      'attribute': attributes.map((attribute) => attribute.toJson()).toList(),
    };
  }

  static List<Attribute> _parseAttributes(dynamic json) {
    if (json == null) {
      AppLogger.logDebug('$TAG: No attributes to parse');
      return [];
    }
    try {
      AppLogger.logDebug('$TAG: Parsing attributes');
      if (json is! List) {
        AppLogger.logError('$TAG: Expected List for attributes but got ${json.runtimeType}');
        return [];
      }
      return json.map((e) => Attribute.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing attributes: $e');
      return [];
    }
  }
}

// Step 15: Attribute class (unchanged)
class Attribute {
  static const String TAG = '[Attribute]';
  final String id;
  final String value;
  final String name;

  Attribute({
    required this.id,
    required this.value,
    required this.name,
  });

  factory Attribute.fromJson(Map<String, dynamic> json) {
    AppLogger.logDebug('$TAG: Creating Attribute from JSON');
    try {
      return Attribute(
        id: json['id']?.toString() ?? 'UNKNOWN_ATTR_ID', // Default if null
        value: json['value']?.toString() ?? 'Unknown Value', // Default if null
        name: json['name']?.toString() ?? 'Unnamed Attribute', // Default if null
      );
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing Attribute: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    AppLogger.logDebug('$TAG: Converting Attribute to JSON');
    return {
      'id': id,
      'value': value,
      'name': name,
    };
  }
}
