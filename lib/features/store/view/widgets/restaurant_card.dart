import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../common/log/loggers.dart';
import '../../../../../../common/styles/app_text_styles.dart';
import '../../viewmodel/home_viewmodel.dart';
import '../../../store/model/store_models.dart';

class RestaurantCard extends StatelessWidget {
  static const String TAG = '[RestaurantCard]';

  final RestaurantModel restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final status = viewModel.getRestaurantStatus(restaurant);

        // Enhanced logging to debug holiday data
        AppLogger.logDebug(
          '$TAG: Building card for ${restaurant.name} '
              '(Status: ${status['statusText']}, '
              'Holidays Count: ${restaurant.holidays.length}, '
              'First Holiday: ${restaurant.holidays.isNotEmpty ? "${restaurant.holidays.first.name} (${restaurant.holidays.first.holidayDate})" : "None"})',
        );

        return GestureDetector(
          onTap: onTap,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side - Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 130,
                      height: 130,
                      child: Image.network(
                        restaurant.storeImage,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          AppLogger.logError('$TAG: Error loading image: $error');
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.grey,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right side - Restaurant details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Restaurant name
                        Text(
                          restaurant.name,
                          style: AppTextStyles.h5b,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Description
                        Text(
                          restaurant.shortDescription ?? 'No description available',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Status and Timing
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Timing
                            Text(
                              status['displayTiming'],
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Status indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: status['isOpen']
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: status['isOpen'] ? Colors.green : Colors.red,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                status['isOpen'] ? "Open" : "Closed",
                                style: TextStyle(
                                  color: status['isOpen'] ? Colors.green : Colors.red,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Simplified Holiday Display for Debugging
                        Text(
                          restaurant.holidays.isNotEmpty
                              ? 'Holiday: ${restaurant.holidays.first.name} (${restaurant.holidays.first.holidayDate})'
                              : 'No upcoming holidays',
                          style: TextStyle(
                            fontSize: 10,
                            color: restaurant.holidays.isNotEmpty ? Colors.orange : Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../../../common/log/loggers.dart';
// import '../../../../../../common/styles/app_text_styles.dart';
// import '../../viewmodel/home_viewmodel.dart';
// import '../../../store/model/store_models.dart';
//
// class RestaurantCard extends StatelessWidget {
//   static const String TAG = '[RestaurantCard]';
//
//   final RestaurantModel restaurant;
//   final VoidCallback onTap;
//
//   const RestaurantCard({
//     super.key,
//     required this.restaurant,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<HomeViewModel>(
//       builder: (context, viewModel, child) {
//         final status = viewModel.getRestaurantStatus(restaurant);
//
//         AppLogger.logDebug(
//           '$TAG: Building card for ${restaurant.name} '
//               '(Status: ${status['statusText']})',
//         );
//
//         return GestureDetector(
//           onTap: onTap,
//           child: Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             // elevation: 4,
//             elevation: 0,
//             color: Colors.white,
//             margin: const EdgeInsets.only(bottom: 16),
//             child: Padding(
//               padding: const EdgeInsets.all(0.0),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Left side - Image
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: SizedBox(
//                       width: 130,
//                       height: 130,
//                       child: Image.network(
//                         restaurant.storeImage,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           AppLogger.logError('$TAG: Error loading image: $error');
//                           return Container(
//                             color: Colors.grey[300],
//                             child: const Icon(Icons.restaurant, color: Colors.grey),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(width: 12),
//
//                   // Right side - Restaurant details
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // Restaurant name
//                         Text(
//                           restaurant.name,
//                           style: AppTextStyles.h5b,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//
//                         const SizedBox(height: 4),
//
//                         // Restaurant type
//                         if (restaurant.shortDescription != null)
//                           Text(
//                             restaurant.shortDescription!,
//                             style: const TextStyle(
//                               fontSize: 10,
//                               color: Colors.grey,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//
//                         const SizedBox(height: 8),
//
//                         // Status and timing
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               // Status (Open/Closed)
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                                 decoration: BoxDecoration(
//                                   color: status['isOpen']
//                                       ? Colors.green[70]
//                                       : Colors.red[70],
//                                   borderRadius: BorderRadius.circular(4),
//                                   border: Border.all(
//                                     color: status['isOpen']
//                                         ? Colors.green
//                                         : Colors.red,
//                                     width: 0.4,
//                                   ),
//                                 ),
//                                 child: Text(
//                                   status['isOpen'] ? "Open" : "Closed",
//                                   style: TextStyle(
//                                     color: status['isOpen'] ? Colors.green : Colors.red,
//                                     fontSize: 9,
//                                     // fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//
//                               // Timing
//                               Text(
//                                 status['displayTiming'],
//                                 style: const TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
