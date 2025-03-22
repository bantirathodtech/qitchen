import 'package:flutter/material.dart';
import '../../../../common/log/loggers.dart';
import '../../../common/styles/custom_switch.dart';
import 'menu_dialog.dart';

class ProductFilters extends StatelessWidget {
  static const String TAG = '[ProductFilters]';

  final bool isVegOnly; // Current veg-only filter state
  final ValueChanged<bool> onVegFilterChanged; // Callback to toggle veg filter
  // final String? selectedMenu; // Selected menu, nullable as per ViewModel
  // final ValueChanged<String?> onMenuSelected; // Callback to update selected menu

  const ProductFilters({
    super.key,
    required this.isVegOnly,
    required this.onVegFilterChanged,
    // required this.selectedMenu,
    // required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Step 1: Build filter card with veg toggle and menu selector
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildVegFilter(), // Veg filter toggle
            // _buildMenuFilter(context), // Menu filter button
          ],
        ),
      ),
    );
  }

  // Step 2: Build veg filter toggle
  Widget _buildVegFilter() {
    return Row(
      children: [
        const Text(
          'Veg Only',
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
        const SizedBox(width: 8),
        CustomSwitch(
          value: isVegOnly,
          onChanged: (value) {
            AppLogger.logInfo('$TAG: Veg filter toggled to $value');
            onVegFilterChanged(value); // Notify ViewModel to update state
          },
        ),
      ],
    );
  }

  // // Step 3: Build menu filter button with dialog trigger
  // Widget _buildMenuFilter(BuildContext context) {
  //   return TextButton.icon(
  //     onPressed: () => _showMenuDialog(context),
  //     label: Text(
  //       'Categories: ${selectedMenu ?? "All"}', // Display selected menu or "All"
  //       style: const TextStyle(fontSize: 14, color: Colors.black),
  //     ),
  //     icon: Image.asset(
  //       'assets/images/categories.png',
  //       width: 20,
  //       height: 20,
  //     ),
  //   );
  // }
  //
  // // Step 4: Show menu selection dialog
  // void _showMenuDialog(BuildContext context) {
  //   AppLogger.logInfo('$TAG: Opening menu dialog');
  //   showDialog(
  //     context: context,
  //     builder: (context) => MenuDialog(
  //       selectedMenu: selectedMenu,
  //       onMenuSelected: (menu) {
  //         AppLogger.logInfo('$TAG: Menu selected in dialog: $menu');
  //         onMenuSelected(menu); // Pass selection back to ViewModel
  //       },
  //     ),
  //   );
  // }
}

