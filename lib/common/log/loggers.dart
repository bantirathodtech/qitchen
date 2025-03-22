// //filename: "";
// import 'package:flutter/foundation.dart';
// import 'package:logger/logger.dart';
//
// /// A utility class for logging messages in the app using the logger package.
// /// Includes detailed method names with emoji icons for each log level.
// class AppLogger {
//   static final Logger _logger = Logger(
//     printer: PrettyPrinter(
//       methodCount: 2, // Number of method calls to be displayed
//       errorMethodCount:
//           8, // Number of method calls to be displayed when logging an error
//       lineLength: 120, // Width of the output
//       colors: true, // Colorful log messages
//       printEmojis: true, // Include emojis in log messages
//       dateTimeFormat: DateTimeFormat.dateAndTime, // Format for timestamps
//     ),
//   );
//
//   /// Logs a debug message with 📘 icon.
//   static void logDebug(dynamic message) {
//     if (kDebugMode) {
//       _logger.d('📘 DEBUG: $message');
//     }
//   }
//
//   /// Logs an info message with ℹ️ icon.
//   static void logInfo(dynamic message) {
//     if (kDebugMode) {
//       _logger.i('ℹ️ INFO: $message');
//     }
//   }
//
//   /// Logs a warning message with ⚠️ icon.
//   static void logWarning(dynamic message) {
//     if (kDebugMode) {
//       _logger.w('⚠️ WARNING: $message');
//     }
//   }
//
//   /// Logs an error message with 🛑 icon.
//   static void logError(dynamic message, {StackTrace? stackTrace}) {
//     if (kDebugMode) {
//       _logger.e('🛑 ERROR: $message');
//     }
//   }
//
//   /// Logs a trace message with 🔍 icon.
//   static void logTrace(dynamic message) {
//     if (kDebugMode) {
//       _logger.t('🔍 TRACE: $message');
//     }
//   }
//
//   /// Logs a fatal message with 💥 icon.
//   static void logFatal(dynamic message) {
//     if (kDebugMode) {
//       _logger.f('💥 FATAL: $message');
//     }
//   }
//
//   /// Logs a custom message with tag and message.
//   static void log(String tag, String message) {
//     if (kDebugMode) {
//       _logger.d('[$tag]: $message');
//     }
//   }
// }

// filename: app_logger.dart
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// A utility class for logging messages in the app using the logger package.
/// Includes detailed method names with emoji icons for each log level.
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount:
          8, // Number of method calls to be displayed when logging an error
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Include emojis in log messages
      dateTimeFormat: DateTimeFormat.dateAndTime, // Format for timestamps
    ),
  );

  // Define the default tag for filtering logs
  static const String defaultTag = 'logFlow';

  /// Logs a debug message with 📘 icon.
  static void logDebug(dynamic message, {String tag = defaultTag}) {
    if (kDebugMode) {
      _logger.d('📘 DEBUG [$tag]: $message');
    }
  }

  /// Logs an info message with ℹ️ icon.
  static void logInfo(dynamic message, {String tag = defaultTag}) {
    if (kDebugMode) {
      _logger.i('ℹ️ INFO [$tag]: $message');
    }
  }

  /// Logs a warning message with ⚠️ icon.
  static void logWarning(dynamic message, {String tag = defaultTag}) {
    if (kDebugMode) {
      _logger.w('⚠️ WARNING [$tag]: $message');
    }
  }

  /// Logs an error message with 🛑 icon, with an optional tag parameter.
  static void logError(dynamic message,
      {String tag = defaultTag, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _logger.e('🛑 ERROR [$tag]: $message');
      if (stackTrace != null) {
        _logger
            .e('Stack Trace: $stackTrace'); // Log the stack trace if provided
      }
    }
  }

  /// Logs a trace message with 🔍 icon.
  static void logTrace(dynamic message, {String tag = defaultTag}) {
    if (kDebugMode) {
      _logger.t('🔍 TRACE [$tag]: $message');
    }
  }

  /// Logs a fatal message with 💥 icon.
  static void logFatal(dynamic message, {String tag = defaultTag}) {
    if (kDebugMode) {
      _logger.f('💥 FATAL [$tag]: $message');
    }
  }

  /// Logs a custom message with tag and message.
  static void log(String tag, String message) {
    if (kDebugMode) {
      _logger.d('[$tag]: $message');
    }
  }
}
