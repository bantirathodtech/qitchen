// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentOrder _$PaymentOrderFromJson(Map<String, dynamic> json) => PaymentOrder(
      order: Order.fromJson(json['order'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PaymentOrderToJson(PaymentOrder instance) =>
    <String, dynamic>{
      'order': instance.order.toJson(),
    };

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      documentno: json['documentno'] as String,
      cSBunitID: json['cSBunitID'] as String,
      dateOrdered: json['dateOrdered'] as String,
      discAmount: json['discAmount'] as num,
      grosstotal: json['grosstotal'] as num,
      taxamt: json['taxamt'] as num,
      mobileNo: json['mobileNo'] as String,
      finPaymentmethodId: json['finPaymentmethodId'] as String,
      isTaxIncluded: json['isTaxIncluded'] as String,
      metaData: (json['metaData'] as List<dynamic>)
          .map((e) => OrderMetadata.fromJson(e as Map<String, dynamic>))
          .toList(),
      line: (json['line'] as List<dynamic>)
          .map((e) => PaymentOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
    );

Map<String, dynamic> _$OrderToJson(Order instance) {
  final val = <String, dynamic>{
    'documentno': instance.documentno,
    'cSBunitID': instance.cSBunitID,
    'dateOrdered': instance.dateOrdered,
    'discAmount': instance.discAmount,
    'grosstotal': instance.grosstotal,
    'taxamt': instance.taxamt,
    'mobileNo': instance.mobileNo,
    'finPaymentmethodId': instance.finPaymentmethodId,
    'isTaxIncluded': instance.isTaxIncluded,
    'metaData': instance.metaData.map((e) => e.toJson()).toList(),
    'line': instance.line.map((e) => e.toJson()).toList(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('customerId', instance.customerId);
  writeNotNull('customerName', instance.customerName);
  return val;
}

OrderMetadata _$OrderMetadataFromJson(Map<String, dynamic> json) =>
    OrderMetadata(
      key: json['key'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$OrderMetadataToJson(OrderMetadata instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
    };

PaymentOrderItem _$PaymentOrderItemFromJson(Map<String, dynamic> json) =>
    PaymentOrderItem(
      mProductId: json['mProductId'] as String,
      name: json['name'] as String,
      qty: (json['qty'] as num).toInt(),
      unitprice: json['unitprice'] as num,
      linenet: json['linenet'] as num,
      linetax: json['linetax'] as num,
      linegross: json['linegross'] as num,
      productioncenter: json['productioncenter'] as String?,
      subProducts: (json['subProducts'] as List<dynamic>)
          .map((e) => PaymentOrderAddon.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PaymentOrderItemToJson(PaymentOrderItem instance) {
  final val = <String, dynamic>{
    'mProductId': instance.mProductId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  val['qty'] = instance.qty;
  val['unitprice'] = instance.unitprice;
  val['linenet'] = instance.linenet;
  val['linetax'] = instance.linetax;
  val['linegross'] = instance.linegross;
  writeNotNull('productioncenter', instance.productioncenter);
  val['subProducts'] = instance.subProducts.map((e) => e.toJson()).toList();
  return val;
}

PaymentOrderAddon _$PaymentOrderAddonFromJson(Map<String, dynamic> json) =>
    PaymentOrderAddon(
      addonProductId: json['addonProductId'] as String,
      name: json['name'] as String,
      price: json['price'] as num,
      qty: (json['qty'] as num).toInt(),
    );

Map<String, dynamic> _$PaymentOrderAddonToJson(PaymentOrderAddon instance) =>
    <String, dynamic>{
      'addonProductId': instance.addonProductId,
      'name': instance.name,
      'price': instance.price,
      'qty': instance.qty,
    };
