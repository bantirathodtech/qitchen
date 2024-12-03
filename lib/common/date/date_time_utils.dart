import 'package:intl/intl.dart';

class DateTimeUtils {
  // Formats used in the application
  static const String uiDateFormat = 'yyyy:MM:dd hh:mm a'; // UI display format
  static const String graphQLDateFormat =
      'yyyy-MM-dd HH:mm:ss'; // GraphQL format

  /// Converts a [DateTime] object to a string formatted for UI display.
  static String formatDateForDisplay(DateTime dateTime) {
    final DateFormat formatter = DateFormat(uiDateFormat);
    return formatter.format(dateTime);
  }

  /// Converts a date string from UI format to GraphQL format.
  static String formatDateForGraphQL(String uiFormattedDate) {
    final DateFormat uiFormatter = DateFormat(uiDateFormat);
    final DateTime dateTime = uiFormatter.parse(uiFormattedDate);
    return DateFormat(graphQLDateFormat).format(dateTime);
  }

  /// Parses a GraphQL-formatted date string into a UI-formatted string.
  static String formatGraphQLToDisplay(String graphQLDate) {
    final DateFormat graphQLFormatter = DateFormat(graphQLDateFormat);
    final DateTime dateTime = graphQLFormatter.parse(graphQLDate);
    final DateFormat uiFormatter = DateFormat(uiDateFormat);
    return uiFormatter.format(dateTime);
  }

  /// Parses a date string into a [DateTime] object using the provided [format].
  static DateTime parseDateTime(String dateString,
      {String format = graphQLDateFormat}) {
    final DateFormat formatter = DateFormat(format);
    return formatter.parse(dateString);
  }

  /// Checks if a given date string is valid according to the provided [format].
  static bool isValidDateFormat(String date, {required String format}) {
    try {
      DateFormat(format).parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Formats a [DateTime] object to a time string (default format: 'HH:mm').
  static String formatTime(DateTime dateTime, {String timeFormat = 'HH:mm'}) {
    final DateFormat timeFormatter = DateFormat(timeFormat);
    return timeFormatter.format(dateTime);
  }

  /// Returns the difference in days between two [DateTime] objects.
  static int calculateDaysBetween(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays;
  }

  /// Adds a specified number of [days] to a [DateTime] object.
  static DateTime addDays(DateTime dateTime, int days) {
    return dateTime.add(Duration(days: days));
  }

  /// Subtracts a specified number of [days] from a [DateTime] object.
  static DateTime subtractDays(DateTime dateTime, int days) {
    return dateTime.subtract(Duration(days: days));
  }

  /// Checks if a given [DateTime] object represents today's date.
  static bool isToday(DateTime dateTime) {
    final DateTime now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Converts a [DateTime] object to a human-readable relative time string (e.g., '2 hours ago').
  static String timeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 7) {
      return DateFormat('yyyy-MM-dd')
          .format(dateTime); // Displays the date if over a week old
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

// Purpose: Provides utility functions for formatting, parsing, and manipulating date and time values.
// Usage: Use this class whenever you need to format, convert, or manipulate date and time values within the app.
