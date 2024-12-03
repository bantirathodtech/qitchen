// // lib/features/order/ui/widgets/confirmation_items_table.dart
//
// import 'package:flutter/material.dart';
//
// import '../../data/models/payment_order.dart';
//
// class ConfirmationItemsTable extends StatelessWidget {
//   final List<PaymentOrderItem> items;
//
//   const ConfirmationItemsTable({
//     super.key,
//     required this.items,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       color: Colors.white,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Text(
//           //   'Order Items',
//           //   style: Theme.of(context).textTheme.titleLarge,
//           // ),
//           // // const SizedBox(height: 8),
//           // const Divider(),
//           if (items.isEmpty)
//             Center(
//               child: Text(
//                 'No items in order',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: Colors.grey[600],
//                     ),
//               ),
//             )
//           else
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: items.length,
//               separatorBuilder: (context, index) => const Divider(),
//               itemBuilder: (context, index) => ExpansionTile(
//                 title: _buildItemHeader(context, items[index]),
//                 children: [
//                   _buildItemDetails(context, items[index]),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildItemHeader(BuildContext context, PaymentOrderItem item) {
//     return Row(
//       children: [
//         Text(
//           '${item.qty}x',
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             item.name ?? 'Unknown Item',
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//         ),
//         Text(
//           '₹${item.linegross.toStringAsFixed(2)}',
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildItemDetails(BuildContext context, PaymentOrderItem item) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 8.0,
//         vertical: 4.0,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Price details
//           _buildDetailRow(
//               context, 'Unit Price', '₹${item.unitprice.toStringAsFixed(2)}'),
//           _buildDetailRow(
//               context, 'Net Amount', '₹${item.linenet.toStringAsFixed(2)}'),
//           _buildDetailRow(
//               context, 'Tax Amount', '₹${item.linetax.toStringAsFixed(2)}'),
//           _buildDetailRow(
//               context, 'Total', '₹${item.linegross.toStringAsFixed(2)}',
//               isTotal: true),
//
//           // Show addons if any
//           if (item.subProducts.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             const Divider(),
//             Text(
//               'Add-ons:',
//               style: Theme.of(context).textTheme.titleSmall,
//             ),
//             const SizedBox(height: 4),
//             ...item.subProducts.map(
//               (addon) => Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '${addon.qty}x ${addon.name}',
//                       style: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                     Text(
//                       '₹${addon.price.toStringAsFixed(2)}',
//                       style: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//
//           // Show production center if available
//           if (item.productioncenter != null) ...[
//             const SizedBox(height: 8),
//             const Divider(),
//             Text(
//               'Production Center: ${item.productioncenter}',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Colors.grey[600],
//                   ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(BuildContext context, String label, String value,
//       {bool isTotal = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//                 ),
//           ),
//           Text(
//             value,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//                 ),
//           ),
//         ],
//       ),
//     );
//   }
// }

