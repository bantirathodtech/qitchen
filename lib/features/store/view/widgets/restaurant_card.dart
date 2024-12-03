import 'package:cw_food_ordering/features/store/model/store_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../common/log/loggers.dart';
import '../../../../../../common/styles/app_text_styles.dart';
import '../../viewmodel/home_viewmodel.dart';

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
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Stack(
              children: [
                buildImageStack(status),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: buildDetailsCard(status),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildImageStack(Map<String, dynamic> status) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: SizedBox(
        width: double.maxFinite,
        height: 230,
        child: Image.network(
          restaurant.storeImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            AppLogger.logError('$TAG: Error loading image: $error');
            return const Placeholder();
          },
        ),
      ),
    );
  }

  Widget buildDetailsCard(Map<String, dynamic> status) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader(status),
          const SizedBox(height: 4),
          buildTypeAndTiming(status),
          if (restaurant.shortDescription != null) ...[
            const SizedBox(height: 4),
            buildDescription(),
          ],
        ],
      ),
    );
  }

  Widget buildHeader(Map<String, dynamic> status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            restaurant.name,
            style: AppTextStyles.h3,
          ),
        ),
        Text(
          status['isOpen'] ? "Open" : "Close",
          style: AppTextStyles.statusTextStyle.copyWith(
            color: status['isOpen'] ? Colors.green : Colors.red,
            // fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildTypeAndTiming(Map<String, dynamic> status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          restaurant.shortDescription ?? 'Type of restaurant',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          status['displayTiming'],
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget buildDescription() {
    return Text(
      restaurant.shortDescription!,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
