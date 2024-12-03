// import 'dart:developer' as dev;
//
// String fetchOrderQuery(String id) {
//   dev.log('Fetching order data for id: $id', name: 'GraphQLQueries');
//   return '''
//     query GetOrder(\$id: ID!) {
//       order(id: \$id) {
//         sOrderID
//         documentno
//         dateordered
//         docstatus
//         finPaymentmethodId
//         storeName
//         grosstotal
//         line {
//           value
//           productName
//           qty
//           unitprice
//           linegross
//           addons {
//             addonProductId
//             name
//             price
//           }
//         }
//       }
//     }
//   ''';
// }
