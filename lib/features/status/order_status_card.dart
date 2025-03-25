// import 'package:flutter/material.dart';
// import 'package:hexcolor/hexcolor.dart'; // Import for Flutter framework
//
// // Enum to represent different order_shared_common statuses
// enum OrderStatus {
//   ordered,
//   preparing,
//   ready,
//   collected,
// }
//
// class OrderStatusCard extends StatelessWidget {
//   const OrderStatusCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Build the card widget
//     return Card(
//       elevation: 0,
//       margin: const EdgeInsets.all(0),
//       color: HexColor("#9AADCF"),
//       child: Padding(
//         padding: const EdgeInsets.all(0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Build status options for each status
//                       _buildStatusOption(
//                         Icons.shopping_cart,
//                         'Ordered',
//                         context,
//                         OrderStatus.ordered,
//                       ),
//                       _buildStatusOption(
//                         Icons.restaurant_menu,
//                         'Preparing',
//                         context,
//                         OrderStatus.preparing,
//                       ),
//                       _buildStatusOption(
//                         Icons.check_circle,
//                         'Ready',
//                         context,
//                         OrderStatus.ready,
//                       ),
//                       _buildStatusOption(
//                         Icons.store,
//                         'Collected',
//                         context,
//                         OrderStatus.collected,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Widget to build each status option
//   Widget _buildStatusOption(
//     IconData icon,
//     String statusText,
//     BuildContext context,
//     OrderStatus status,
//   ) {
//     return Expanded(
//       child: Column(
//         children: [
//           const SizedBox(height: 15),
//           Icon(
//             icon,
//             size: 32,
//             color: _getStatusColor(status),
//           ),
//           const SizedBox(height: 3),
//           Text(
//             statusText,
//             style: TextStyle(
//               fontSize: 12,
//               fontFamily: 'Inter',
//               fontWeight: FontWeight.w400,
//               color: _getStatusColor(status),
//             ),
//           ),
//           const SizedBox(height: 15),
//         ],
//       ),
//     );
//   }
//
//   // Method to get color for each status
//   Color _getStatusColor(OrderStatus status) {
//     switch (status) {
//       case OrderStatus.ordered:
//         return Colors.white;
//       case OrderStatus.preparing:
//         return Colors.white;
//       case OrderStatus.ready:
//         return Colors.white;
//       case OrderStatus.collected:
//         return Colors.white;
//       default:
//         return Colors.white;
//     }
//   }
// }
