// product_filters.dart
import 'package:flutter/material.dart';

import '../../../../common/log/loggers.dart';
import '../../../common/styles/custom_switch.dart';
import 'menu_dialog.dart';

class ProductFilters extends StatelessWidget {
  static const String TAG = '[ProductFilters]';

  final bool isVegOnly;
  final ValueChanged<bool> onVegFilterChanged;
  final String? selectedMenu; // Changed back to nullable
  final ValueChanged<String?> onMenuSelected;

  const ProductFilters({
    super.key,
    required this.isVegOnly,
    required this.onVegFilterChanged,
    required this.selectedMenu,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // Removes the shadow
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildVegFilter(),
            // _buildHealthyFilter(context),
            _buildMenuFilter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVegFilter() {
    return Row(
      children: [
        Text(
          'Veg Only',
          style:
              TextStyle(fontSize: 12, color: Colors.black), // Adjust text size
        ),
        SizedBox(width: 8), // Spacing between text and toggle
        CustomSwitch(
          value: isVegOnly,
          onChanged: (value) {
            onVegFilterChanged(value); // Notify parent widget about the change
          },
        ),
      ],
    );
  }

  // Widget _buildVegFilter() {
  //   return Row(
  //     children: [
  //       const Text('Veg Only'),
  //       Switch(
  //         value: isVegOnly,
  //         onChanged: onVegFilterChanged,
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildVegFilter() {
  //   return Row(
  //     children: [
  //       const Text(
  //         'Veg Only',
  //         style: TextStyle(fontSize: 12), // Adjust text size
  //       ),
  //       SizedBox(
  //         width: 60, // Adjust the width of the toggle
  //         // height: 10, // Adjust the height of the toggle
  //         child: Transform.scale(
  //           scale: 0.6, // Adjust the scale to resize the toggle button
  //           child: Switch(
  //             value: isVegOnly,
  //             onChanged: onVegFilterChanged,
  //             activeColor: Colors.green, // Set the color to green
  //             activeTrackColor: Colors.green
  //                 .withOpacity(0.3), // Optional: change the track color
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildHealthyFilter(BuildContext context) {
  //   return Expanded(
  //     child: GestureDetector(
  //       onTap: () => _showHealthyOptionsDialog(context),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: const [
  //           Text(
  //             'Healthy',
  //             style: TextStyle(
  //               color: Colors.black,
  //               fontFamily: 'Inter',
  //               fontSize: 14,
  //             ),
  //           ),
  //           SizedBox(width: 4),
  //           Icon(
  //             Icons.local_hospital,
  //             color: Colors.black,
  //             size: 14,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showHealthyOptionsDialog(BuildContext context) {
    AppLogger.logInfo('$TAG: Showing healthy options dialog');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Healthy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Show Nutrition Value'),
              value: false,
              onChanged: (value) {
                AppLogger.logInfo(
                    '$TAG: Show Nutrition Value selected: $value');
              },
            ),
            CheckboxListTile(
              title: const Text('Show Allergens'),
              value: false,
              onChanged: (value) {
                AppLogger.logInfo('$TAG: Show Allergens selected: $value');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuFilter(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showMenuDialog(context),
      // icon: Icon(
      //   Icons.restaurant_menu,
      //   color: Colors.black, // Set the icon color to black
      // ),
      label: Text(
        'Categories: $selectedMenu',
        style: TextStyle(
            fontSize: 14, color: Colors.black), // Set the label color to black
      ),
      // icon: Icon(
      //   Icons.arrow_drop_down,
      //   color: Colors.black, // Set the icon color to black
      // ),
      icon: Image.asset(
        'assets/images/categories.png',
        width: 20, // You can adjust the width and height as needed
        height: 20, // Adjust height to match your UI
      ),
    );
  }

  void _showMenuDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MenuDialog(
        selectedMenu: selectedMenu,
        onMenuSelected: onMenuSelected,
      ),
    );
  }
}
