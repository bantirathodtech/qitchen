// lib/features/history/model/wallet_transaction_model.dart
class WalletTransactionModel {
  final String walletTrxId;
  final DateTime date;
  final String trxType;
  final double trxValue;
  final double openingAmt;
  final double closingAmt;

  WalletTransactionModel({
    required this.walletTrxId,
    required this.date,
    required this.trxType,
    required this.trxValue,
    required this.openingAmt,
    required this.closingAmt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      walletTrxId: json['wallet_trx_id'] ?? '',
      date: DateTime.parse(json['date']),
      trxType: json['trx_type'] ?? '',
      trxValue: (json['trx_value'] ?? 0).toDouble(),
      openingAmt: (json['opening_amt'] ?? 0).toDouble(),
      closingAmt: (json['closing_amt'] ?? 0).toDouble(),
    );
  }
}

// Optional wrapper class if you need to handle the entire response
class GetWalletTransactions {
  final List<WalletTransactionModel> transactions;

  GetWalletTransactions({required this.transactions});

  factory GetWalletTransactions.fromJson(List<dynamic> json) {
    return GetWalletTransactions(
      transactions: json
          .map((transactionJson) =>
              WalletTransactionModel.fromJson(transactionJson))
          .toList(),
    );
  }
}
