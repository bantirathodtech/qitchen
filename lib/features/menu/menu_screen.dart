// import 'package:flutter/material.dart';
//
// import '../../../common/log/loggers.dart';
// import '../../../common/styles/app_text_styles.dart'; // Import global text styles
// import '../../../data/db/app_preferences.dart';
// import '../../common/widgets/custom_app_bar.dart';
// import '../auth/profile/profile_screen.dart';
// import '../auth/signin/signin_screen.dart';
// import '../favorite/favorite_view.dart';
// import '../history/view/order_history_screen.dart';
// import '../main/main_screen.dart';
// import '../wallet/view/wallet_view.dart';
//
// class MenuScreen extends StatefulWidget {
//   final VoidCallback onBackPressed;
//
//   const MenuScreen({super.key, required this.onBackPressed});
//
//   @override
//   MenuScreenState createState() => MenuScreenState();
// }
//
// class MenuScreenState extends State<MenuScreen> {
//   // late final VoidCallback onBackPressed;
//
//   String _firstName = 'User';
//   String _lastName = '';
//   bool _isLoading = true;
//   String _selectedMenu = 'Home';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }
//
//   Future<void> _loadUserData() async {
//     try {
//       final userData = await AppPreference.getUserData();
//       setState(() {
//         _firstName = userData['firstName'] ?? 'User';
//         _lastName = userData['lastName'] ?? '';
//         _isLoading = false;
//       });
//     } catch (e) {
//       AppLogger.logError('Error loading user data: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Widget _buildLoadingIndicator() {
//     return const Center(
//       child: CircularProgressIndicator(),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
// // Use the onBackPressed method from the widget
//         widget.onBackPressed();
//         return false;
//       },
//       child: Scaffold(
//         appBar: CustomAppBar(
//           logoPath: 'assets/images/cw_image.png',
//           onBackPressed:
//               widget.onBackPressed, // Access onBackPressed via widget
//         ),
//         body: Padding(
//           padding: const EdgeInsets.only(
//               left: 16.0, right: 16.0, top: 8.0), // Adjusted padding
//           child: _isLoading ? _buildLoadingIndicator() : _buildMenuContent(),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMenuContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildUserInfo(),
//         const Divider(), // Divider separating user info from menu items
//         const SizedBox(height: 16),
//         Expanded(
//           child: ListView(
//             children: _buildMenuItems(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Updated _buildUserInfo to use the new menuOptionStyle
//   Widget _buildUserInfo() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         IconButton(
//           icon: const Icon(Icons.person, size: 40),
//           onPressed: () {
//             _navigateToScreen(context, const ProfileScreen());
//           },
//         ),
//         const SizedBox(width: 16),
//         Text(
//           '$_firstName $_lastName',
//           style: AppTextStyles.menuOptionStyle, // Applied new text style
//         ),
//       ],
//     );
//   }
//
//   List<Widget> _buildMenuItems() {
//     return [
//       _buildMenuOption(
//         icon: Icons.home,
//         label: 'Home',
//         screen: const MainScreen(),
//       ),
//       _buildMenuOption(
//         icon: Icons.history,
//         label: 'Order History',
//         action: () => _navigateToOrderHistory(context), // Use custom navigation
//
//         // screen: const OrderHistoryScreen(
//         //   customerId: '',
//         // ),
//       ),
//       _buildMenuOption(
//         icon: Icons.account_balance_wallet,
//         label: 'Wallet',
//         screen: WalletPaymentHandler(
//           amount: 0.0,
//           onComplete: (bool success) {},
//         ),
//         // action: () => Routes.navigateToWallet(context),
//       ),
//       // _buildMenuOption(
//       //   icon: Icons.loyalty,
//       //   label: 'Loyalty',
//       //   screen: LoyaltyScreen(),
//       // ),
//       _buildMenuOption(
//         icon: Icons.favorite,
//         label: 'Favorites',
//         screen: const FavoriteView(),
//       ),
//       _buildMenuOption(
//         icon: Icons.logout,
//         label: 'Logout',
//         action: _handleLogout,
//       ),
//     ];
//   }
//
//   // Add this new method to handle Order History navigation
//   Future<void> _navigateToOrderHistory(BuildContext context) async {
//     try {
//       setState(() => _isLoading = true);
//
//       final userData = await AppPreference.getUserData();
//       final customerId = userData['b2cCustomerId'];
//
//       setState(() => _isLoading = false);
//
//       if (customerId == null || customerId.toString().isEmpty) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please login again to view order history'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//
//       if (!mounted) return;
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => OrderHistoryScreen(
//             customerId: customerId.toString(),
//           ),
//         ),
//       );
//     } catch (e) {
//       AppLogger.logError('Error navigating to order history: $e');
//
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   // Updated _buildMenuOption to use the new menuOptionStyle
//   Widget _buildMenuOption({
//     required IconData icon,
//     required String label,
//     Widget? screen,
//     VoidCallback? action,
//   }) {
//     bool isSelected = _selectedMenu == label;
//
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _selectedMenu = label;
//         });
//         if (action != null) {
//           action();
//         } else if (screen != null) {
//           _navigateToScreen(context, screen);
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.transparent,
//         ),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? Colors.blue : Colors.black,
//               size: 30,
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 label,
//                 style: isSelected
//                     ? AppTextStyles.menuOptionStyle.copyWith(
//                         color: Colors.blue) // Use new style for selected
//                     : AppTextStyles.menuOptionStyle, // Applied new text style
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _navigateToScreen(BuildContext context, Widget screen) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => screen),
//     );
//   }
//
//   void _handleLogout() async {
//     await AppPreference.clearUserData();
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const SignInScreen(),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../../common/log/loggers.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../data/db/app_preferences.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../auth/profile/profile_screen.dart';
import '../auth/signin/signin_screen.dart';
import '../favorite/favorite_view.dart';
import '../history/view/order_history_screen.dart';
import '../main/main_screen.dart';
import '../wallet/view/wallet_view.dart';

