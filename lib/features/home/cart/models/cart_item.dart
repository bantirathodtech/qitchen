import '../../../products/model/product_model.dart';

class CartItem {
  final ProductModel product;
  final Map<String, List<AddOnItem>> selectedAddons;
  final num quantity;
  final num totalPrice;
  final String? specialInstructions; // Add this field

  const CartItem({
    required this.product,
    required this.selectedAddons,
    required this.quantity,
    required this.totalPrice,
    this.specialInstructions, // Add this parameter
  });

  CartItem copyWith({
    ProductModel? product,
    Map<String, List<AddOnItem>>? selectedAddons,
    num? quantity,
    num? totalPrice,
    String? specialInstructions, // Add this parameter
  }) {
    return CartItem(
      product: product ?? this.product,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      specialInstructions:
          specialInstructions ?? this.specialInstructions, // Add this
    );
  }
}
