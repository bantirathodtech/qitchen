// lib/features/history/screens/rate_order_screen.dart

import 'package:flutter/material.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/log/loggers.dart';
import '../model/order_history_model.dart';

class RateOrderScreen extends StatefulWidget {
  final OrderHistory order;

  const RateOrderScreen({
    super.key,
    required this.order,
  });

  @override
  State<RateOrderScreen> createState() => _RateOrderScreenState();
}

class _RateOrderScreenState extends State<RateOrderScreen> {
  static const String TAG = '[RateOrderScreen]';
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleBack() {
    Navigator.of(context).pop();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      _showError('Please select a rating before submitting');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Implement API call to submit rating
      AppLogger.logInfo('$TAG Submitting rating: $_rating, comment: ${_commentController.text}');

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Show success and return to previous screen
      if (mounted) {
        Navigator.pop(context, {
          'success': true,
          'rating': _rating,
          'comment': _commentController.text
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rating submitted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      AppLogger.logError('$TAG Error submitting rating: $e');
      if (mounted) {
        _showError('Failed to submit rating: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        logoPath: 'assets/images/cw_image.png',
        onBackPressed: _handleBack,
        showNotification: false,
        // title: 'Rate Your Order',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store info card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.grey, width: 0.1),
              ),
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.order.storeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order #${widget.order.documentNo}',
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Ordered on ${widget.order.orderDate}',
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'How was your experience?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            // Star rating
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: index < _rating ? Colors.amber : Colors.grey,
                    size: 36,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),

            // Comment field
            const SizedBox(height: 24),
            const Text(
              'Add a comment (optional)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us more about your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),

            // Submit button
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submitRating,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Submit Rating',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// // lib/features/history/screens/rate_order_screen.dart
//
// import 'package:flutter/material.dart';
// import '../../../../common/widgets/custom_app_bar.dart';
// import '../../../../common/log/loggers.dart';
// import '../model/order_history_model.dart';
//
// class RateOrderScreen extends StatefulWidget {
//   final OrderHistory order;
//
//   const RateOrderScreen({
//     super.key,
//     required this.order,
//   });
//
//   @override
//   State<RateOrderScreen> createState() => _RateOrderScreenState();
// }
//
// class _RateOrderScreenState extends State<RateOrderScreen> {
//   static const String TAG = '[RateOrderScreen]';
//   int _rating = 0;
//   final TextEditingController _commentController = TextEditingController();
//   bool _isSubmitting = false;
//
//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }
//
//   void _handleBack() {
//     Navigator.of(context).pop();
//   }
//
//   Future<void> _submitRating() async {
//     if (_rating == 0) {
//       _showError('Please select a rating before submitting');
//       return;
//     }
//
//     setState(() {
//       _isSubmitting = true;
//     });
//
//     try {
//       // TODO: Implement API call to submit rating
//       AppLogger.logInfo('$TAG Submitting rating: $_rating, comment: ${_commentController.text}');
//
//       // Simulate API delay
//       await Future.delayed(const Duration(seconds: 1));
//
//       // Show success
//       if (mounted) {
//         Navigator.pop(context, {
//           'success': true,
//           'rating': _rating,
//           'comment': _commentController.text
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Rating submitted successfully'),
//             backgroundColor: Colors.green,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     } catch (e) {
//       AppLogger.logError('$TAG Error submitting rating: $e');
//       if (mounted) {
//         _showError('Failed to submit rating: $e');
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSubmitting = false;
//         });
//       }
//     }
//   }
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         logoPath: 'assets/images/cw_image.png',
//         onBackPressed: _handleBack,
//         showNotification: false,
//         // title: 'Rate Your Order',
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Store info card
//             Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 side: const BorderSide(color: Colors.grey, width: 0.1),
//               ),
//               elevation: 0,
//               color: Colors.white,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.order.storeName,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Order #${widget.order.documentNo}',
//                       style: const TextStyle(
//                         color: Color(0xFF666666),
//                         fontSize: 14,
//                       ),
//                     ),
//                     Text(
//                       'Ordered on ${widget.order.orderDate}',
//                       style: const TextStyle(
//                         color: Color(0xFF666666),
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 24),
//             const Text(
//               'How was your experience?',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//
//             // Star rating
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(5, (index) {
//                 return IconButton(
//                   icon: Icon(
//                     index < _rating ? Icons.star : Icons.star_border,
//                     color: index < _rating ? Colors.amber : Colors.grey,
//                     size: 36,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _rating = index + 1;
//                     });
//                   },
//                 );
//               }),
//             ),
//
//             // Comment field
//             const SizedBox(height: 24),
//             const Text(
//               'Add a comment (optional)',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _commentController,
//               maxLines: 4,
//               decoration: InputDecoration(
//                 hintText: 'Tell us more about your experience...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(color: Colors.grey),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(color: Theme.of(context).primaryColor),
//                 ),
//               ),
//             ),
//
//             // Submit button
//             const SizedBox(height: 32),
//             SizedBox(
//               width: double.infinity,
//               child: FilledButton(
//                 onPressed: _isSubmitting ? null : _submitRating,
//                 style: FilledButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
//                 child: _isSubmitting
//                     ? const SizedBox(
//                   height: 20,
//                   width: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.white,
//                   ),
//                 )
//                     : const Text(
//                   'Submit Rating',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }