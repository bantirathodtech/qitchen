import 'package:flutter/material.dart';

import '../../../common/log/loggers.dart';
import '../../store/model/store_models.dart';
import '../../store/view/widgets/restaurant_card.dart';

class RestaurantList extends StatelessWidget {
  static const String TAG = '[RestaurantList]';

  final List<RestaurantModel> restaurants;
  final ValueChanged<RestaurantModel> onRestaurantSelected;

  const RestaurantList({
    super.key,
    required this.restaurants,
    required this.onRestaurantSelected,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.logDebug(
        '$TAG: Building list with ${restaurants.length} restaurants');

    // Add a check for empty restaurants list
    if (restaurants.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            'No restaurants available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: restaurants.length * 2 - 1, // This is safe now that we check for empty list
      itemBuilder: (context, index) {
        if (index.isOdd) {
          // Add a thin, dark grey divider between restaurant cards
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Divider(
              color: Colors.grey[500], // Darker grey color
              thickness: 0.1, // Thin line
              height: 1, // Minimal height
            ),
          );
        } else {
          // Normal restaurant card
          final restaurant = restaurants[index ~/ 2]; // Adjust index
          return RestaurantCard(
            restaurant: restaurant,
            onTap: () => onRestaurantSelected(restaurant),
          );
        }
      },
    );
  }
}

//
//   @override
//   Widget build(BuildContext context) {
//     AppLogger.logDebug(
//         '$TAG: Building list with ${restaurants.length} restaurants');
//
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: restaurants.length * 2 - 1, // Adjust count to insert dividers
//       itemBuilder: (context, index) {
//         if (index.isOdd) {
//           // Add the styled container between restaurant cards
//           return Container(
//             margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.05),
//                   spreadRadius: 0.5,
//                   blurRadius: 10,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             height: 12, // Adjust height to fit between cards
//           );
//         } else {
//           // Normal restaurant card
//           final restaurant = restaurants[index ~/ 2]; // Adjust index
//           return RestaurantCard(
//             restaurant: restaurant,
//             onTap: () => onRestaurantSelected(restaurant),
//           );
//         }
//       },
//     );
//   }
// }
