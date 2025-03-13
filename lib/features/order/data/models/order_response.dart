import 'package:json_annotation/json_annotation.dart';

part 'order_response.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderResponse {
  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'recordId')
  final String? recordId;

  // Match exact API response structure
  // Example response: {"status": "200", "message": "Sales Order created successfully", "recordId": "C08E0DDD116F4C529DFB73091E35A609"}
  const OrderResponse({
    required this.status,
    required this.message,
    this.recordId,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrderResponseToJson(this);

  bool get isSuccess => status == '200';
}
