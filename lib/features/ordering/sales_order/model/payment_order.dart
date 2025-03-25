import '../../order_shared_common/models/base_model.dart';

class PaymentOrder implements BaseModel {
  final Order order;

  const PaymentOrder({required this.order});

  // Manual deserialization from JSON
  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      order: Order.fromJson(json['order_shared_common'] ?? {}),
    );
  }

  // Manual serialization to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'order_shared_common': order.toJson(),
    };
  }
}

class Order implements BaseModel {
  final String documentno;
  final String cSBunitID;
  final String dateOrdered;
  final num discAmount;
  final num grosstotal;
  final num taxamt;
  final String mobileNo;
  final String finPaymentmethodId;
  final String isTaxIncluded;
  final List<OrderMetadata> metaData;
  final List<PaymentOrderItem> line;
  final String? customerId;
  final String? customerName;

  const Order({
    required this.documentno,
    required this.cSBunitID,
    required this.dateOrdered,
    required this.discAmount,
    required this.grosstotal,
    required this.taxamt,
    required this.mobileNo,
    required this.finPaymentmethodId,
    required this.isTaxIncluded,
    required this.metaData,
    required this.line,
    this.customerId,
    this.customerName,
  });

  // Manual deserialization from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      documentno: json['documentno'] ?? '',
      cSBunitID: json['cSBunitID'] ?? '',
      dateOrdered: json['dateOrdered'] ?? '',
      discAmount: json['discAmount'] ?? 0,
      grosstotal: json['grosstotal'] ?? 0,
      taxamt: json['taxamt'] ?? 0,
      mobileNo: json['mobileNo'] ?? '',
      finPaymentmethodId: json['finPaymentmethodId'] ?? '',
      isTaxIncluded: json['isTaxIncluded'] ?? '',
      metaData: json['metaData'] == null
          ? []
          : List<OrderMetadata>.from(
          (json['metaData'] as List).map((x) => OrderMetadata.fromJson(x))),
      line: json['line'] == null
          ? []
          : List<PaymentOrderItem>.from(
          (json['line'] as List).map((x) => PaymentOrderItem.fromJson(x))),
      customerId: json['customerId'],
      customerName: json['customerName'],
    );
  }

  // Manual serialization to JSON
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'documentno': documentno,
      'cSBunitID': cSBunitID,
      'dateOrdered': dateOrdered,
      'discAmount': discAmount,
      'grosstotal': grosstotal,
      'taxamt': taxamt,
      'mobileNo': mobileNo,
      'finPaymentmethodId': finPaymentmethodId,
      'isTaxIncluded': isTaxIncluded,
      'metaData': metaData.map((e) => e.toJson()).toList(),
      'line': line.map((e) => e.toJson()).toList(),
    };

    // Only include optional fields if they're not null
    if (customerId != null) data['customerId'] = customerId;
    if (customerName != null) data['customerName'] = customerName;

    return data;
  }
}

class OrderMetadata implements BaseModel {
  final String key;
  final String value;

  const OrderMetadata({
    required this.key,
    required this.value,
  });

  // Manual deserialization from JSON
  factory OrderMetadata.fromJson(Map<String, dynamic> json) {
    return OrderMetadata(
      key: json['key'] ?? '',
      value: json['value'] ?? '',
    );
  }

  // Manual serialization to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }
}

class PaymentOrderItem implements BaseModel {
  final String mProductId;
  final String name;
  final int qty;
  final num unitprice;
  final num linenet;
  final num linetax;
  final num linegross;
  final String? productioncenter;
  final List<PaymentOrderAddon> subProducts;

  const PaymentOrderItem({
    required this.mProductId,
    required this.name,
    required this.qty,
    required this.unitprice,
    required this.linenet,
    required this.linetax,
    required this.linegross,
    this.productioncenter,
    required this.subProducts,
  });

  // Manual deserialization from JSON
  factory PaymentOrderItem.fromJson(Map<String, dynamic> json) {
    return PaymentOrderItem(
      mProductId: json['mProductId'] ?? '',
      name: json['name'] ?? '',
      qty: json['qty'] ?? 0,
      unitprice: json['unitprice'] ?? 0,
      linenet: json['linenet'] ?? 0,
      linetax: json['linetax'] ?? 0,
      linegross: json['linegross'] ?? 0,
      productioncenter: json['productioncenter'],
      subProducts: json['subProducts'] == null
          ? []
          : List<PaymentOrderAddon>.from(
          (json['subProducts'] as List).map((x) => PaymentOrderAddon.fromJson(x))),
    );
  }

  // Manual serialization to JSON
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'mProductId': mProductId,
      'name': name,
      'qty': qty,
      'unitprice': unitprice,
      'linenet': linenet,
      'linetax': linetax,
      'linegross': linegross,
      'subProducts': subProducts.map((e) => e.toJson()).toList(),
    };

    // Only include optional fields if they're not null
    if (productioncenter != null) data['productioncenter'] = productioncenter;

    return data;
  }
}

class PaymentOrderAddon implements BaseModel {
  final String addonProductId;
  final String name;
  final num price;
  final int qty;

  const PaymentOrderAddon({
    required this.addonProductId,
    required this.name,
    required this.qty,
    required this.price,
  });

  // Manual deserialization from JSON
  factory PaymentOrderAddon.fromJson(Map<String, dynamic> json) {
    return PaymentOrderAddon(
      addonProductId: json['addonProductId'] ?? '',
      name: json['name'] ?? '',
      qty: json['qty'] ?? 0,
      price: json['price'] ?? 0,
    );
  }

