// // lib/features/order/provider/payment_method_enum.dart
//
// enum PaymentMethod {
//   card('Credit/Debit Card'),
//   wallet('Digital Wallet'),
//   upi('UPI'),
//   netBanking('Net Banking'),
//   cod('Cash on Delivery');
//
//   final String displayName;
//   const PaymentMethod(this.displayName);
//
//   factory PaymentMethod.fromString(String method) {
//     return PaymentMethod.values.firstWhere(
//       (e) => e.name.toLowerCase() == method.toLowerCase(),
//       orElse: () => PaymentMethod.card,
//     );
//   }
//
//   bool get isOnlinePayment => this != cod;
//   bool get requiresAdditionalVerification => this == cod || this == wallet;
// }
