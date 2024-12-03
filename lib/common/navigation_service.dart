// import 'package:cw_food_ordering/core/3. main/main_screen.dart';
// import 'package:flutter/material.dart';
//
// class NavigationService {
//   static void navigateToMainScreen(BuildContext context, int tabIndex) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MainScreen(initialIndex: tabIndex),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../features/main/main_screen.dart';

class NavigationService {
  static void navigateToMainScreen(BuildContext context, int tabIndex) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MainScreen(initialIndex: tabIndex),
      ),
      (Route<dynamic> route) =>
          route.isFirst, // Keep only the first route (MainScreen)
    );
  }
}
