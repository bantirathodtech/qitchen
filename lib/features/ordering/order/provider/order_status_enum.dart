// // lib/features/order/provider/order_status_enum.dart
//
// enum OrderStatus {
//   pending('Pending'),
//   processing('Processing'),
//   completed('Completed'),
//   cancelled('Cancelled'),
//   failed('Failed');
//
//   final String displayName;
//   const OrderStatus(this.displayName);
//
//   factory OrderStatus.fromString(String status) {
//     return OrderStatus.values.firstWhere(
//       (e) => e.name.toLowerCase() == status.toLowerCase(),
//       orElse: () => OrderStatus.pending,
//     );
//   }
//
//   bool get isFinished =>
//       this == completed || this == cancelled || this == failed;
//   bool get canCancel => this == pending || this == processing;
//   bool get canProcess => this == pending;
//   bool get canComplete => this == processing;
// }
