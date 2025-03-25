import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/cache/app_prefetch_manager.dart';
import '../cart/multiple/cart_screen.dart';
import '../home/widgets/main_bottom_navigation_bar.dart';
import '../menu/menu_screen.dart';
import '../store/view/screen/home_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    // Add this section to prefetch data in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Prefetch app data in background without blocking UI
      AppPrefetchManager.prefetchAppData(context);
    });
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      onItemTapped(0);
      return false;
    }
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            const HomeScreen(),
            CartScreen(onBackPressed: () => onItemTapped(0)),
            MenuScreen(onBackPressed: () => onItemTapped(0)),
          ],
        ),
        bottomNavigationBar: MainBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: onItemTapped,
        ),
        // bottomNavigationBar: Consumer<CartManager>(
        //   builder: (context, cartManager, child) {
        //     return BottomNavigationBar(
        //       backgroundColor: Colors.white,
        //       currentIndex: _selectedIndex,
        //       onTap: onItemTapped,
        //       // selectedItemColor: Theme.of(context).primaryColor,
        //       selectedItemColor: Colors.black,
        //       unselectedItemColor: Colors.grey,
        //       items: [
        //         const BottomNavigationBarItem(
        //           icon: Icon(Icons.home),
        //           label: 'Home',
        //         ),
        //         BottomNavigationBarItem(
        //           icon: Badge(
        //             isLabelVisible: cartManager.itemCount > 0,
        //             label: Text('${cartManager.itemCount}'),
        //             child: const Icon(Icons.shopping_cart),
        //           ),
        //           label: 'Cart',
        //         ),
        //         const BottomNavigationBarItem(
        //           icon: Icon(Icons.menu),
        //           label: 'Menu',
        //         ),
        //       ],
        //     );
        //   },
        // ),
      ),
    );
  }
}
