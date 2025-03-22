import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main/main_screen.dart';
import '../cart/multiple/cart_manager.dart';

/// Standalone bottom navigation bar without tab highlighting
/// Used in product/detail screens where no tab should be highlighted
class StandaloneBottomNavigationBar extends StatelessWidget {
  /// Callback when a tab is tapped, defaults to navigation to MainScreen
  final Function(int)? onTap;

  /// Optional builder context for more complex navigation patterns
  final BuildContext? navigationContext;

  const StandaloneBottomNavigationBar({
    Key? key,
    this.onTap,
    this.navigationContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctx = navigationContext ?? context;

    return Consumer<CartManager>(
      builder: (context, cartManager, child) {
        return BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: 0, // Default index, but will be visually ignored
          selectedItemColor: Colors.grey, // All items are grey (no highlighting)
          unselectedItemColor: Colors.grey, // All items are grey
          type: BottomNavigationBarType.fixed,
          onTap: onTap ?? (index) {
            // Default navigation behavior if no custom onTap provided
            Navigator.pushReplacement(
              ctx,
              MaterialPageRoute(
                builder: (context) => MainScreen(initialIndex: index),
              ),
            );
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: cartManager.itemCount > 0,
                label: Text('${cartManager.itemCount}'),
                child: const Icon(Icons.shopping_cart),
              ),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'Menu',
            ),
          ],
        );
      },
    );
  }
}