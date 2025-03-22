// widgets/product_app_bar.dart
import 'package:flutter/material.dart';

import '../notifications/view/notifications_screen.dart';

class ProductAppBar extends StatelessWidget {
  static const String TAG = '[ProductAppBar]';

  final String storeImage;
  final VoidCallback onBack;

  const ProductAppBar({
    super.key,
    required this.storeImage,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      expandedHeight: 200,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(storeImage, fit: BoxFit.cover),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: onBack,
          ),
          Image.asset('assets/images/cw_image.png', height: 30),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () => _navigateToNotifications(context),
          ),
        ],
      ),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationsScreen()),
    );
  }
}
