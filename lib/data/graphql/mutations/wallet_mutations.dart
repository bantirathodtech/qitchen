// import 'dart:developer' as dev;
//
// /// WALLET MUTATION
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
