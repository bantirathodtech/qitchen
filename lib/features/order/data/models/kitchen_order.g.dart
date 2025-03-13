// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KitchenOrder _$KitchenOrderFromJson(Map<String, dynamic> json) => KitchenOrder(
      customerId: json['customerId'] as String,
      documentno: json['documentno'] as String,
      cSBunitID: json['cSBunitID'] as String,
      customerName: json['customerName'] as String,
      dateOrdered: json['dateOrdered'] as String,
      status: json['status'] as String,
      line: (json['line'] as List<dynamic>)
          .map((e) => KitchenOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$KitchenOrderToJson(KitchenOrder instance) =>
    <String, dynamic>{
      'customerId': instance.customerId,
      'documentno': instance.documentno,
      'cSBunitID': instance.cSBunitID,
      'customerName': instance.customerName,
      'dateOrdered': instance.dateOrdered,
      'status': instance.status,
      'line': instance.line.map((e) => e.toJson()).toList(),
    };

KitchenOrderItem _$KitchenOrderItemFromJson(Map<String, dynamic> json) =>
    KitchenOrderItem(
      mProductId: json['mProductId'] as String,
      name: json['name'] as String,
      qty: (json['qty'] as num).toInt(),
      notes: json['notes'] as String,
      productioncenter: json['productioncenter'] as String,
      tokenNumber: (json['token_number'] as num).toInt(),
      status: json['status'] as String,
      subProducts: (json['subProducts'] as List<dynamic>)
          .map((e) => KitchenOrderAddon.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$KitchenOrderItemToJson(KitchenOrderItem instance) =>
    <String, dynamic>{
      'mProductId': instance.mProductId,
      'name': instance.name,
      'qty': instance.qty,
      'notes': instance.notes,
      'productioncenter': instance.productioncenter,
      'token_number': instance.tokenNumber,
      'status': instance.status,
      'subProducts': instance.subProducts.map((e) => e.toJson()).toList(),
    };

KitchenOrderAddon _$KitchenOrderAddonFromJson(Map<String, dynamic> json) =>
    KitchenOrderAddon(
      addonProductId: json['addonProductId'] as String,
      name: json['name'] as String,
      qty: (json['qty'] as num).toInt(),
    );

Map<String, dynamic> _$KitchenOrderAddonToJson(KitchenOrderAddon instance) =>
    <String, dynamic>{
      'addonProductId': instance.addonProductId,
      'name': instance.name,
      'qty': instance.qty,
    };
