import 'package:json_annotation/json_annotation.dart';

part 'kitchen_order_response.g.dart';

@JsonSerializable(explicitToJson: true)
class KitchenOrderResponse {
  @JsonKey(name: 'message')
  final String message;

  // Matches exact API response:
  // {"message": "Order and production center data saved successfully to Redis"}
  const KitchenOrderResponse({required this.message});

  factory KitchenOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$KitchenOrderResponseFromJson(json);

  bool get isSuccess =>
      message == "Order and production center data saved successfully to Redis";
}
