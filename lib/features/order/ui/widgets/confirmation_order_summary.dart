// lib/features/order/ui/widgets/confirmation_order_summary.dart

import 'package:flutter/material.dart';

import '../../data/models/payment_order.dart';

class ConfirmationOrderSummary extends StatelessWidget {
  final Order order;

  const ConfirmationOrderSummary({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Order Summary',
            //   style: Theme.of(context).textTheme.titleLarge,
            // ),
            // const Divider(),
            _buildDetailRow(
              context,
              'Order No',
              order.documentno,
            ),
            _buildDetailRow(
              context,
              'Date',
              order.dateOrdered,
            ),
            // _buildDetailRow(
            //   context,
            //   'Mobile',
            //   order.mobileNo,
            // ),
            // _buildDetailRow(
            //   context,
            //   'Subtotal',
            //   '₹${(order.grosstotal - order.taxamt).toStringAsFixed(2)}',
            // ),
            // _buildDetailRow(
            //   context,
            //   'Tax',
            //   '₹${order.taxamt.toStringAsFixed(2)}',
            // ),
            if (order.discAmount > 0)
              _buildDetailRow(
                context,
                'Discount',
                '₹${order.discAmount.toStringAsFixed(2)}',
              ),
            _buildDetailRow(
              context,
              'Total Amount',
              '₹${order.grosstotal.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                : Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
