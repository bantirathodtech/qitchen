// import '../shared_fragments.dart';
//
// String createOrderMutation({
//   required String documentno,
//   required String cSBunitID,
//   required String dateOrdered,
//   required double discAmount,
//   required int grosstotal,
//   required int taxamt,
//   required String mobileNo,
//   required String finPaymentmethodId,
//   required String isTaxIncluded,
//   required List<Map<String, dynamic>> metaData,
//   required List<Map<String, dynamic>> line,
// }) {
//   return '''
//     mutation {
//       createOrder(
//         order: {
//           documentno: "$documentno"
//           cSBunitID: "$cSBunitID"
//           dateOrdered: "$dateOrdered"
//           discAmount: $discAmount
//           grosstotal: $grosstotal
//           taxamt: $taxamt
//           mobileNo: "$mobileNo"
//           finPaymentmethodId: "$finPaymentmethodId"
//           isTaxIncluded: "$isTaxIncluded"
//           metaData: ${metaDataToString(metaData)}
//           line: ${lineToString(line)}
//         }
//       ) {
//         status
//         message
//         recordId
//       }
//     }
//   ''';
// }
