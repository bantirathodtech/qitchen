import '../../order_shared_common/models/base_model.dart';

class KitchenOrder implements BaseModel {
  final String customerId;
  final String documentno;
  final String cSBunitID;
  final String customerName;
  final String dateOrdered;
  final String status;
  final List<KitchenOrderItem> line;

  const KitchenOrder({
    required this.customerId,
    required this.documentno,
    required this.cSBunitID,
    required this.customerName,
    required this.dateOrdered,
    required this.status,
    required this.line,
  });

  // Manual deserialization from JSON
  factory KitchenOrder.fromJson(Map<String, dynamic> json) {
    return KitchenOrder(
      customerId: json['customerId'] ?? '',
      documentno: json['documentno'] ?? '',
      cSBunitID: json['cSBunitID'] ?? '',
      customerName: json['customerName'] ?? '',
      dateOrdered: json['dateOrdered'] ?? '',
      status: json['status'] ?? '',
      line: json['line'] == null
          ? []
          : List<KitchenOrderItem>.from(
          (json['line'] as List).map((x) => KitchenOrderItem.fromJson(x))),
    );
  }

  // Manual serialization to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'documentno': documentno,
      'cSBunitID': cSBunitID,
      'customerName': customerName,
      'dateOrdered': dateOrdered,
      'status': status,
      'line': line.map((e) => e.toJson()).toList(),
    };
  }
}

class KitchenOrderItem implements BaseModel {
  final String mProductId;
  final String name;
  final int qty;
  final String notes;
  final String productioncenter;
  final int tokenNumber;
  final String status;
  final List<KitchenOrderAddon> subProducts;

  const KitchenOrderItem({
    required this.mProductId,
    required this.name,
    required this.qty,
    required this.notes,
    required this.productioncenter,
    required this.tokenNumber,
    required this.status,
    required this.subProducts,
  });

  // Manual deserialization from JSON
  factory KitchenOrderItem.fromJson(Map<String, dynamic> json) {
    return KitchenOrderItem(
      mProductId: json['mProductId'] ?? '',
      name: json['name'] ?? '',
      qty: json['qty'] ?? 0,
      notes: json['notes'] ?? '',
      productioncenter: json['productioncenter'] ?? '',
      tokenNumber: json['token_number'] ?? 0, // Match the exact API field name
      status: json['status'] ?? '',
      subProducts: json['subProducts'] == null
          ? []
          : List<KitchenOrderAddon>.from(
          (json['subProducts'] as List).map((x) => KitchenOrderAddon.fromJson(x))),
    );
  }

  // Manual serialization to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'mProductId': mProductId,
      'name': name,
      'qty': qty,
      'notes': notes,
      'productioncenter': productioncenter,
      'token_number': tokenNumber, // Match the exact API field name
      'status': status,
      'subProducts': subProducts.map((e) => e.toJson()).toList(),
    };
  }
}

class KitchenOrderAddon implements BaseModel {
  final String addonProductId;
  final String name;
  final int qty;

  const KitchenOrderAddon({
    required this.addonProductId,
    required this.name,
    required this.qty,
  });

  // Manual deserialization from JSON
  factory KitchenOrderAddon.fromJson(Map<String, dynamic> json) {
    return KitchenOrderAddon(
      addonProductId: json['addonProductId'] ?? '',
      name: json['name'] ?? '',
      qty: json['qty'] ?? 0,
    );
  }

  // Manual serialization to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'addonProductId': addonProductId,
      'name': name,
      'qty': qty,
    };
  }
}

// import 'package:json_annotation/json_annotation.dart';
//
// import 'base_model.dart';
//
// part 'kitchen_order.g.dart';
//
// @JsonSerializable(explicitToJson: true)
// class KitchenOrder implements BaseModel {
//   @JsonKey(name: 'customerId')
//   final String customerId;
//
//   @JsonKey(name: 'documentno')
//   final String documentno;
//
//   @JsonKey(name: 'cSBunitID')
//   final String cSBunitID;
//
//   @JsonKey(name: 'customerName')
//   final String customerName;
//
//   @JsonKey(name: 'dateOrdered')
//   final String dateOrdered;
//
//   @JsonKey(name: 'status')
//   final String status;
//
//   @JsonKey(name: 'line')
//   final List<KitchenOrderItem> line;
//
//   const KitchenOrder({
//     required this.customerId,
//     required this.documentno,
//     required this.cSBunitID,
//     required this.customerName,
//     required this.dateOrdered,
//     required this.status,
//     required this.line,
//   });
//
//   factory KitchenOrder.fromJson(Map<String, dynamic> json) =>
//       _$KitchenOrderFromJson(json);
//
//   @override
//   Map<String, dynamic> toJson() => _$KitchenOrderToJson(this);
// }
//
// @JsonSerializable(explicitToJson: true)
// class KitchenOrderItem implements BaseModel {
//   @JsonKey(name: 'mProductId')
//   final String mProductId;
//
//   @JsonKey(name: 'name')
//   final String name;
//
//   @JsonKey(name: 'qty')
//   final int qty;
//
//   @JsonKey(name: 'notes')
//   final String notes;
//
//   @JsonKey(name: 'productioncenter')
//   final String productioncenter;
//
//   @JsonKey(name: 'token_number') // Match exact API field name
//   final int tokenNumber;
//
//
//   @JsonKey(name: 'status')
//   final String status;
//
//   @JsonKey(name: 'subProducts')
//   final List<KitchenOrderAddon> subProducts;
//
//   const KitchenOrderItem({
//     required this.mProductId,
//     required this.name,
//     required this.qty,
//     required this.notes,
//     required this.productioncenter,
//     required this.tokenNumber,
//     required this.status,
//     required this.subProducts,
//   });
//
//   factory KitchenOrderItem.fromJson(Map<String, dynamic> json) =>
//       _$KitchenOrderItemFromJson(json);
//
//   @override
//   Map<String, dynamic> toJson() => _$KitchenOrderItemToJson(this);
// }
//
// @JsonSerializable(explicitToJson: true)
// class KitchenOrderAddon implements BaseModel {
//   @JsonKey(name: 'addonProductId')
//   final String addonProductId;
//
//   @JsonKey(name: 'name')
//   final String name;
//
//   @JsonKey(name: 'qty')
//   final int qty;
//
//   const KitchenOrderAddon({
//     required this.addonProductId,
//     required this.name,
//     required this.qty,
//   });
//
//   factory KitchenOrderAddon.fromJson(Map<String, dynamic> json) =>
//       _$KitchenOrderAddonFromJson(json);
//
//   @override
//   Map<String, dynamic> toJson() => _$KitchenOrderAddonToJson(this);
// }
