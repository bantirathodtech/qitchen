import 'dart:developer' as dev;

/// WALLET QUERIES
String fetchWalletQuery(String walletId) {
  dev.log('Fetching wallet data for id: $walletId', name: 'GraphQLQueries');
  return '''
    query GetWalletBalance(\$id: String!) {
      getWalletBalance(id: \$id) {
        b2c_Customer_Id
        b2c_Customer_name
        balance_Amt
      }
    }
  ''';
}

/// WALLET TRANSACTIONS QUERIES
String fetchWalletTransactionsQuery(String walletId) {
  dev.log('Fetching wallet transactions data for walletId: $walletId',
      name: 'GraphQLQueries');
  return '''
    query GetWalletTransactions(\$id: ID!) {
      walletTransactions(walletId: \$id) {
        walletTrxId
        date
        trxType
        trxValue
        openingAmt
        closingAmt
      }
    }
  ''';
}
