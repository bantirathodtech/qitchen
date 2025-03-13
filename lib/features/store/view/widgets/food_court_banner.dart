import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../common/log/loggers.dart';
import '../../../../../common/styles/app_text_styles.dart';

class FoodCourtBanner extends StatelessWidget {
  static const String TAG = '[FoodCourtBanner]';

  final String name;
  final VoidCallback onTap;
  final VoidCallback onLocationSelect;


  const FoodCourtBanner({
    super.key,
    required this.name,
    required this.onTap,
    required this.onLocationSelect,

  });

  @override
  Widget build(BuildContext context) {
    AppLogger.logDebug('$TAG: Building banner with name: $name');

    return Card(
      // elevation: 4,
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      // shadowColor: Colors.white.withOpacity(0.9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // _buildBackgroundGradient(),
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
        color: Colors.white.withOpacity(0.4),
        border: Border.all(
          color: Colors.grey.shade300,  // Light grey border
          width: 0.5,  // Adjust thickness as needed
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Location icon before the name
          SizedBox(
            width: 20,
            height: 30,
            child: SvgPicture.asset(
              'assets/images/svg/food_location.svg',
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.map, color: Colors.red,),
          const SizedBox(width: 8),

          // Name text
          Text(
            name,
            style: AppTextStyles.h5b.copyWith(
              // color: Colors.black,
              // fontSize: 16,
              fontFamily: 'Inter',
              // fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(width: 8),

          // Dropdown icon after the name
          GestureDetector(
            onTap: onLocationSelect,
            child: Icon(
              Icons.keyboard_arrow_down_sharp,
              color: Colors.black,
              size: 30,
            ),
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
