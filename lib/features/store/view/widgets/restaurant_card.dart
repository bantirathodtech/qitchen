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

        AppLogger.logDebug(
          '$TAG: Building card for ${restaurant.name} '
              '(Status: ${status['statusText']})',
        );

        return GestureDetector(
          onTap: onTap,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            // elevation: 4,
            elevation: 0,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 16),
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
                        errorBuilder: (context, error, stackTrace) {
                          AppLogger.logError('$TAG: Error loading image: $error');
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.restaurant, color: Colors.grey),
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

                        // Restaurant type
                        if (restaurant.shortDescription != null)
                          Text(
                            restaurant.shortDescription!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                        const SizedBox(height: 8),

                        // Status and timing
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Status (Open/Closed)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: status['isOpen']
                                      ? Colors.green[70]
                                      : Colors.red[70],
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: status['isOpen']
                                        ? Colors.green
                                        : Colors.red,
                                    width: 0.4,
                                  ),
                                ),
                                child: Text(
                                  status['isOpen'] ? "Open" : "Closed",
                                  style: TextStyle(
                                    color: status['isOpen'] ? Colors.green : Colors.red,
                                    fontSize: 9,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // Timing
                              Text(
                                status['displayTiming'],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
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

//
//
// import 'package:cw_food_ordering/features/store/model/store_models.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../../../common/log/loggers.dart';
// import '../../../../../../common/styles/app_text_styles.dart';
// import '../../viewmodel/home_viewmodel.dart';
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
//           '(Status: ${status['statusText']})',
//         );
//
//         return GestureDetector(
//           onTap: onTap,
//           child: Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             elevation: 1,
//             margin: const EdgeInsets.symmetric(vertical: 8),
//             child: Stack(
//               children: [
//                 buildImageStack(status),
//                 Positioned(
//                   bottom: 0,
//                   left: 0,
//                   right: 0,
//                   child: buildDetailsCard(status),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget buildImageStack(Map<String, dynamic> status) {
//     return ClipRRect(
//       borderRadius: const BorderRadius.all(Radius.circular(16)),
//       child: SizedBox(
//         width: double.maxFinite,
//         height: 230,
//         child: Image.network(
//           restaurant.storeImage,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             AppLogger.logError('$TAG: Error loading image: $error');
//             return const Placeholder();
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget buildDetailsCard(Map<String, dynamic> status) {
//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.9),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//           bottomLeft: Radius.circular(16),
//           bottomRight: Radius.circular(16),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           buildHeader(status),
//           const SizedBox(height: 4),
//           buildTypeAndTiming(status),
//           if (restaurant.shortDescription != null) ...[
//             const SizedBox(height: 4),
//             buildDescription(),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget buildHeader(Map<String, dynamic> status) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Text(
//             restaurant.name,
//             style: AppTextStyles.h3,
//           ),
//         ),
//         Text(
//           status['isOpen'] ? "Open" : "Close",
//           style: AppTextStyles.statusTextStyle.copyWith(
//             color: status['isOpen'] ? Colors.green : Colors.red,
//             // fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget buildTypeAndTiming(Map<String, dynamic> status) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           restaurant.shortDescription ?? 'Type of restaurant',
//           style: const TextStyle(
//             fontSize: 12,
//             color: Colors.grey,
//           ),
//         ),
//         Text(
//           status['displayTiming'],
//           style: const TextStyle(
//             fontSize: 12,
//             color: Colors.grey,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget buildDescription() {
//     return Text(
//       restaurant.shortDescription!,
//       style: const TextStyle(
//         fontSize: 14,
//         color: Colors.black54,
//       ),
//       maxLines: 2,
//       overflow: TextOverflow.ellipsis,
//     );
//   }
// }
