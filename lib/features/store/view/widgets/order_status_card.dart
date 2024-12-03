import 'package:flutter/material.dart';

import '../../../../../../common/styles/app_text_styles.dart';
import '../../../../../common/log/loggers.dart';

enum OrderStatus {
  ordered,
  preparing,
  ready,
  collected,
}

class OrderStatusCard extends StatefulWidget {
  static const String TAG = '[OrderStatusCard]';

  final OrderStatus currentStatus;

  const OrderStatusCard({
    super.key,
    this.currentStatus = OrderStatus.ordered,
  });

  @override
  _OrderStatusCardState createState() => _OrderStatusCardState();
}

class _OrderStatusCardState extends State<OrderStatusCard> {
  late OrderStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.currentStatus; // Initialize with passed status
  }

  void _cycleOrderStatus() {
    setState(() {
      final currentIndex = OrderStatus.values.indexOf(_currentStatus);
      final nextIndex = (currentIndex + 1) % OrderStatus.values.length;
      _currentStatus = OrderStatus.values[nextIndex];
    });
  }

  bool _isStatusActive(OrderStatus status) {
    return OrderStatus.values.indexOf(status) <=
        OrderStatus.values.indexOf(_currentStatus);
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.ordered:
        return Color(0xFFE0E0E0); // Light gray for a neutral feel
      case OrderStatus.preparing:
        return Color(0xFFFFA726); // Vibrant orange for active preparation
      case OrderStatus.ready:
        return Color(0xFF42A5F5); // Bright blue to signify readiness
      case OrderStatus.collected:
        return Color(0xFF66BB6A); // Soft green for completion
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.logDebug('${OrderStatusCard.TAG}: Building order status card');

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      color: const Color.fromRGBO(154, 173, 207, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: Colors.black.withOpacity(0.2),
      child: Stack(
        children: [
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...OrderStatus.values.map((status) => _buildStatusItem(status)),
          // _buildCycleButton(),
        ],
      ),
    );
  }

  Widget _buildStatusItem(OrderStatus status) {
    final isActive = _isStatusActive(status);

    final circleColor = isActive ? _getStatusColor(status) : Colors.white;

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              border: !isActive
                  ? Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset(
                _getStatusIcon(status),
                color: const Color.fromRGBO(55, 84, 211, 1),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusText(status),
            style: AppTextStyles.h6.copyWith(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Widget _buildCycleButton() {
  //   return GestureDetector(
  //     onTap: _cycleOrderStatus,
  //     child: Column(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: Colors.orange, // Custom color for the button
  //             shape: BoxShape.circle,
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.1),
  //                 blurRadius: 4,
  //                 offset: const Offset(0, 2),
  //               ),
  //             ],
  //           ),
  //           // child: Icon(
  //           //   Icons.loop,
  //           //   color: Colors.white,
  //           //   size: 24,
  //           // ),
  //         ),
  //         // const SizedBox(height: 8),
  //         // Text(
  //         //   'Cycle',
  //         //   style: AppTextStyles.h6.copyWith(
  //         //     color: Colors.white,
  //         //     fontSize: 12,
  //         //     fontWeight: FontWeight.bold,
  //         //     shadows: [
  //         //       Shadow(
  //         //         color: Colors.black.withOpacity(0.2),
  //         //         blurRadius: 2,
  //         //         offset: const Offset(0, 1),
  //         //       ),
  //         //     ],
  //         //   ),
  //         //   textAlign: TextAlign.center,
  //         // ),
  //       ],
  //     ),
  //   );
  // }

  String _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.ordered:
        return 'assets/images/os_list.png';
      case OrderStatus.preparing:
        return 'assets/images/os_prepare.png';
      case OrderStatus.ready:
        return 'assets/images/os_dish.png';
      case OrderStatus.collected:
        return 'assets/images/os_check.png';
    }
  }

  String _getStatusText(OrderStatus status) {
    return status.toString().split('.').last.capitalize();
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

// // lib/features/store/view/widgets/order_status_card.dart
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../../../common/styles/app_text_styles.dart';
// import '../../../../../common/log/loggers.dart';
// import '../../../order/data/models/kitchen_order.dart';
// import '../../../order/provider/kitchen_order_state.dart';
// import '../../../order/viewmodel/kitchen_order_viewmodel.dart';
//
// // Defines the different order status types
// enum OrderStatus {
//   ordered,
//   preparing,
//   ready,
//   collected,
// }
//
// // The OrderStatusCard widget is responsible for displaying the order status information
// class OrderStatusCard extends StatefulWidget {
//   static const String TAG = '[OrderStatusCard]';
//
//   const OrderStatusCard({
//     super.key,
//   });
//
//   @override
//   _OrderStatusCardState createState() => _OrderStatusCardState();
// }
//
// class _OrderStatusCardState extends State<OrderStatusCard> {
//   // Tracks the current status being displayed
//   late OrderStatus _currentStatus;
//   Map<String, String> _orderStatuses = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchPendingOrders();
//   }
//
//   @override
//   void didUpdateWidget(covariant OrderStatusCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     _fetchPendingOrders();
//   }
//
//   // Fetches the pending orders from the KitchenOrderViewModel
//   Future<void> _fetchPendingOrders() async {
//     try {
//       final kitchenViewModel = context.read<KitchenOrderViewModel>();
//       final orders = await kitchenViewModel.getPendingOrders();
//       _updateOrderStatuses(orders);
//     } catch (e) {
//       AppLogger.logError(
//           '${OrderStatusCard.TAG}: Error fetching pending orders: $e');
//     }
//   }
//
//   // Updates the order statuses in the KitchenOrderState
//   void _updateOrderStatuses(List<KitchenOrder> orders) {
//     final kitchenState = context.read<KitchenOrderState>();
//     final statuses = <String, String>{};
//     for (final order in orders) {
//       statuses[order.documentno] = order.status;
//     }
//     setState(() {
//       _orderStatuses = statuses;
//     });
//   }
//
//   // Cycles through the different order statuses when the "Cycle" button is pressed
//   void _cycleOrderStatus() {
//     setState(() {
//       final currentIndex = OrderStatus.values.indexOf(_currentStatus);
//       final nextIndex = (currentIndex + 1) % OrderStatus.values.length;
//       _currentStatus = OrderStatus.values[nextIndex];
//     });
//   }
//
//   // Checks if the given status is active (i.e., the current status or a previous one)
//   bool _isStatusActive(OrderStatus status) {
//     return OrderStatus.values.indexOf(status) <=
//         OrderStatus.values.indexOf(_currentStatus);
//   }
//
//   // Determines the color for the given order status
//   Color _getStatusColor(OrderStatus status) {
//     switch (status) {
//       case OrderStatus.ordered:
//         return const Color(0xFFE0E0E0); // Light gray for a neutral feel
//       case OrderStatus.preparing:
//         return const Color(0xFFFFA726); // Vibrant orange for active preparation
//       case OrderStatus.ready:
//         return const Color(0xFF42A5F5); // Bright blue to signify readiness
//       case OrderStatus.collected:
//         return const Color(0xFF66BB6A); // Soft green for completion
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     AppLogger.logDebug('${OrderStatusCard.TAG}: Building order status card');
//
//     return _orderStatuses.isNotEmpty
//         ? SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: _orderStatuses.entries.map((entry) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: _buildOrderStatusItem(entry.key, entry.value),
//                 );
//               }).toList(),
//             ),
//           )
//         : const SizedBox.shrink();
//   }
//
//   // Builds an individual order status item
//   Widget _buildOrderStatusItem(String orderNumber, String status) {
//     final orderStatus = _getOrderStatus(status);
//     final isActive = _isStatusActive(orderStatus);
//
//     final circleColor = isActive ? _getStatusColor(orderStatus) : Colors.white;
//
//     return Card(
//       elevation: 4,
//       color: const Color.fromRGBO(154, 173, 207, 1),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Order #$orderNumber'),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: circleColor,
//                 shape: BoxShape.circle,
//                 border: !isActive
//                     ? Border.all(
//                         color: Colors.grey.withOpacity(0.3),
//                         width: 1,
//                       )
//                     : null,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: Image.asset(
//                   _getStatusIcon(orderStatus),
//                   color: const Color.fromRGBO(55, 84, 211, 1),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               status.toUpperCase(),
//               style: AppTextStyles.h6.copyWith(
//                 color: Colors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 shadows: [
//                   Shadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 2,
//                     offset: const Offset(0, 1),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Helper methods to get the appropriate status icon and text
//   String _getStatusIcon(OrderStatus status) {
//     switch (status) {
//       case OrderStatus.ordered:
//         return 'assets/images/os_list.png';
//       case OrderStatus.preparing:
//         return 'assets/images/os_prepare.png';
//       case OrderStatus.ready:
//         return 'assets/images/os_dish.png';
//       case OrderStatus.collected:
//         return 'assets/images/os_check.png';
//     }
//   }
//
//   // Converts the status string to the corresponding OrderStatus enum
//   OrderStatus _getOrderStatus(String status) {
//     switch (status.toLowerCase()) {
//       case 'ordered':
//         return OrderStatus.ordered;
//       case 'preparing':
//         return OrderStatus.preparing;
//       case 'ready':
//         return OrderStatus.ready;
//       case 'collected':
//         return OrderStatus.collected;
//       default:
//         return OrderStatus.ordered;
//     }
//   }
// }
