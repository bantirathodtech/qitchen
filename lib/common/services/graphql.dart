/// CUSTOMER QUERIES
// String fetchCustomerQuery(String id) {
//   dev.log('Fetching customer data for id: $id', name: 'GraphQLQueries');
//   return '''
//     query GetCustomer(\$id: ID!) {
//       customer(id: \$id) {
//         otp
//         token
//         b2cCustomerId
//         newCustomer
//         firstName
//         lastName
//         email
//         walletId
//       }
//     }
//   ''';
// }
///
// String verifyCustomerMutation(String contactNo) {
//   return '''
//     mutation VerifyCustomer(\$contactNo: String!) {
//       verifyCustomer(contactNo: \$contactNo) {
//         otp
//         token
//         b2cCustomerId
//         newCustomer
//         firstName
//         lastName
//         email
//         walletId
//       }
//     }
//   ''';
// }
//
// String upsertFNBCustomerMutation(Map<String, dynamic> userData) {
//   return '''
//     mutation {
//       upsertFNBCustomer(customer: {
//         b2cCustomerId: "${userData['b2cCustomerId']}",
//         firstName: "${userData['firstName']}",
//         lastName: "${userData['lastName']}",
//         mobileNo: "${userData['mobileNo']}",
//         email: "${userData['email']}"
//       }) {
//         status
//         message
//         b2cCustomerId
//       }
//     }
//   ''';
// }

/// STORE QUERIES
// String fetchStoresQuery() {
//   return '''
//     query {
//       getStores(configId: "2EF21B71E41C4730B6046409F979CC17") {
//         name
//         promotionBanner
//         announcement
//         darkTheme
//         storeConfig {
//           name
//           shortDescription
//           storeImage
//           storeId
//           csBunit {
//             csBunitId
//             value
//             name
//           }
//           storeTimings {
//             startTime
//             endTime
//             isMonday
//             isTuesday
//             isWednesday
//             isThursday
//             isFriday
//             isSaturday
//             isSunday
//           }
//           storeHolidays {
//             name
//             holidayDate
//           }
//         }
//       }
//     }
//   ''';
// }
// String fetchStoresQuery() {
//   dev.log('Fetching stores data', name: 'GraphQLQueries');
//   return '''
//     query {
//       getStores(configId: "2EF21B71E41C4730B6046409F979CC17") {
//         name
//         promotionBanner
//         announcement
//         darkTheme
//         storeConfig {
//           name
//           shortDescription
//           storeImage
//           storeId
//           csBunit {
//             csBunitId
//             value
//             name
//           }
//           storeTimings {
//             startTime
//             endTime
//             isMonday
//             isTuesday
//             isWednesday
//             isThursday
//             isFriday
//             isSaturday
//             isSunday
//           }
//           storeHolidays {
//             name
//             holidayDate
//           }
//         }
//       }
//     }
//   ''';
// }

/// ORDER QUERIES
// String fetchOrderQuery(String id) {
//   dev.log('Fetching order_shared_common data for id: $id', name: 'GraphQLQueries');
//   return '''
//     query GetOrder(\$id: ID!) {
//       order_shared_common(id: \$id) {
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

