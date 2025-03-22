// 1. Model Layer - Data Structure
// get_wallet_balance_model.dart
class GetWalletBalanceModel {
  final String b2cCustomerId;
  final String b2cCustomerName;
  final double balanceAmt;

  GetWalletBalanceModel({
    required this.b2cCustomerId,
    required this.b2cCustomerName,
    required this.balanceAmt,
  });

  factory GetWalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return GetWalletBalanceModel(
      b2cCustomerId: json['b2c_Customer_Id']?.toString() ?? '',
      b2cCustomerName: json['b2c_Customer_name']?.toString() ?? '',
      balanceAmt: _parseAmount(json['balance_Amt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'b2c_Customer_Id': b2cCustomerId,
        'b2c_Customer_name': b2cCustomerName,
        'balance_Amt': balanceAmt,
      };

  static double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
