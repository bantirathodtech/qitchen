// File: models/store_models.dart

import '../../../../common/log/loggers.dart';

/// Main store model containing all store-related data
class StoreModel {
  static const String TAG = '[StoreModel]';

  final String name;
  final String promotionBanner;
  final String announcement;
  final String darkTheme;
  final List<RestaurantModel> restaurants;

  StoreModel({
    required this.name,
    required this.promotionBanner,
    required this.announcement,
    required this.darkTheme,
    required this.restaurants,
  });

  // factory StoreModel.fromJson(Map<String, dynamic> json) {
  //   AppLogger.logInfo('$TAG: Parsing store model from JSON');
  //
  //   try {
  //     return StoreModel(
  //       name: json['name'] ?? '',
  //       promotionBanner: json['promotionBanner'] ?? '',
  //       announcement: json['announcement'] ?? '',
  //       darkTheme: json['darkTheme'] ?? '',
  //       restaurants: (json['storeConfig'] as List? ?? [])
  //           .map((e) => RestaurantModel.fromJson(e))
  //           .toList(),
  //     );
  //   } catch (e) {
  //     AppLogger.logError('$TAG: Error parsing store model: $e');
  //     rethrow;
  //   }
  // }

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    AppLogger.logInfo('$TAG: Parsing store model from JSON');

    try {
      String promotionBanner = json['promotionBanner'] ?? '';

      // Clean promotion banner URL if present
      if (promotionBanner.isNotEmpty) {
        promotionBanner = promotionBanner
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll('&amp;', '&')
            .trim();

        // Validate URL
        try {
          final uri = Uri.parse(promotionBanner);
          if (!uri.isScheme('http') && !uri.isScheme('https')) {
            promotionBanner = '';
          }
        } catch (e) {
          AppLogger.logWarning('$TAG: Invalid promotion banner URL: $e');
          promotionBanner = '';
        }
      }

      return StoreModel(
        name: json['name'] ?? '',
        promotionBanner: promotionBanner,
        announcement: json['announcement'] ?? '',
        darkTheme: json['darkTheme'] ?? '',
        restaurants: (json['storeConfig'] as List? ?? [])
            .map((e) => RestaurantModel.fromJson(e))
            .toList(),
      );
    } catch (e) {
      AppLogger.logError('$TAG: Error parsing store model: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'promotionBanner': promotionBanner,
        'announcement': announcement,
        'darkTheme': darkTheme,
        'storeConfig': restaurants.map((e) => e.toJson()).toList(),
      };
}

/// Model representing individual restaurants
class RestaurantModel {
  static const String TAG = '[RestaurantModel]';

  final String name;
  final String? shortDescription;
  final String storeImage;
  final String storeId;
  final BusinessUnitModel businessUnit;
  final List<TimingModel> timings;
  final List<HolidayModel> holidays;

  RestaurantModel({
    required this.name,
    this.shortDescription,
    required this.storeImage,
    required this.storeId,
    required this.businessUnit,
    required this.timings,
    required this.holidays,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    AppLogger.logInfo('$TAG: Parsing restaurant: ${json['name']}');

    return RestaurantModel(
      name: json['name'] ?? '',
      shortDescription: json['shortDescription'],
      storeImage: json['storeImage'] ?? '',
      storeId: json['storeId'] ?? '',
      businessUnit: BusinessUnitModel.fromJson(json['csBunit'] ?? {}),
      timings: (json['storeTimings'] as List? ?? [])
          .map((e) => TimingModel.fromJson(e))
          .toList(),
      holidays: (json['storeHolidays'] as List? ?? [])
          .map((e) => HolidayModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'shortDescription': shortDescription,
        'storeImage': storeImage,
        'storeId': storeId,
        'csBunit': businessUnit.toJson(),
        'storeTimings': timings.map((e) => e.toJson()).toList(),
        'storeHolidays': holidays.map((e) => e.toJson()).toList(),
      };
}

/// Model for business unit information
class BusinessUnitModel {
  final String csBunitId;
  final String? value;
  final String? name;

  BusinessUnitModel({
    required this.csBunitId,
    this.value,
    this.name,
  });

  factory BusinessUnitModel.fromJson(Map<String, dynamic> json) =>
      BusinessUnitModel(
        csBunitId: json['csBunitId'] ?? '',
        value: json['value'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'csBunitId': csBunitId,
        'value': value,
        'name': name,
      };
}

/// Model for store timing information
class TimingModel {
  static const String TAG = '[TimingModel]';

  final String startTime;
  final String endTime;
  final Map<String, bool> days;

  TimingModel({
    required this.startTime,
    required this.endTime,
    required this.days,
  });

  // factory TimingModel.fromJson(Map<String, dynamic> json) {
  //   AppLogger.logDebug('$TAG: Parsing timing data');
  //
  //   return TimingModel(
  //     startTime: json['startTime'] ?? '',
  //     endTime: json['endTime'] ?? '',
  //     days: {
  //       'monday': json['isMonday'] == 'Y',
  //       'tuesday': json['isTuesday'] == 'Y',
  //       'wednesday': json['isWednesday'] == 'Y',
  //       'thursday': json['isThursday'] == 'Y',
  //       'friday': json['isFriday'] == 'Y',
  //       'saturday': json['isSaturday'] == 'Y',
  //       'sunday': json['isSunday'] == 'Y',
  //     },
  //   );
  // }
  factory TimingModel.fromJson(Map<String, dynamic> json) {
    AppLogger.logDebug('$TAG: Parsing timing data');

    // Ensure we have non-null values to work with
    final startTime = json['startTime'] ?? '';
    final endTime = json['endTime'] ?? '';

    return TimingModel(
      startTime: startTime,
      endTime: endTime,
      days: {
        'monday': json['isMonday'] == 'Y',
        'tuesday': json['isTuesday'] == 'Y',
        'wednesday': json['isWednesday'] == 'Y',
        'thursday': json['isThursday'] == 'Y',
        'friday': json['isFriday'] == 'Y',
        'saturday': json['isSaturday'] == 'Y',
        'sunday': json['isSunday'] == 'Y',
      },
    );
  }

  Map<String, dynamic> toJson() => {
        'startTime': startTime,
        'endTime': endTime,
        'isMonday': days['monday'] == true ? 'Y' : 'N',
        'isTuesday': days['tuesday'] == true ? 'Y' : 'N',
        'isWednesday': days['wednesday'] == true ? 'Y' : 'N',
        'isThursday': days['thursday'] == true ? 'Y' : 'N',
        'isFriday': days['friday'] == true ? 'Y' : 'N',
        'isSaturday': days['saturday'] == true ? 'Y' : 'N',
        'isSunday': days['sunday'] == true ? 'Y' : 'N',
      };

  bool isDayOpen(String day) => days[day.toLowerCase()] ?? false;
}

/// Model for holiday information
class HolidayModel {
  final String name;
  final String holidayDate;

  HolidayModel({
    required this.name,
    required this.holidayDate,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) => HolidayModel(
        name: json['name'] ?? '',
        holidayDate: json['holidayDate'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'holidayDate': holidayDate,
      };
}
