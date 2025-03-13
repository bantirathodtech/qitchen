import 'package:flutter/material.dart';

import '../3/search_overlay_screen.dart';

void showSearchOverlayDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    transitionDuration: const Duration(milliseconds: 300),
    barrierColor: Colors.black.withOpacity(0.5),
    pageBuilder: (context, _, __) {
      return const SearchOverlayScreen();
    },
    transitionBuilder: (context, animation, _, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}
