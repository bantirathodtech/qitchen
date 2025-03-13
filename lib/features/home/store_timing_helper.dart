// File: helpers/store_timing_helper.dart

import 'package:cw_food_ordering/features/store/model/store_models.dart';

import '../../common/log/loggers.dart';

class StoreTimingHelper {
  static const String TAG = '[StoreTimingHelper]';

  /// Get timing information for a restaurant
  static Map<String, dynamic> getRestaurantTimingInfo(
      RestaurantModel restaurant) {
    AppLogger.logInfo('$TAG: Getting timing info for ${restaurant.name}');

    final DateTime now = DateTime.now();
    final String today = _getDayOfWeek(now);

    // Check if restaurant has timing information
    if (restaurant.timings.isEmpty) {
      AppLogger.logInfo(
          '$TAG: No timing information available for: ${restaurant.name}');
      return {
        'isOpen': false,
        'displayTiming': 'Hours not available',
        'statusText': 'Status unknown'
      };
    }

    // Check for holiday
    if (_isHolidayToday(now, restaurant.holidays)) {
      final holiday = _getHolidayInfo(now, restaurant.holidays);
      return {
        'isOpen': false,
        'displayTiming': 'Closed for ${holiday.name}',
        'statusText': 'Holiday'
      };
    }

    // Get today's timing
    final todayTiming = _getTodayTiming(today, restaurant.timings);
    if (todayTiming == null) {
      return {
        'isOpen': false,
        'displayTiming': 'Closed on ${today}s',
        'statusText': 'Closed today'
      };
    }

    // Check current status
    return _getCurrentStatus(now, todayTiming);
  }

  /// Get current day of week
  static String _getDayOfWeek(DateTime date) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    return days[date.weekday - 1];
  }

  /// Check if today is a holiday
  static bool _isHolidayToday(DateTime date, List<HolidayModel> holidays) {
    return holidays.any((holiday) {
      final holidayDate = DateTime.parse(holiday.holidayDate);
      return date.year == holidayDate.year &&
          date.month == holidayDate.month &&
          date.day == holidayDate.day;
    });
  }

  /// Get holiday information if today is a holiday
  static HolidayModel _getHolidayInfo(
    DateTime date,
    List<HolidayModel> holidays,
  ) {
    try {
      return holidays.firstWhere((holiday) {
        final holidayDate = DateTime.parse(holiday.holidayDate);
        return date.year == holidayDate.year &&
            date.month == holidayDate.month &&
            date.day == holidayDate.day;
      });
    } catch (e) {
      AppLogger.logWarning('$TAG: No holiday info found for date: $date');
      return HolidayModel(
        name: 'Unknown Holiday',
        holidayDate: date.toString(),
      );
    }
  }

  /// Get timing for today
  static TimingModel? _getTodayTiming(
    String day,
    List<TimingModel> timings,
  ) {
    try {
      return timings.firstWhere(
        (timing) => timing.isDayOpen(day),
      );
    } catch (e) {
      AppLogger.logInfo('$TAG: No timing found for $day');
      return null;
    }
  }

  /// Get current status based on timing
  static Map<String, dynamic> _getCurrentStatus(
    DateTime now,
    TimingModel timing,
  ) {
    final currentTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );

    final openTime = _parseTime(timing.startTime);
    final closeTime = _parseTime(timing.endTime);

    final isOpen =
        currentTime.isAfter(openTime) && currentTime.isBefore(closeTime);

    if (isOpen) {
      return {
        'isOpen': true,
        'displayTiming': 'Closes at ${_formatTime(closeTime)}',
        'statusText': 'Open'
      };
    } else if (currentTime.isBefore(openTime)) {
      return {
        'isOpen': false,
        'displayTiming': 'Opens at ${_formatTime(openTime)}',
        'statusText': 'Closed'
      };
    } else {
      return {
        'isOpen': false,
        'displayTiming': 'Opens tomorrow at ${_formatTime(openTime)}',
        'statusText': 'Closed'
      };
    }
  }

  /// Parse time string to DateTime
  static DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Format DateTime to time string
  static String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
