// File: product_model.dart

import '../../../../common/log/loggers.dart';

class ProductModel {
  static const String TAG = '[ProductModel]';

  final String productId;
  final String categoryId;
  final String name;
  final String? menuName;
  final String? categoryName;
  final String veg;
  final String unitprice; // Keep as string from API
  final String? productionCenter; // Add this field
  final String? imageUrl;
  final String? shortDesc;
  final List<AddOnGroup>? addOnGroups;
  final List<AttributeGroup>? attributeGroups;
  bool? isFavorite;

  ProductModel({
    required this.productId,
    required this.categoryId,
    required this.name,
    this.menuName,
    this.categoryName,
    required this.veg,
    required this.unitprice,
    this.productionCenter, // Make it optional
    this.imageUrl,
    this.shortDesc,
    this.addOnGroups,
    this.attributeGroups,
    this.isFavorite,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    AppLogger.logDebug('$TAG: Creating ProductModel from JSON');

    try {
      return ProductModel(
        productId: json['product_id'] ?? '',
        categoryId: json['category_id'] ?? '',
        name: json['name'] ?? '',
        menuName: json['menuName'] ?? json['menu_name'] ?? '',
        categoryName: json['categoryName'] ?? json['category_name'] ?? '',
        veg: json['veg'] ?? 'N',
        unitprice: json['unitprice'] ?? '0',
        productionCenter:
            json['productionCenter'], // Add this field to fromJson
        imageUrl: json['imageUrl'],
        shortDesc: json['short_desc'],
        addOnGroups: _parseAddOnGroups(json['add_on_group']),
        attributeGroups: _parseAttributeGroups(json['attributeGroup']),
        isFavorite: json['isFavorite'] == 'true',
      );
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing ProductModel: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    AppLogger.logDebug('$TAG: Converting ProductModel to JSON');

    return {
      'product_id': productId,
      'category_id': categoryId,
      'name': name,
      'menuName': menuName,
      'categoryName': categoryName,
      'veg': veg,
      'unitprice': unitprice,
      'productionCenter': productionCenter, // Add this field to toJson
      'imageUrl': imageUrl,
      'short_desc': shortDesc,
      'add_on_group': addOnGroups?.map((e) => e.toJson()).toList(),
      'attributeGroup': attributeGroups?.map((e) => e.toJson()).toList(),
    };
  }

  static List<AddOnGroup>? _parseAddOnGroups(dynamic json) {
    if (json == null) {
      AppLogger.logDebug('$TAG: No addon groups to parse');
      return null;
    }

    try {
      AppLogger.logDebug('$TAG: Parsing addon groups');
      return List<AddOnGroup>.from((json as List)
          .map((e) => AddOnGroup.fromJson(e as Map<String, dynamic>)));
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing addon groups: $e');
      return null;
    }
  }

  static List<AttributeGroup>? _parseAttributeGroups(dynamic json) {
    if (json == null) {
      AppLogger.logDebug('$TAG: No attribute groups to parse');
      return null;
    }

    try {
      AppLogger.logDebug('$TAG: Parsing attribute groups');
      return List<AttributeGroup>.from((json as List)
          .map((e) => AttributeGroup.fromJson(e as Map<String, dynamic>)));
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing attribute groups: $e');
      return null;
    }
  }
}

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
        id: json['id'] ?? '',
        type: json['type'] ?? '',
        name: json['name'] ?? '',
        minqty: _parseInt(json['minqty']) ?? 0,
        maxqty: _parseInt(json['maxqty']) ?? 0,
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
      return List<AddOnItem>.from((json as List)
          .map((e) => AddOnItem.fromJson(e as Map<String, dynamic>)));
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing addon items: $e');
      return [];
    }
  }
}

class AddOnItem {
  static const String TAG = '[AddOnItem]';

  final String id;
  final String name;
  final String price; // Keep as string from API

  AddOnItem({
    required this.id,
    required this.name,
    required this.price,
  });

  factory AddOnItem.fromJson(Map<String, dynamic> json) {
    AppLogger.logDebug('$TAG: Creating AddOnItem from JSON');

    try {
      return AddOnItem(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        price: json['price']?.toString() ?? '0',
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
        id: json['id'] ?? '',
        name: json['name'] ?? '',
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
      return List<Attribute>.from((json as List)
          .map((e) => Attribute.fromJson(e as Map<String, dynamic>)));
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing attributes: $e');
      return [];
    }
  }
}

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
        id: json['id'] ?? '',
        value: json['value'] ?? '',
        name: json['name'] ?? '',
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
