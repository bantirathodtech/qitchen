import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../common/log/loggers.dart';
import '../../../../common/styles/ElevatedButton.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../main/main_screen.dart';
import '../../data/models/kitchen_order.dart';
import '../../data/models/payment_order.dart';
import '../../viewmodel/kitchen_order_viewmodel.dart';
import '../../viewmodel/payment_order_viewmodel.dart';
import '../widgets/confirmation_items_table.dart';
import '../widgets/confirmation_order_summary.dart';
import '../widgets/confirmation_success_message.dart';

class ConfirmationDisplayScreen extends StatefulWidget {
  final Order order;

  const ConfirmationDisplayScreen({super.key, required this.order});

  @override
  State<ConfirmationDisplayScreen> createState() =>
      _ConfirmationDisplayScreenState();
}

class _ConfirmationDisplayScreenState extends State<ConfirmationDisplayScreen> {
  static const String TAG = '[ConfirmationDisplayScreen]';
  late final PaymentOrderViewModel _paymentViewModel;
  late final KitchenOrderViewModel _kitchenViewModel;
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _paymentViewModel = context.read<PaymentOrderViewModel>();
    _kitchenViewModel = context.read<KitchenOrderViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processOrder();
    });
  }

  Future<void> _processOrder() async {
    try {
      setState(() {
        _isProcessing = true;
        _error = null; // Reset error state
      });

      AppLogger.logInfo('$TAG Processing order: ${widget.order.documentno}');
      AppLogger.logDebug('$TAG Order data: ${widget.order.toJson()}');
      AppLogger.logDebug('$TAG Line items count: ${widget.order.line.length}');

      // Create a deep clone of the order with line items
      final processedOrder = _cloneOrder(widget.order);

      // Validate order data
      _validateOrder(processedOrder);

      // Create payment order first
      // Inside _processOrder() method, replace the current PaymentOrderItem creation with:
      final paymentSuccess = await _paymentViewModel.createOrder(
        documentNo: processedOrder.documentno,
        cSBunitID: processedOrder.cSBunitID,
        dateOrdered: processedOrder.dateOrdered,
        discAmount: processedOrder.discAmount,
        grosstotal: processedOrder.grosstotal,
        taxamt: processedOrder.taxamt,
        mobileNo: processedOrder.mobileNo,
        finPaymentmethodId: processedOrder.finPaymentmethodId,
        isTaxIncluded: processedOrder.isTaxIncluded,
        metaData: processedOrder.metaData,
        lineItems: processedOrder.line, // Use original line items directly
      );

      if (!paymentSuccess) {
        throw Exception('Failed to create payment order');
      }

      AppLogger.logInfo('$TAG Payment order created successfully');

      // Then create kitchen orders
      final itemsByCenter = _groupItemsByCenter(processedOrder.line);

      for (final entry in itemsByCenter.entries) {
        final center = entry.key;
        final items = entry.value;

        AppLogger.logDebug(
            '$TAG Creating kitchen order for center: $center with ${items.length} items');

        final kitchenOrderLines = items
            .map((item) => KitchenOrderItem(
                  mProductId: item.mProductId,
                  name: item.name ?? 'Unknown Item',
                  qty: item.qty,
                  notes: '',
                  productioncenter: center,
                  tokenNumber: 1,
                  status: 'pending',
                  subProducts: item.subProducts
                      .map((addon) => KitchenOrderAddon(
                            addonProductId: addon.addonProductId,
                            name: addon.name,
                            qty: addon.qty,
                          ))
                      .toList(),
                ))
            .toList();

        final kitchenSuccess = await _kitchenViewModel.createRedisOrder(
          customerId: processedOrder.customerId ?? processedOrder.mobileNo,
          documentNo: processedOrder.documentno,
          cSBunitID: processedOrder.cSBunitID,
          customerName: processedOrder.customerName ?? 'Guest',
          dateOrdered: processedOrder.dateOrdered,
          status: 'pending',
          lineItems: kitchenOrderLines,
        );

        if (!kitchenSuccess) {
          throw Exception('Failed to create kitchen order for center: $center');
        }

        AppLogger.logInfo('$TAG Kitchen order created for center: $center');
      }

      AppLogger.logInfo('$TAG Order processed successfully');
    } catch (e, stackTrace) {
      AppLogger.logError('$TAG Order processing failed: $e');
      AppLogger.logError('$TAG Stack trace: $stackTrace');
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isProcessing = false);
    }
  }

// Helper Methods
  Order _cloneOrder(Order original) {
    return Order(
      documentno: original.documentno,
      cSBunitID: original.cSBunitID,
      dateOrdered: original.dateOrdered,
      discAmount: original.discAmount,
      grosstotal: original.grosstotal,
      taxamt: original.taxamt,
      mobileNo: original.mobileNo,
      finPaymentmethodId: original.finPaymentmethodId,
      isTaxIncluded: original.isTaxIncluded,
      metaData: List<OrderMetadata>.from(original.metaData),
      line: List<PaymentOrderItem>.from(original.line),
      customerId: original.customerId,
      customerName: original.customerName,
    );
  }

  void _validateOrder(Order order) {
    if (order.documentno.isEmpty) {
      throw Exception('Invalid order: Document number is missing');
    }
    if (order.line.isEmpty) {
      throw Exception('Order validation failed: No line items found');
    }
    for (var item in order.line) {
      if (item.mProductId.isEmpty) {
        throw Exception('Invalid line item: Product ID is missing');
      }
      if (item.qty <= 0) {
        throw Exception('Invalid line item: Quantity must be greater than 0');
      }
    }
  }

  Map<String, List<PaymentOrderItem>> _groupItemsByCenter(
      List<PaymentOrderItem> items) {
    final itemsByCenter = <String, List<PaymentOrderItem>>{};
    for (var item in items) {
      final center = item.productioncenter ?? 'default-center';
      itemsByCenter.putIfAbsent(center, () => []).add(item);
    }
    return itemsByCenter;
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    color: Theme.of(context).colorScheme.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Order Processing Failed',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        logoPath: 'assets/images/cw_image.png',
        onBackPressed: () {
          // Define what happens when the back button is pressed
          Navigator.of(context).pop();
        },
      ),

      // appBar: AppBar(
      //   title: const Text('Order Confirmation'),
      //   automaticallyImplyLeading: false,
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConfirmationSuccessMessage(
                orderId: widget.order.documentno,
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Thank You!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(55, 84, 211, 1),
                  ),
                ),
              ),
              _buildItemCountAndTotal(context),
              const SizedBox(height: 4),
              Row(),
              const SizedBox(height: 4),
              ConfirmationOrderSummary(
                order: widget.order,
              ),
              const SizedBox(height: 4),
              ConfirmationItemsTable(
                items: widget.order.line,
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Your payment confirmation',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: QrImageView(
                    data: widget.order.documentno,
                    version: QrVersions.auto,
                    size: 160,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Your receipt has been stored.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                child: CustomElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(initialIndex: 0),
                      ),
                      (route) => false, // Remove all previous routes
                    );
                  },
                  color: Colors.deepOrangeAccent,
                  text: 'back to Home',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCountAndTotal(BuildContext context) {
    final itemCount = widget.order.line.length;
    final totalAmount = widget.order.grosstotal.toStringAsFixed(2);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$itemCount Items -',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(111, 111, 111, 1),
          ),
        ),
        SizedBox(
          width: 16,
        ),
        Text(
          '₹$totalAmount',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(111, 111, 111, 1),
          ),
        ),
      ],
    );
  }
}
