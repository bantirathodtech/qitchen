import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cart/multiple/cart_manager.dart';

/// Main bottom navigation bar with tab highlighting support
/// Used in the main screen where tabs should be highlighted
class MainBottomNavigationBar extends StatelessWidget {
  /// The index of the currently selected tab (0-based)
  final int currentIndex;

  /// Callback function when a tab is tapped
  final Function(int) onTap;

  const MainBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartManager>(
      builder: (context, cartManager, child) {
        return BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
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