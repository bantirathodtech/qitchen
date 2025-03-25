// import 'package:json_annotation/json_annotation.dart';
//
// part 'order_response.g.dart';
//
// // Fix for order_response.dart
// @JsonSerializable(explicitToJson: true)
// class OrderResponse {
//   @JsonKey(name: 'status')
//   final String status;
//
//   @JsonKey(name: 'message')
//   final String message;
//
//   @JsonKey(name: 'recordId')
//   final String? recordId;
//
//   const OrderResponse({
//     required this.status,
//     required this.message,
//     this.recordId,
//   });
//
//   factory OrderResponse.fromJson(Map<String, dynamic> json) =>
//       _$OrderResponseFromJson(json); // Fixed: * changed to _
//
//   Map<String, dynamic> toJson() => _$OrderResponseToJson(this); // Fixed: * changed to _
//
//   bool get isSuccess => status == '200';
// }
class OrderResponse {
  final String status;
  final String message;
  final String? recordId;

  OrderResponse({
    required this.status,
    required this.message,
    this.recordId,
  });

  // Manual parsing without code generation
  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      recordId: json['recordId'],
    );
  }

  bool get isSuccess => status == '200';
}