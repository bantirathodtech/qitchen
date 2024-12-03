// menu_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/product_viewmodel.dart';

class MenuDialog extends StatelessWidget {
  final String? selectedMenu; // Changed back to nullable
  final ValueChanged<String?> onMenuSelected;

  const MenuDialog({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Menu'),
      content: Consumer<ProductViewModel>(
        builder: (context, viewModel, _) {
          final menus = viewModel.getAllMenus();
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: menus
                  .map(
                    (menu) => RadioListTile<String>(
                      title: Text(menu),
                      value: menu,
                      groupValue: selectedMenu,
                      onChanged: (value) {
                        onMenuSelected(value);
                        Navigator.pop(context);
                      },
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
