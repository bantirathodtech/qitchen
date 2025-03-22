import 'package:json_annotation/json_annotation.dart';

import 'base_model.dart';

part 'kitchen_order.g.dart';

@JsonSerializable(explicitToJson: true)
class KitchenOrder implements BaseModel {
  @JsonKey(name: 'customerId')
  final String customerId;

  @JsonKey(name: 'documentno')
  final String documentno;

  @JsonKey(name: 'cSBunitID')
  final String cSBunitID;

  @JsonKey(name: 'customerName')
  final String customerName;

  @JsonKey(name: 'dateOrdered')
  final String dateOrdered;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'line')
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

  factory KitchenOrder.fromJson(Map<String, dynamic> json) =>
      _$KitchenOrderFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$KitchenOrderToJson(this);
}

@JsonSerializable(explicitToJson: true)
class KitchenOrderItem implements BaseModel {
  @JsonKey(name: 'mProductId')
  final String mProductId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'qty')
  final int qty;

  @JsonKey(name: 'notes')
  final String notes;

  @JsonKey(name: 'productioncenter')
  final String productioncenter;

  @JsonKey(name: 'token_number') // Match exact API field name
  final int tokenNumber;


  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'subProducts')
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

  factory KitchenOrderItem.fromJson(Map<String, dynamic> json) =>
      _$KitchenOrderItemFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$KitchenOrderItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class KitchenOrderAddon implements BaseModel {
  @JsonKey(name: 'addonProductId')
  final String addonProductId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'qty')
  final int qty;

  const KitchenOrderAddon({
    required this.addonProductId,
    required this.name,
    required this.qty,
  });

  factory KitchenOrderAddon.fromJson(Map<String, dynamic> json) =>
      _$KitchenOrderAddonFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$KitchenOrderAddonToJson(this);
}
