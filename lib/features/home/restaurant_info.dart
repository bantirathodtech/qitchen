// widgets/restaurant_info.dart
import 'package:flutter/material.dart';

class RestaurantInfo extends StatelessWidget {
  static const String TAG = '[RestaurantInfo]';

  final String name;
  final String? description;
  final bool isOpen;
  final String displayTiming;

  const RestaurantInfo({
    super.key,
    required this.name,
    this.description,
    required this.isOpen,
    required this.displayTiming,
    required String businessUnitId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (description != null)
              Text(
                description!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isOpen ? 'Open' : 'Closed',
              style: TextStyle(color: isOpen ? Colors.green : Colors.red),
            ),
            Text(
              displayTiming,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