/// PRODUCT QUERIES
// String getFetchProductQuery(String id) {
//   return """
//   query {
//     getProducts(commerceConfigId: "$id") {
//       product_id
//       category_id
//       categoryName
//       group_id
//       location_id
//       sku
//       name
//       menuName
//       available_start_time
//       available_end_time
//       taxCategories {
//         name
//         taxRate
//         csTaxcategoryID
//         parentTaxId
//       }
//       productioncenter
//       preparationtime
//       preorder
//       short_desc
//       veg
//       unitprice
//       listprice
//       imageUrl
//       bestseller
//       available
//       available_from
//       available_to
//       next_available_from
//       next_available_to
//       add_on_group {
//         id
//         type
//         name
//         minqty
//         maxqty
//         addOnItems {
//           id
//           name
//           price
//         }
//       }
//       attributeGroup {
//         id
//         name
//         attribute {
//           id
//           value
//           name
//         }
//       }
//       ingredients
//     }
//   }
//   """;
// }
// String getFetchProductQuery(String id) {
//   return "query {\n" +
//       "getProducts(commerceConfigId: \"$id\") {\n" +
//       "product_id\n" +
//       "category_id\n" +
//       "group_id\n" +
//       "location_id\n" +
//       "sku\n" +
//       "name\n" +
//       "short_desc\n" +
//       "veg\n" +
//       "unitprice\n" +
//       "listprice\n" +
//       "imageUrl\n" +
//       "bestseller\n" +
//       "available\n" +
//       "available_from\n" +
//       "available_to\n" +
//       "next_available_from\n" +
//       "next_available_to\n" +
//       "add_on_group {\n" +
//       "id\n" +
//       "type\n" +
//       "name\n" +
//       "minqty\n" +
//       "maxqty\n" +
//       "addOnItems {\n" +
//       "id\n" +
//       "name\n" +
//       "price\n" +
//       "}\n" +
//       "}\n" +
//       "attributeGroup {\n" +
//       "id\n" +
//       "name\n" +
//       "attribute {\n" +
//       "id\n" +
//       "value\n" +
//       "name\n" +
//       "}\n" +
//       "}\n" +
//       "ingredients\n" +
//       "}\n" +
//       "}";
//   return "";
// }
//
// /// WALLET QUERIES
// String fetchWalletQuery(String walletId) {
//   dev.log('Fetching wallet data for id: $walletId', name: 'GraphQLQueries');
//   return '''
//     query GetWalletBalance(\$id: String!) {
//       getWalletBalance(id: \$id) {
//         b2c_Customer_Id
//         b2c_Customer_name
//         balance_Amt
//       }
//     }
//   ''';
// }
//
// /// WALLET TRANSACTIONS QUERIES
// String fetchWalletTransactionsQuery(String walletId) {
//   dev.log('Fetching wallet transactions data for walletId: $walletId',
//       name: 'GraphQLQueries');
//   return '''
//     query GetWalletTransactions(\$id: ID!) {
//       walletTransactions(walletId: \$id) {
//         walletTrxId
//         date
//         trxType
//         trxValue
//         openingAmt
//         closingAmt
//       }
//     }
//   ''';
// }

/// WALLET MUTATION
// String upsertWalletTransactionMutation(
//     String b2cCustomerId, String trxType, double trxValue) {
//   dev.log(
//       'Upserting wallet transaction for customerId: $b2cCustomerId with trxType: $trxType and trxValue: $trxValue',
//       name: 'GraphQLMutations');
//   return '''
//     mutation UpsertWalletTransaction(\$b2cCustomerId: String!, \$trxType: String!, \$trxValue: Float!) {
//       upsertWalletTransaction(wallet: {
//         b2c_Customer_Id: \$b2cCustomerId,
//         trx_type: \$trxType,
//         trx_value: \$trxValue
//       }) {
//         status
//         message
//       }
//     }
//   ''';
// }

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
//         order_shared_common: {
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

// String metaDataToString(List<Map<String, dynamic>> metaData) {
//   final metaDataString = metaData.map((item) {
//     return '{ key: "${item['key']}", value: "${item['value']}" }';
//   }).join(', ');
//   return '[$metaDataString]';
// }
//
// String lineToString(List<Map<String, dynamic>> line) {
//   final lineString = line.map((item) {
//     final subProductsString = item['subProducts'].map((subProduct) => '''
//       {
//         addonProductId: "${subProduct['addonProductId']}",
//         name: "${subProduct['name']}",
//         price: ${subProduct['price']},
//         qty: ${subProduct['qty']}
//       }
//     ''').join(', ');
//
//     return '''
//       {
//         mProductId: "${item['mProductId']}",
//         qty: ${item['qty']},
//         unitprice: ${item['unitprice']},
//         linenet: ${item['linenet']},
//         linetax: ${item['linetax']},
//         linegross: ${item['linegross']},
//         subProducts: [$subProductsString]
//       }
//     ''';
//   }).join(', ');
//   return '[$lineString]';
// }

/// PRODUCT QUERIES
// String fetchProductQuery(String storeId) {
//   dev.log('Fetching product data for id: $storeId', name: 'GraphQLQueries');
//   return '''
//     query getProducts(\$commerceConfigId: id) {
//         productId
//         categoryId
//         groupId
//         locationId
//         sku
//         name
//         shortDesc
//         veg
//         unitPrice
//         listPrice
//         imageUrl
//         bestseller
//         available
//         availableFrom
//         availableTo
//         addOnGroup {
//           name
//           value
//         }
//         attributeGroup {
//           name
//           attributes
//         }
//         ingredients
//       }
//     }
//   ''';
// }
