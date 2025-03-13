// // lib/features/order/data/model/redis_order_model.dart
//
// import '../../../../common/log/loggers.dart';
//
// class RedisOrderModel {
//   final String customerId;
//   final String documentno;
//   final String cSBunitID;
//   final String customerName;
//   final String dateOrdered;
//   final String status;
//   final List<RedisOrderLine> line;
//
//   RedisOrderModel({
//     required this.customerId,
//     required this.documentno,
//     required this.cSBunitID,
//     required this.customerName,
//     required this.dateOrdered,
//     required this.status,
//     required this.line,
//   });
//
//   Map<String, dynamic> toJson() {
//     AppLogger.logDebug('[RedisOrderModel] Converting order to JSON');
//     return {
//       'customerId': customerId,
//       'documentno': documentno,
//       'cSBunitID': cSBunitID,
//       'customerName': customerName,
//       'dateOrdered': dateOrdered,
//       'status': status,
//       'line': line.map((item) => item.toJson()).toList(),
//     };
//   }
// }
//
// class RedisOrderLine {
//   final String mProductId;
//   final String name;
//   final int qty;
//   final String notes;
//   final String productioncenter;
//   final int tokenNumber;
//   final String status;
//   final List<RedisSubProduct> subProducts;
//
//   RedisOrderLine({
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
//   Map<String, dynamic> toJson() => {
//         'mProductId': mProductId,
//         'name': name,
//         'qty': qty,
//         'notes': notes,
//         'productioncenter': productioncenter,
//         'token_number': tokenNumber,
//         'status': status,
//         'subProducts': subProducts.map((item) => item.toJson()).toList(),
//       };
// }
//
// class RedisSubProduct {
//   final String addonProductId;
//   final String name;
//   final int qty;
//
//   RedisSubProduct({
//     required this.addonProductId,
//     required this.name,
//     required this.qty,
//   });
//
//   Map<String, dynamic> toJson() => {
//         'addonProductId': addonProductId,
//         'name': name,
//         'qty': qty,
//       };
// }