  // Manual serialization to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'addonProductId': addonProductId,
      'name': name,
      'qty': qty,
      'price': price,
    };
  }
}

// // lib/features/order_shared_common/data/models/payment_order.dart
//
// import 'package:json_annotation/json_annotation.dart';
//
// import 'base_model.dart';
//
// part 'payment_order.g.dart';
//
// @JsonSerializable(explicitToJson: true, includeIfNull: false)
// class PaymentOrder implements BaseModel {
//   final Order order_shared_common;
//
//   const PaymentOrder({required this.order_shared_common});
//
//   factory PaymentOrder.fromJson(Map<String, dynamic> json) =>
//       _$PaymentOrderFromJson(json);
//
//   @override
//   Map<String, dynamic> toJson() => _$PaymentOrderToJson(this);
// }
//
// @JsonSerializable(explicitToJson: true, includeIfNull: false)
// class Order implements BaseModel {
//   @JsonKey(name: 'documentno') // Ensure exact API field name
//   final String documentno;
//
//   @JsonKey(name: 'cSBunitID') // Ensure exact API field name
//   final String cSBunitID;
//
//   @JsonKey(name: 'dateOrdered') // Ensure exact API field name
//   final String dateOrdered;
//
//   @JsonKey(name: 'discAmount') // Ensure exact API field name
//   final num discAmount; // Changed to num to match API
//
//   @JsonKey(name: 'grosstotal') // Ensure exact API field name
//   final num grosstotal; // Changed to num to match API
//
//   @JsonKey(name: 'taxamt') // Ensure exact API field name
//   final num taxamt; // Changed to num to match API
//
//   @JsonKey(name: 'mobileNo') // Ensure exact API field name
//   final String mobileNo;
//
//   @JsonKey(name: 'finPaymentmethodId') // Ensure exact API field name
//   final String finPaymentmethodId;
//
//   @JsonKey(name: 'isTaxIncluded') // Ensure exact API field name
//   final String isTaxIncluded;
//
//   @JsonKey(name: 'metaData') // Ensure exact API field name
//   final List<OrderMetadata> metaData;
//
//   @JsonKey(name: 'line') // Ensure exact API field name
//   final List<PaymentOrderItem> line;
//
//   // Optional fields not in API spec but needed for app functionality
//   @JsonKey(includeIfNull: false)
//   final String? customerId;
//
//   @JsonKey(includeIfNull: false)
//   final String? customerName;
//
//   const Order({
//     required this.documentno,
//     required this.cSBunitID,
//     required this.dateOrdered,
//     required this.discAmount,
//     required this.grosstotal,
//     required this.taxamt,
//     required this.mobileNo,
//     required this.finPaymentmethodId,
//     required this.isTaxIncluded,
//     required this.metaData,
//     required this.line,
//     this.customerId,
//     this.customerName,
//   });
//
//   factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
//
//   @override
//   Map<String, dynamic> toJson() => _$OrderToJson(this);
// }
//
// @JsonSerializable(explicitToJson: true, includeIfNull: false)
// class OrderMetadata implements BaseModel {
//   @JsonKey(name: 'key')
//   final String key;
//
//   @JsonKey(name: 'value')
//   final String value;
//
//   const OrderMetadata({
//     required this.key,
//     required this.value,
//   });
//
//   factory OrderMetadata.fromJson(Map<String, dynamic> json) =>
//       _$OrderMetadataFromJson(json);
//
//   @override
//   Map<String, dynamic> toJson() => _$OrderMetadataToJson(this);
// }
//
// @JsonSerializable(explicitToJson: true, includeIfNull: false)
// class PaymentOrderItem implements BaseModel {
//   @JsonKey(name: 'mProductId')
//   final String mProductId;
//
//   @JsonKey(includeIfNull: false)
//   final String name;
//
//   @JsonKey(name: 'qty')
//   final int qty;
//
//   @JsonKey(name: 'unitprice')
//   final num unitprice;
//
//   @JsonKey(name: 'linenet')
//   final num linenet;
//
//   @JsonKey(name: 'linetax')
//   final num linetax;
//
//   @JsonKey(name: 'linegross')
//   final num linegross;
//
//   @JsonKey(includeIfNull: false)
//   final String? productioncenter;
//
//   @JsonKey(name: 'subProducts')
//   final List<PaymentOrderAddon> subProducts;
//
//   const PaymentOrderItem({
//     required this.mProductId,
//     required this.name,
//     required this.qty,
//     required this.unitprice,
//     required this.linenet,
//     required this.linetax,
//     required this.linegross,
//     this.productioncenter,
//     required this.subProducts,
//   });
//
//   factory PaymentOrderItem.fromJson(Map<String, dynamic> json) =>
//       _$PaymentOrderItemFromJson(json);
//
//   @override
//   Map<String, dynamic> toJson() => _$PaymentOrderItemToJson(this);
// }
//
// @JsonSerializable(explicitToJson: true, includeIfNull: false)
// class PaymentOrderAddon implements BaseModel {
//   @JsonKey(name: 'addonProductId')
//   final String addonProductId;
//
//   @JsonKey(name: 'name')
//   final String name;
//
//   @JsonKey(name: 'price')
//   final num price;
//
//   @JsonKey(name: 'qty')
//   final int qty;
//
//   const PaymentOrderAddon({
//     required this.addonProductId,
//     required this.name,
//     required this.qty,
//     required this.price,
//   });
//
//   factory PaymentOrderAddon.fromJson(Map<String, dynamic> json) =>
//       _$PaymentOrderAddonFromJson(json);
//
//   @override
//   Map<String, dynamic> toJson() => _$PaymentOrderAddonToJson(this);
// }
