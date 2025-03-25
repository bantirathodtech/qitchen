// lib/features/history/widgets/order_history_empty_view.dart

import 'package:flutter/material.dart';

class OrderHistoryEmptyView extends StatelessWidget {
  final VoidCallback? onBrowsePressed;

  const OrderHistoryEmptyView({
    super.key,
    this.onBrowsePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start shopping to see your orders here',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          if (onBrowsePressed != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onBrowsePressed,
              child: const Text('Browse Store'),
            ),
          ],
        ],
      ),
    );
  }
}
