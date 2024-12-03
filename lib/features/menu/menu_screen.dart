import 'package:flutter/material.dart';

import '../../../common/log/loggers.dart';
import '../../../common/styles/app_text_styles.dart'; // Import global text styles
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
  // late final VoidCallback onBackPressed;

  String _firstName = 'User';
  String _lastName = '';
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
        _firstName = userData['firstName'] ?? 'User';
        _lastName = userData['lastName'] ?? '';
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
// Use the onBackPressed method from the widget
        widget.onBackPressed();
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          logoPath: 'assets/images/cw_image.png',
          onBackPressed:
              widget.onBackPressed, // Access onBackPressed via widget
        ),
        body: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 8.0), // Adjusted padding
          child: _isLoading ? _buildLoadingIndicator() : _buildMenuContent(),
        ),
      ),
    );
  }

  Widget _buildMenuContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfo(),
        const Divider(), // Divider separating user info from menu items
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: _buildMenuItems(),
          ),
        ),
      ],
    );
  }

  // Updated _buildUserInfo to use the new menuOptionStyle
  Widget _buildUserInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.person, size: 40),
          onPressed: () {
            _navigateToScreen(context, const ProfileScreen());
          },
        ),
        const SizedBox(width: 16),
        Text(
          '$_firstName $_lastName',
          style: AppTextStyles.menuOptionStyle, // Applied new text style
        ),
      ],
    );
  }

  List<Widget> _buildMenuItems() {
    return [
      _buildMenuOption(
        icon: Icons.home,
        label: 'Home',
        screen: const MainScreen(),
      ),
      _buildMenuOption(
        icon: Icons.history,
        label: 'Order History',
        action: () => _navigateToOrderHistory(context), // Use custom navigation

        // screen: const OrderHistoryScreen(
        //   customerId: '',
        // ),
      ),
      _buildMenuOption(
        icon: Icons.account_balance_wallet,
        label: 'Wallet',
        screen: WalletPaymentHandler(
          amount: 0.0,
          onComplete: (bool success) {},
        ),
        // action: () => Routes.navigateToWallet(context),
      ),
      // _buildMenuOption(
      //   icon: Icons.loyalty,
      //   label: 'Loyalty',
      //   screen: LoyaltyScreen(),
      // ),
      _buildMenuOption(
        icon: Icons.favorite,
        label: 'Favorites',
        screen: const FavoriteView(),
      ),
      _buildMenuOption(
        icon: Icons.logout,
        label: 'Logout',
        action: _handleLogout,
      ),
    ];
  }

  // Add this new method to handle Order History navigation
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

  // Updated _buildMenuOption to use the new menuOptionStyle
  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    Widget? screen,
    VoidCallback? action,
  }) {
    bool isSelected = _selectedMenu == label;

    return InkWell(
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.black,
              size: 30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: isSelected
                    ? AppTextStyles.menuOptionStyle.copyWith(
                        color: Colors.blue) // Use new style for selected
                    : AppTextStyles.menuOptionStyle, // Applied new text style
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _handleLogout() async {
    await AppPreference.clearUserData();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInScreen(),
      ),
    );
  }
}
