import 'package:intl/intl.dart';

class DateTimeFormatter {
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static DateTime parseTime(String timeString) {
    final DateFormat formatter = DateFormat.Hm(); // HH:mm format
    return formatter.parse(timeString);
  }

  static String getDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  // New method to check if a given time is between two other times
  static bool isTimeBetween(DateTime time, DateTime start, DateTime end) {
    final now = DateTime(2022, 1, 1, time.hour, time.minute);
    final startTime = DateTime(2022, 1, 1, start.hour, start.minute);
    final endTime = DateTime(2022, 1, 1, end.hour, end.minute);

    if (startTime.isBefore(endTime)) {
      return now.isAfter(startTime) && now.isBefore(endTime);
    } else {
      // Handle cases where the end time is on the next day
      return now.isAfter(startTime) || now.isBefore(endTime);
    }
  }
}
