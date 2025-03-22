// import '../../../../common/log/loggers.dart';
//
// class OrderDataModel {
//   final String documentno;
//   final String cSBunitID; // This matches the API case exactly
//   final String dateOrdered;
//   // final double discAmount;
//   // final int grosstotal;
//   // final int taxamt;
//   final num discAmount; // Changed to num to handle both int and double
//   final num grosstotal; // Changed to match API format
//   final num taxamt; // Changed to match API format
//   final String mobileNo;
//   final String finPaymentmethodId;
//   final String isTaxIncluded;
//   final List<MetaData> metaData;
//   final List<OrderLine> line;
//
//   OrderDataModel({
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
//   });
//
//   Map<String, dynamic> toJson() {
//     AppLogger.logDebug('[OrderDataModel] Converting order to JSON');
//     AppLogger.logDebug('[OrderDataModel] documentno: $documentno');
//     AppLogger.logDebug(
//         '[OrderDataModel] Converting order to JSON with ${line.length} line items');
//
//     final orderJson = {
//       'order': {
//         'documentno': documentno,
//         'cSBunitID': cSBunitID,
//         'dateOrdered': dateOrdered,
//         'discAmount': discAmount,
//         'grosstotal': grosstotal,
//         'taxamt': taxamt,
//         'mobileNo': mobileNo,
//         'finPaymentmethodId': finPaymentmethodId,
//         'isTaxIncluded': isTaxIncluded,
//         'metaData': metaData.map((item) => item.toJson()).toList(),
//         'line': line.map((item) => item.toJson()).toList(),
//       }
//     };
//
//     // Get the line items array and cast it properly
//     final List<dynamic> lineItems =
//         (orderJson['order'] as Map<String, dynamic>)['line'] as List<dynamic>;
//     AppLogger.logDebug(
//         '[OrderDataModel] JSON line items count: ${lineItems.length}');
//
//     return orderJson;
//   }
// }
//
// class MetaData {
//   final String key;
//   final String value;
//
//   MetaData({
//     required this.key,
//     required this.value,
//   });
//
//   Map<String, dynamic> toJson() => {
//         'key': key,
//         'value': value,
//       };
// }
//
// class SubProduct {
//   final String addonProductId;
//   final String name;
//   // final double price;
//   // final int qty;
//   final num price; // Changed to num
//   final num qty; // Changed to num
//
//   SubProduct({
//     required this.addonProductId,
//     required this.name,
//     required this.price,
//     required this.qty,
//   });
//
//   Map<String, dynamic> toJson() => {
//         'addonProductId': addonProductId,
//         'name': name,
//         'price': price,
//         'qty': qty,
//       };
// }
//
// class OrderLine {
//   final String mProductId;
//   // final int qty;
//   // final double unitprice;
//   // final double linenet;
//   // final double linetax;
//   // final double linegross;
//   final num qty; // Changed to num
//   final num unitprice; // Changed to num
//   final num linenet; // Changed to num
//   final num linetax; // Changed to num
//   final num linegross; // Changed to num
//   final List<SubProduct> subProducts;
//
//   OrderLine({
//     required this.mProductId,
//     required this.qty,
//     required this.unitprice,
//     required this.linenet,
//     required this.linetax,
//     required this.linegross,
//     required this.subProducts,
//   });
//
//   Map<String, dynamic> toJson() => {
//         'mProductId': mProductId,
//         'qty': qty,
//         'unitprice': unitprice,
//         'linenet': linenet,
//         'linetax': linetax,
//         'linegross': linegross,
//         'subProducts': subProducts.map((item) => item.toJson()).toList(),
//       };
// }