///
// import 'package:flutter/material.dart';
//
// import '../../data/models/payment_order.dart';
//
// class ConfirmationItemsTable extends StatelessWidget {
//   final List<PaymentOrderItem> items;
//
//   const ConfirmationItemsTable({
//     super.key,
//     required this.items,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Group items by production center (restaurant)
//     Map<String, List<PaymentOrderItem>> itemsByRestaurant = {};
//     for (var item in items) {
//       final restaurant = item.productioncenter ?? 'Total Value';
//       if (!itemsByRestaurant.containsKey(restaurant)) {
//         itemsByRestaurant[restaurant] = [];
//       }
//       itemsByRestaurant[restaurant]!.add(item);
//     }
//
//     return Card(
//       elevation: 4,
//       color: Colors.white,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (items.isEmpty)
//             Center(
//               child: Text(
//                 'No items in order',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: Colors.grey[600],
//                     ),
//               ),
//             )
//           else
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: itemsByRestaurant.length,
//               separatorBuilder: (context, index) => const Divider(),
//               itemBuilder: (context, index) {
//                 final restaurant = itemsByRestaurant.keys.elementAt(index);
//                 final restaurantItems = itemsByRestaurant[restaurant]!;
//                 final grossTotal = restaurantItems.fold<double>(
//                     0, (sum, item) => sum + item.linegross);
//
//                 return ExpansionTile(
//                   title: _buildItemHeader(
//                     context,
//                     restaurant,
//                     restaurantItems.length,
//                     grossTotal,
//                   ),
//                   children: [
//                     _buildItemDetails(context, restaurantItems),
//                   ],
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildItemHeader(
//     BuildContext context,
//     String restaurantName,
//     int itemCount,
//     double grossTotal,
//   ) {
//     return Row(
//       children: [
//         Expanded(
//           child: Row(
//             children: [
//               Text(
//                 '$itemCount Items',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   restaurantName,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                   overflow:
//                       TextOverflow.ellipsis, // Handle long restaurant names
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Text(
//           '₹${grossTotal.toStringAsFixed(2)}',
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildItemDetails(
//       BuildContext context, List<PaymentOrderItem> restaurantItems) {
//     final double totalTax =
//         restaurantItems.fold(0, (sum, item) => sum + item.linetax);
//     final double grandTotal =
//         restaurantItems.fold(0, (sum, item) => sum + item.linegross);
//
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           // Individual items with their add-ons
//           ...restaurantItems.map((item) => Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Main item
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             '${item.qty}x ${item.name ?? 'Unknown Item'}',
//                             style: Theme.of(context).textTheme.bodyMedium,
//                           ),
//                         ),
//                         Text(
//                           '₹${item.unitprice.toStringAsFixed(2)}',
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Add-ons if any
//                   if (item.subProducts.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: item.subProducts
//                             .map((addon) => Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 2.0),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Expanded(
//                                         child: Text(
//                                           '${addon.qty}x ${addon.name}',
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyMedium
//                                               ?.copyWith(
//                                                 color: Colors.grey[600],
//                                               ),
//                                         ),
//                                       ),
//                                       Text(
//                                         '₹${addon.price.toStringAsFixed(2)}',
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .bodyMedium
//                                             ?.copyWith(
//                                               color: Colors.grey[600],
//                                             ),
//                                       ),
//                                     ],
//                                   ),
//                                 ))
//                             .toList(),
//                       ),
//                     ),
//                   const SizedBox(height: 4),
//                 ],
//               )),
//
//           const Divider(),
//
//           // Tax and Total
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Tax Amount',
//                   style: Theme.of(context).textTheme.bodyMedium,
//                 ),
//                 Text(
//                   '₹${totalTax.toStringAsFixed(2)}',
//                   style: Theme.of(context).textTheme.bodyMedium,
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Total',
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//                 Text(
//                   '₹${grandTotal.toStringAsFixed(2)}',
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../data/models/payment_order.dart';

class ConfirmationItemsTable extends StatelessWidget {
  final List<PaymentOrderItem> items;

  const ConfirmationItemsTable({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Group items by production center (restaurant)
    Map<String, List<PaymentOrderItem>> itemsByRestaurant = {};
    for (var item in items) {
      final restaurant = item.productioncenter ?? 'Unknown Restaurant';
      if (!itemsByRestaurant.containsKey(restaurant)) {
        itemsByRestaurant[restaurant] = [];
      }
      itemsByRestaurant[restaurant]!.add(item);
    }

    return Card(
      elevation: 4,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isEmpty)
            Center(
              child: Text(
                'No items in order',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemsByRestaurant.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final restaurant = itemsByRestaurant.keys.elementAt(index);
                final restaurantItems = itemsByRestaurant[restaurant]!;
                final grossTotal = restaurantItems.fold<double>(
                    0, (sum, item) => sum + item.linegross);

                return ExpansionTile(
                  title: _buildItemHeader(
                    context,
                    restaurant,
                    restaurantItems.length,
                    grossTotal,
                  ),
                  children: [
                    _buildItemDetails(context, restaurantItems),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildItemHeader(
    BuildContext context,
    String restaurantName,
    int itemCount,
    double grossTotal,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  '$itemCount Items',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    restaurantName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${grossTotal.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetails(
      BuildContext context, List<PaymentOrderItem> restaurantItems) {
    final double totalTax =
        restaurantItems.fold(0, (sum, item) => sum + item.linetax);
    final double grandTotal =
        restaurantItems.fold(0, (sum, item) => sum + item.linegross);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Individual items with their add-ons
          ...restaurantItems.map((item) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main item
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.qty}x ${item.name ?? 'Unknown Item'}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          '₹${item.unitprice.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  // Add-ons (using the original implementation)
                  if (item.subProducts.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Divider(),
                    Text(
                      'Add-ons:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    ...item.subProducts.map(
                      (addon) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${addon.qty}x ${addon.name}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '₹${addon.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              )),

          const Divider(),

          // Tax and Total
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tax Amount',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '₹${totalTax.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '₹${grandTotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
