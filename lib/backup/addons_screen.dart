// import 'package:flutter/material.dart';
//
// import '../products/model/product_model.dart';
//
// class AddonsBottomSheet extends StatefulWidget {
//   final ProductModel product;
//   final String productName;
//   final double productPrice;
//   final String? imageUrl;
//   final Function(Map<String, List<AddOnItem>>, int, double) onAddToCart;
//
//   const AddonsBottomSheet({
//     super.key,
//     required this.product,
//     required this.productName,
//     required this.productPrice,
//     this.imageUrl,
//     required this.onAddToCart,
//   });
//
//   @override
//   State<AddonsBottomSheet> createState() => _AddonsBottomSheetState();
// }
//
// class _AddonsBottomSheetState extends State<AddonsBottomSheet> {
//   final Map<String, List<String>> _selections = {};
//   double get _total => widget.productPrice + _calculateAddonsPrice();
//
//   @override
//   void initState() {
//     super.initState();
//     _initSelections();
//   }
//
//   void _initSelections() {
//     for (var group in widget.product.addOnGroups ?? []) {
//       if (group.name != "Customes") {
//         _selections[group.id] = [];
//       }
//     }
//   }
//
//   double _calculateAddonsPrice() {
//     double total = 0;
//     for (var group in widget.product.addOnGroups ?? []) {
//       if (group.name == "Customes") continue;
//       for (var itemId in _selections[group.id] ?? []) {
//         final item = group.addOnItems.firstWhere((i) => i.id == itemId);
//         total += double.tryParse(item.price) ?? 0;
//       }
//     }
//     return total;
//   }
//
//   bool _isValid() {
//     for (var group in widget.product.addOnGroups ?? []) {
//       if (group.name == "Customes") continue;
//       final count = _selections[group.id]?.length ?? 0;
//       if (count < group.minqty || count > group.maxqty) return false;
//     }
//     return true;
//   }
//
//   Widget _buildProductDetails() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           if (widget.imageUrl != null)
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 image: DecorationImage(
//                   image: NetworkImage(widget.imageUrl!),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.productName,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '₹${widget.productPrice.toStringAsFixed(2)}',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.green[700],
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAddonGroups() {
//     final filteredGroups = widget.product.addOnGroups
//             ?.where((group) => group.name != "Customes")
//             .toList() ??
//         [];
//
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: filteredGroups.length,
//       itemBuilder: (context, index) {
//         final group = filteredGroups[index];
//
//         return Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           group.name,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           _getRequirementText(group),
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       '${_selections[group.id]?.length ?? 0}/${group.maxqty}',
//                       style: const TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               ...group.addOnItems.map((item) => CheckboxListTile(
//                     value: _selections[group.id]?.contains(item.id) ?? false,
//                     onChanged: (_) => _toggleSelection(group, item),
//                     title: Text(item.name),
//                     controlAffinity: ListTileControlAffinity.leading,
//                     secondary: Text(
//                       '+₹${double.tryParse(item.price)?.toStringAsFixed(2) ?? '0.00'}',
//                       style: TextStyle(
//                         color: Colors.green[700],
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   )),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildBottomBar() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Total Amount',
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 '₹${_total.toStringAsFixed(2)}',
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//             ],
//           ),
//           const Spacer(),
//           ElevatedButton(
//             onPressed: _isValid() ? _handleAddToCart : null,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.orange[600],
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 32,
//                 vertical: 16,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Add to Cart',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final maxHeight = MediaQuery.of(context).size.height *
//         0.8; // Adjust the multiplier as needed
//
//     return Container(
//       padding: const EdgeInsets.only(top: 16),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(24),
//           topRight: Radius.circular(24),
//         ),
//       ),
//       child: SingleChildScrollView(
//         child: ConstrainedBox(
//           constraints: BoxConstraints(maxHeight: maxHeight),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               _buildProductDetails(),
//               _buildAddonGroups(),
//               _buildBottomBar(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _handleAddToCart() {
//     if (_isValid()) {
//       final addons = _formatAddons();
//       widget.onAddToCart(addons, 1, _total);
//       Navigator.pop(context);
//     }
//   }
//
//   void _toggleSelection(AddOnGroup group, AddOnItem item) {
//     setState(() {
//       _selections[group.id] = _selections[group.id] ?? [];
//       if (_selections[group.id]!.contains(item.id)) {
//         _selections[group.id]!.remove(item.id);
//       } else {
//         _selections[group.id]!.add(item.id);
//       }
//     });
//   }
//
//   String _getRequirementText(AddOnGroup group) {
//     if (group.minqty == 0) return 'Optional (up to ${group.maxqty})';
//     if (group.minqty == group.maxqty) return 'Select exactly ${group.minqty}';
//     return 'Select ${group.minqty}-${group.maxqty}';
//   }
//
//   Map<String, List<AddOnItem>> _formatAddons() {
//     final Map<String, List<AddOnItem>> result = {};
//     for (var group in widget.product.addOnGroups ?? []) {
//       if (group.name == "Customes") continue;
//       final selectedIds = _selections[group.id] ?? [];
//       if (selectedIds.isEmpty) continue;
//       final items = selectedIds
//           .map((id) => group.addOnItems.firstWhere((item) => item.id == id))
//           .toList()
//           .cast<AddOnItem>();
//       if (items.isNotEmpty) result[group.id] = items;
//     }
//     return result;
//   }
// }
