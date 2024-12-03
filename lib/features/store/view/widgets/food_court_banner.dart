import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../common/log/loggers.dart';
import '../../../../../common/styles/app_text_styles.dart';

class FoodCourtBanner extends StatelessWidget {
  static const String TAG = '[FoodCourtBanner]';

  final String name;
  final VoidCallback onTap;

  const FoodCourtBanner({
    super.key,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.logDebug('$TAG: Building banner with name: $name');

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: Colors.white.withOpacity(0.9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            _buildBackgroundGradient(),
            _buildOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      width: double.maxFinite,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[400]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      width: double.maxFinite,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withOpacity(0.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 30,
            child: SvgPicture.asset(
              'assets/images/svg/food_location.svg',
              color: Colors.white,
            ),
          ),
          Text(
            name,
            style: AppTextStyles.h4.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// // File: screens/home/widgets/food_court_banner.dart
//
// import 'package:flutter/material.dart';
//
// import '../../../common/log/loggers.dart';
// import '../../../common/styles/app_text_styles.dart';
//
// class FoodCourtBanner extends StatelessWidget {
//   static const String TAG = '[FoodCourtBanner]';
//
//   final String name;
//   final VoidCallback onTap;
//
//   const FoodCourtBanner({
//     super.key,
//     required this.name,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     AppLogger.logDebug('$TAG: Building banner with name: $name');
//
//     return Card(
//       elevation: 0,
//       margin: EdgeInsets.zero,
//       child: InkWell(
//         onTap: onTap,
//         child: Stack(
//           children: [
//             _buildBackgroundImage(),
//             _buildOverlay(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBackgroundImage() {
//     return Container(
//       width: double.infinity,
//       height: 60,
//       decoration: const BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage('assets/images/food_court.png'),
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOverlay() {
//     return Container(
//       width: double.infinity,
//       height: 60,
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.4),
//       ),
//       alignment: Alignment.center,
//       child: Text(
//         name,
//         style: AppTextStyles.h4.copyWith(color: Colors.white),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }
