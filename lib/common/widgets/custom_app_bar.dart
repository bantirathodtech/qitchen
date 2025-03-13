import 'package:flutter/material.dart';

import '../../features/notifications/view/notifications_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String logoPath;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions; // New parameter for custom actions
  final bool
      showNotification; // New parameter to control notification visibility

  const CustomAppBar({
    super.key,
    required this.logoPath,
    this.onBackPressed,
    this.actions,
    this.showNotification = true, // Default to showing notification
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
          ),
          Image.asset(
            logoPath,
            height: 30,
          ),
          // Show either custom actions or notification button
          if (actions != null)
            ...actions!
          else if (showNotification)
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.black),
              onPressed: () => _navigateToScreen(
                context,
                NotificationsScreen(),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}
