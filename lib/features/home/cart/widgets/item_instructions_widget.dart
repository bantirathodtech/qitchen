// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../../common/styles/app_text_styles.dart';
// import '../models/cart_item.dart';
// import '../multiple/cart_manager.dart';
//
// class ItemInstructionsWidget extends StatefulWidget {
//   final CartManager cartManager;
//   final String restaurantName;
//   final CartItem cartItem;
//
//   const ItemInstructionsWidget({
//     required this.cartManager,
//     required this.restaurantName,
//     required this.cartItem,
//     super.key,
//   });
//
//   @override
//   State<ItemInstructionsWidget> createState() => _ItemInstructionsWidgetState();
// }
//
// class _ItemInstructionsWidgetState extends State<ItemInstructionsWidget> {
//   late TextEditingController _notesController;
//
//   @override
//   void initState() {
//     super.initState();
//     _notesController = TextEditingController(text: widget.cartItem.specialInstructions);
//   }
//
//   @override
//   void dispose() {
//     _notesController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () => _showNotesDialog(context),
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.withOpacity(0.2)),
//           borderRadius: BorderRadius.circular(8),
//           color: Colors.grey.withOpacity(0.05),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.note_alt_outlined, size: 16, color: Colors.grey[600]),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 widget.cartItem.specialInstructions?.isNotEmpty == true
//                     ? widget.cartItem.specialInstructions!
//                     : 'Add special instructions',
//                 style: AppTextStyles.menuOptionStyle.copyWith(
//                   fontSize: 12,
//                   color: widget.cartItem.specialInstructions?.isNotEmpty == true
//                       ? Colors.black87
//                       : Colors.grey[600],
//                 ),
//               ),
//             ),
//             Icon(Icons.edit, size: 16, color: Colors.grey[600]),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showNotesDialog(BuildContext context) {
//     _notesController.text = widget.cartItem.specialInstructions ?? '';
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Special Instructions'),
//         content: TextField(
//           controller: _notesController,
//           maxLines: 3,
//           decoration: const InputDecoration(
//             hintText: 'Enter any special instructions...',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               widget.cartManager.updateItemNotes(
//                 widget.restaurantName,
//                 widget.cartItem,
//                 _notesController.text.trim(),
//               );
//               Navigator.pop(context);
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class GeneralInstructionsWidget extends StatefulWidget {
//   final TextEditingController controller;
//   final bool expanded;
//   final VoidCallback onToggleExpanded;
//
//   const GeneralInstructionsWidget({
//     required this.controller,
//     required this.expanded,
//     required this.onToggleExpanded,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<GeneralInstructionsWidget> createState() =>
//       _GeneralInstructionsWidgetState();
// }
//
// class _GeneralInstructionsWidgetState extends State<GeneralInstructionsWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.05),
//             spreadRadius: 1,
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextField(
//             controller: widget.controller,
//             decoration: InputDecoration(
//               hintText: 'Add General Instructions',
//               hintStyle: AppTextStyles.menuOptionStyle.copyWith(
//                 fontSize: 12,
//                 color: Colors.grey[600],
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 vertical: 4,
//                 horizontal: 12,
//               ),
//             ),
//             style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12),
//             maxLines: 1,
//             textAlignVertical: TextAlignVertical.center,
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'To add item-specific instructions, click here',
//                 style: AppTextStyles.menuOptionStyle.copyWith(
//                   fontSize: 12,
//                   color: Colors.grey[700],
//                 ),
//               ),
//               GestureDetector(
//                 onTap: widget.onToggleExpanded,
//                 child: Icon(
//                   widget.expanded
//                       ? Icons.arrow_drop_up
//                       : Icons.arrow_drop_down,
//                   size: 24,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//           if (widget.expanded)
//             Consumer<CartManager>(
//               builder: (context, cartManager, _) {
//                 final allItems = cartManager.cartItemsByRestaurant.entries
//                     .expand((entry) => entry.value.map((item) {
//                   return {
//                     'restaurant': entry.key,
//                     'item': item,
//                   };
//                 }))
//                     .toList();
//
//                 return Column(
//                   children: allItems.map((itemData) {
//                     final restaurantName = itemData['restaurant'] as String;
//                     final item = itemData['item'] as CartItem;
//
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             '${item.product.name} (${restaurantName})',
//                             style: AppTextStyles.menuOptionStyle.copyWith(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           ItemInstructionsWidget(
//                             cartManager: cartManager,
//                             restaurantName: restaurantName,
//                             cartItem: item,
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
// }