class MenuScreen extends StatefulWidget {
  final VoidCallback onBackPressed;

  const MenuScreen({super.key, required this.onBackPressed});

  @override
  MenuScreenState createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen> {
  String _firstName = 'First';
  String _lastName = 'Last';
  bool _isLoading = true;
  String _selectedMenu = 'Home';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await AppPreference.getUserData();
      setState(() {
        _firstName = userData['firstName'] ?? 'First';
        _lastName = userData['lastName'] ?? 'Last';
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.logError('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onBackPressed();
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          logoPath: 'assets/images/cw_image.png',
          onBackPressed: widget.onBackPressed,
        ),
        body: _isLoading
            ? _buildLoadingIndicator()
            : _buildMenuContent(),
      ),
    );
  }

  Widget _buildMenuContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfoCard(),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildMenuItems(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //     // colors: [Colors.blue.shade500, Colors.blue.shade700],
      //     colors: [Colors.blue.shade500, Colors.blue.shade700],
      //   ),
      // ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    _navigateToScreen(context, const ProfileScreen());
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_firstName $_lastName',
                      style: AppTextStyles.menuOptionStyle.copyWith(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () {
                        _navigateToScreen(context, const ProfileScreen());
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'View Account Details',
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.85),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    final List<MenuItemData> menuItems = [
      MenuItemData(
        icon: Icons.home,
        label: 'Home',
        screen: const MainScreen(),
      ),
      MenuItemData(
        icon: Icons.history,
        label: 'Order History',
        action: () => _navigateToOrderHistory(context),
      ),
      MenuItemData(
        icon: Icons.account_balance_wallet,
        label: 'Wallet',
        screen: WalletPaymentHandler(
          amount: 0.0,
          onComplete: (bool success) {},
        ),
      ),
      MenuItemData(
        icon: Icons.favorite,
        label: 'Favorites',
        screen: const FavoriteView(),
      ),
      MenuItemData(
        icon: Icons.logout,
        label: 'Logout',
        action: _handleLogout,
        isLogout: true,
      ),
    ];

    return ListView.separated(
      itemCount: menuItems.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey.withOpacity(0.2),
      ),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuOption(
          icon: item.icon,
          label: item.label,
          screen: item.screen,
          action: item.action,
          isLogout: item.isLogout,
        );
      },
    );
  }

  Future<void> _navigateToOrderHistory(BuildContext context) async {
    try {
      setState(() => _isLoading = true);

      final userData = await AppPreference.getUserData();
      final customerId = userData['b2cCustomerId'];

      setState(() => _isLoading = false);

      if (customerId == null || customerId.toString().isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login again to view order history'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderHistoryScreen(
            customerId: customerId.toString(),
          ),
        ),
      );
    } catch (e) {
      AppLogger.logError('Error navigating to order history: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    Widget? screen,
    VoidCallback? action,
    bool isLogout = false,
  }) {
    bool isSelected = _selectedMenu == label;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.black.withOpacity(0.1)
              : isLogout
              ? Colors.red.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? Colors.black
              : isLogout
              ? Colors.red
              : Colors.black87,
          size: 16,
        ),
      ),
      title: Text(
        label,
        style: AppTextStyles.menuOptionStyle.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Colors.black
              : isLogout
              ? Colors.red
              : Colors.black87,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isSelected
            ? Colors.black
            : isLogout
            ? Colors.red
            : Colors.grey,
        size: 24,
      ),
      onTap: () {
        setState(() {
          _selectedMenu = label;
        });
        if (action != null) {
          action();
        } else if (screen != null) {
          _navigateToScreen(context, screen);
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      selectedTileColor: Colors.blue.withOpacity(0.1),
      selected: isSelected,
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    await AppPreference.clearUserData();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInScreen(),
      ),
    );
  }
}

class MenuItemData {
  final IconData icon;
  final String label;
  final Widget? screen;
  final VoidCallback? action;
  final bool isLogout;

  MenuItemData({
    required this.icon,
    required this.label,
    this.screen,
    this.action,
    this.isLogout = false,
  });
}