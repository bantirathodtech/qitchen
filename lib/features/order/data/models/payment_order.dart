// lib/features/order/data/models/payment_order.dart

import 'package:json_annotation/json_annotation.dart';

import 'base_model.dart';

part 'payment_order.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class PaymentOrder implements BaseModel {
  final Order order;

  const PaymentOrder({required this.order});

  factory PaymentOrder.fromJson(Map<String, dynamic> json) =>
      _$PaymentOrderFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PaymentOrderToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Order implements BaseModel {
  @JsonKey(name: 'documentno') // Ensure exact API field name
  final String documentno;

  @JsonKey(name: 'cSBunitID') // Ensure exact API field name
  final String cSBunitID;

  @JsonKey(name: 'dateOrdered') // Ensure exact API field name
  final String dateOrdered;

  @JsonKey(name: 'discAmount') // Ensure exact API field name
  final num discAmount; // Changed to num to match API

  @JsonKey(name: 'grosstotal') // Ensure exact API field name
  final num grosstotal; // Changed to num to match API

  @JsonKey(name: 'taxamt') // Ensure exact API field name
  final num taxamt; // Changed to num to match API

  @JsonKey(name: 'mobileNo') // Ensure exact API field name
  final String mobileNo;

  @JsonKey(name: 'finPaymentmethodId') // Ensure exact API field name
  final String finPaymentmethodId;

  @JsonKey(name: 'isTaxIncluded') // Ensure exact API field name
  final String isTaxIncluded;

  @JsonKey(name: 'metaData') // Ensure exact API field name
  final List<OrderMetadata> metaData;

  @JsonKey(name: 'line') // Ensure exact API field name
  final List<PaymentOrderItem> line;

  // Optional fields not in API spec but needed for app functionality
  @JsonKey(includeIfNull: false)
  final String? customerId;

  @JsonKey(includeIfNull: false)
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

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OrderMetadata implements BaseModel {
  @JsonKey(name: 'key')
  final String key;

  @JsonKey(name: 'value')
  final String value;

  const OrderMetadata({
    required this.key,
    required this.value,
  });

  factory OrderMetadata.fromJson(Map<String, dynamic> json) =>
      _$OrderMetadataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OrderMetadataToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class PaymentOrderItem implements BaseModel {
  @JsonKey(name: 'mProductId')
  final String mProductId;

  @JsonKey(includeIfNull: false)
  final String name;

  @JsonKey(name: 'qty')
  final int qty;

  @JsonKey(name: 'unitprice')
  final num unitprice;

  @JsonKey(name: 'linenet')
  final num linenet;

  @JsonKey(name: 'linetax')
  final num linetax;

  @JsonKey(name: 'linegross')
  final num linegross;

  @JsonKey(includeIfNull: false)
  final String? productioncenter;

  @JsonKey(name: 'subProducts')
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

  factory PaymentOrderItem.fromJson(Map<String, dynamic> json) =>
      _$PaymentOrderItemFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PaymentOrderItemToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class PaymentOrderAddon implements BaseModel {
  @JsonKey(name: 'addonProductId')
  final String addonProductId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'price')
  final num price;

  @JsonKey(name: 'qty')
  final int qty;

  const PaymentOrderAddon({
    required this.addonProductId,
    required this.name,
    required this.qty,
    required this.price,
  });

  factory PaymentOrderAddon.fromJson(Map<String, dynamic> json) =>
      _$PaymentOrderAddonFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PaymentOrderAddonToJson(this);
}
