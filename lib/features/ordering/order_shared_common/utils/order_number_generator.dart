import 'package:intl/intl.dart';

import '../../../../common/log/loggers.dart';

class OrderNumberGenerator {
  /// Generates a unique order_shared_common number using timestamp
  /// Format: CW-YYMMDD-HHMMSS
  static const String TAG = '[OrderNumberGenerator]';

  static String generateOrderNumber() {
    AppLogger.logInfo('$TAG Generating new order_shared_common number');

    final now = DateTime.now();
    final dateStr =
        DateFormat('yyMMdd').format(now); // Changed from 'yyyyMMdd' to 'yyMMdd'
    final timeStr = DateFormat('HHmmss').format(now);

    final orderNumber = 'CW_$dateStr-$timeStr';
    AppLogger.logInfo('$TAG Generated order_shared_common number: $orderNumber');

    return orderNumber;
  }
}

// import 'package:intl/intl.dart';
//
// import '../../../common/log/loggers.dart';
//
// class OrderNumberGenerator {
//   /// Generates a unique order_shared_common number using timestamp and random elements
//   /// Format: CW-YYYYMMDD-HHMMSS-XXX
//   /// where XXX is a random number between 100-999
//   static const String TAG = '[OrderNumberGenerator]';
//
//   static String generateOrderNumber() {
//     AppLogger.logInfo('$TAG Generating new order_shared_common number');
//
//     final now = DateTime.now();
//     final dateStr = DateFormat('yyyyMMdd').format(now);
//     final timeStr = DateFormat('HHmmss').format(now);
//     final random = (100 + now.millisecond % 900).toString();
//
//     final orderNumber = 'CW-$dateStr-$timeStr-$random';
//     AppLogger.logInfo('$TAG Generated order_shared_common number: $orderNumber');
//
//     return orderNumber;
//   }
// }
