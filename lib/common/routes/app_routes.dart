import 'package:flutter/material.dart';

import '../../features/auth/signin/signin_screen.dart';
import '../../features/auth/splash/splash_screen.dart';
import '../../features/main/main_screen.dart';
import '../../features/menu/menu_screen.dart';
import '../../features/products/view/product_screen.dart'; // Add this import
import '../../features/store/view/screen/home_screen.dart';

class Routes {
  static const String splashScreen = '/';
  static const String mainScreen = '/main';
  static const String signUpScreen = '/signup';
  static const String signInScreen = '/signin';
  static const String homeScreen = '/home';
  static const String cartView = '/cart';
  static const String menuView = '/menu';
  static const String walletView = '/wallet';
  static const String productScreen = '/product'; // Add this line

  static Map<String, WidgetBuilder> get routes {
    return {
      splashScreen: (context) => const SplashScreen(),
      mainScreen: (context) => const MainScreen(),
      signInScreen: (context) => const SignInScreen(),
      homeScreen: (context) => const HomeScreen(),
      menuView: (context) => MenuScreen(
            onBackPressed: () => navigateToMainScreen(context, 0),
          ),
      productScreen: (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ProductScreen(
          storeId: args['storeId'] as String,
          storeImage: args['storeImage'] as String,
          restaurantName: args['restaurantName'] as String,
          // csBunitId: args['csBunitId'] as String,
          isOpen: args['isOpen'] as bool,
          displayTiming: args['displayTiming'] as String,
          shortDescription: args['shortDescription'] as String?,
        );
      },
    };
  }

  static void navigateToProduct(
    BuildContext context, {
    required String storeId,
    required String storeImage,
    required String restaurantName,
    required String csBunitId,
    required bool isOpen,
    required String displayTiming,
    String? shortDescription,
  }) {
    Navigator.pushNamed(
      context,
      productScreen,
      arguments: {
        'storeId': storeId,
        'storeImage': storeImage,
        'restaurantName': restaurantName,
        'csBunitId': csBunitId,
        'isOpen': isOpen,
        'displayTiming': displayTiming,
        'shortDescription': shortDescription,
      },
    );
  }

  static void navigateToWallet(BuildContext context,
      {String? walletId, String? amount}) {
    Navigator.pushNamed(
      context,
      walletView,
      arguments: {
        'walletId': walletId ?? '',
        'amount': amount ?? '',
      },
    );
  }

  static void navigateToMainScreen(BuildContext context, int tabIndex) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(initialIndex: tabIndex),
      ),
      (route) => false,
    );
  }

  static void navigateToCartTab(BuildContext context) {
    navigateToMainScreen(
        context, 1); // Assuming cart is the second tab (index 1)
  }
}
