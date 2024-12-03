// upsert_wallet_transaction.dart
class UpsertWalletTransaction {
  final UpsertWalletTransactionResponse response;

  UpsertWalletTransaction({required this.response});

  factory UpsertWalletTransaction.fromJson(Map<String, dynamic> json) {
    return UpsertWalletTransaction(
      response: UpsertWalletTransactionResponse.fromJson(json),
    );
  }
}

class UpsertWalletTransactionResponse {
  final String status;
  final String message;
  final String recordId;

  UpsertWalletTransactionResponse({
    required this.status,
    required this.message,
    required this.recordId,
  });

  factory UpsertWalletTransactionResponse.fromJson(Map<String, dynamic> json) {
    return UpsertWalletTransactionResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      recordId: json['recordId']?.toString() ?? '',
    );
  }
}
