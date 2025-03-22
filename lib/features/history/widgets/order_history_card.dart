import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/order_history_model.dart';
import '../viewmodel/order_history_viewmodel.dart';

class OrderHistoryCard extends StatelessWidget {
  final OrderHistory order;
  final VoidCallback? onRateOrder;

  const OrderHistoryCard({
    super.key,
    required this.order,
    this.onRateOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.grey, width: 0.1),
      ),
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16), // Reduced vertical margin
      // elevation: 0,
      // color: Colors.white,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(8),
      //   side: const BorderSide(color: Colors.black, width: 1),
      // ),
      // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Reduced vertical margin
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            // Remove extra spacing from expansion tile
            visualDensity: VisualDensity.compact,
          ),
          child: ExpansionTile(
            // Remove default title/subtitle layout and use custom layout
            title: const SizedBox.shrink(), // Empty title
            trailing: const Icon(Icons.expand_more, color: Colors.black),
            // Use completely custom child as the main content
            leading: _UltraCompactHeader(
              storeName: order.storeName,
              orderDate: order.orderDate,
            ),
            tilePadding: const EdgeInsets.only(right: 32, left: 16), // Reduced right padding
            childrenPadding: EdgeInsets.zero,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            maintainState: true,
            // Override internal height constraints with minimal values
            collapsedIconColor: Colors.black,
            iconColor: Colors.black,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: order.items.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Color(0xFF999999),
                        height: 1,
                        thickness: 1,
                      ),
                      itemBuilder: (context, index) {
                        return OrderItemTile(item: order.items[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 28, // Further reduced height
                            child: OutlinedButton(
                              onPressed: () => _handleReorder(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.black),
                                padding: EdgeInsets.zero,
                                foregroundColor: Colors.black,
                                minimumSize: Size.zero, // Allow smaller size
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap target
                              ),
                              child: const Text(
                                'Reorder',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 28, // Further reduced height
                            child: FilledButton(
                              onPressed: onRateOrder,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: EdgeInsets.zero,
                                foregroundColor: Colors.white,
                                minimumSize: Size.zero, // Allow smaller size
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap target
                              ),
                              child: const Text(
                                'Rate Order',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleReorder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black),
        ),
        title: const Text(
          'Reorder Items',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Would you like to add these items to your cart? This will replace any existing items in your cart.',
          style: TextStyle(color: Color(0xFF666666)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderHistoryViewModel>().reorderItems(context, order);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.black),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// Ultra-compact header optimized for minimal height
class _UltraCompactHeader extends StatelessWidget {
  final String storeName;
  final String orderDate;

  const _UltraCompactHeader({
    required this.storeName,
    required this.orderDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: SizedBox(
        height: 30, // Further reduced height
        width: MediaQuery.of(context).size.width * 0.7, // Control width to avoid overflow
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                children: [
                  Text(
                    storeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13, // Slightly smaller font
                      height: 1.1, // Tighter line height
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1), // Minimal spacing
                  Text(
                    orderDate,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.0, // Tighter line height
                      color: Color(0xFF666666),
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderItemTile extends StatelessWidget {
  final OrderLineItem item;

  const OrderItemTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28, // Reduced height
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'x ${item.quantity}',
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      item.productName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (item.addons.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        "(+${item.addons.length})",
                        style: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              '₹${item.totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}