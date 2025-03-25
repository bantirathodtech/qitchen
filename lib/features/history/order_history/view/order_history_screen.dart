// lib/features/history/screens/order_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/log/loggers.dart';
import '../../../../data/db/app_preferences.dart';
import '../../../auth/verify/model/verify_model.dart';
import '../state/order_history_state.dart';
import '../../wallet_history/state/wallet_history_state.dart';
import '../viewmodel/order_history_viewmodel.dart';
import '../../wallet_history/viewmodel/wallet_history_viewmodel.dart';
import '../widgets/order_history_card.dart';
import '../widgets/order_history_empty_view.dart';
import '../widgets/order_history_error_view.dart';
import '../../wallet_history/widgets/wallet_history_card.dart';
import '../../wallet_history/widgets/wallet_history_empty_view.dart';
import '../../wallet_history/widgets/wallet_history_error_view.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String customerId;

  const OrderHistoryScreen({
    super.key,
    required this.customerId,
  });

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitializing = false;
  String? _loadedCustomerId;
  static const String TAG = '[OrderHistoryScreen]';
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _tabController = TabController(length: 2, vsync: this);
  //
  //   // Trigger initialization once the widget is properly mounted
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _initializeData();
  //   });
  // }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add listener to preload tab data
    _tabController.addListener(_handleTabChange);

    // Trigger initialization once the widget is properly mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _handleTabChange() {
    // When user starts moving to Topup tab, ensure data is loaded
    if (_tabController.index == 1 ||
        (_tabController.animation?.value ?? 0) > 0.5) {
      // If we have a customer ID, ensure wallet history is loaded
      if (_loadedCustomerId != null && _loadedCustomerId!.isNotEmpty) {
        // Get view model
        final walletViewModel = context.read<WalletHistoryViewModel>();

        // Check if wallet data is already loaded
        if (!walletViewModel.state.hasTransactions && !walletViewModel.isLoading) {
          // Load wallet history if not already loaded and not currently loading
          _loadWalletHistory(_loadedCustomerId!);
        }
      }
    }
  }

  Future<void> _initializeData() async {
    // Prevent multiple initializations
    if (_isInitializing) {
      AppLogger.logInfo('$TAG Already initializing, skipping duplicate call');
      return;
    }

    // Check if we already loaded data for this customer
    if (_loadedCustomerId == widget.customerId) {
      AppLogger.logInfo('$TAG Data already loaded for customer: $_loadedCustomerId');
      return;
    }

    _isInitializing = true;
    try {
      AppLogger.logInfo('$TAG Starting data initialization');

      // Get customer ID from preferences if not provided
      String customerId = widget.customerId;
      if (customerId.isEmpty) {
        try {
          final userData = await AppPreference.getUserData();
          final customer = CustomerModel.fromJson(userData);
          if (customer.b2cCustomerId != null) {
            customerId = customer.b2cCustomerId!;
            AppLogger.logInfo('$TAG Retrieved customer ID from preferences: $customerId');
          }
        } catch (e) {
          AppLogger.logError('$TAG Error getting customer ID: $e');
        }
      }

      if (customerId.isNotEmpty) {
        // Load both data types in parallel for faster initialization
        AppLogger.logInfo('$TAG Loading order_shared_common history and wallet history in parallel for customer: $customerId');
        await Future.wait([
          _loadOrderHistory(customerId),
          _loadWalletHistory(customerId)
        ], eagerError: false); // Continue even if one fails

        setState(() {
          _loadedCustomerId = customerId;
        });
        AppLogger.logInfo('$TAG Data initialization complete for customer: $customerId');
      } else {
        AppLogger.logError('$TAG No customer ID available to load data');
      }
    } catch (e) {
      AppLogger.logError('$TAG Error during initialization: $e');
    } finally {
      _isInitializing = false;
    }
  }

  // @override
  // void dispose() {
  //   _tabController.dispose();
  //   super.dispose();
  // }
  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }


  Future<void> _loadOrderHistory(String customerId) async {
    try {
      final viewModel = context.read<OrderHistoryViewModel>();
      AppLogger.logInfo('$TAG Calling OrderHistoryViewModel.loadOrderHistory');
      await viewModel.loadOrderHistory(customerId);
    } catch (e) {
      AppLogger.logError('$TAG Error loading order_shared_common history: $e');
    }
  }

  Future<void> _loadWalletHistory(String customerId) async {
    try {
      final viewModel = context.read<WalletHistoryViewModel>();
      AppLogger.logInfo('$TAG Calling WalletHistoryViewModel.loadWalletHistory');
      await viewModel.loadWalletHistory(customerId);
    } catch (e) {
      AppLogger.logError('$TAG Error loading wallet history: $e');
    }
  }

  // This method handles manual refresh requests from the UI
  Future<void> _handleRefresh() async {
    final customerId = _loadedCustomerId ?? widget.customerId;
    if (customerId.isEmpty) {
      AppLogger.logError('$TAG Cannot refresh, no customer ID available');
      return;
    }

    AppLogger.logInfo('$TAG Manual refresh requested for tab: ${_tabController.index}');
    if (_tabController.index == 0) {
      await _loadOrderHistory(customerId);
    } else {
      await _loadWalletHistory(customerId);
    }
  }

  void _handleBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          logoPath: 'assets/images/cw_image.png',
          onBackPressed: _handleBack,
          showNotification: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: _handleRefresh,
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: const [
                  Tab(text: 'Orders'),
                  Tab(text: 'Topup'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersTab(),
                  _buildTopupTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Consumer<OrderHistoryStateNotifier>(
      builder: (context, stateNotifier, child) {
        final state = stateNotifier.state;
        final viewModel = context.read<OrderHistoryViewModel>();

        if (state.isLoading && viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.hasError) {
          return OrderHistoryErrorView(
            error: state.errorMessage ?? 'Unknown error occurred',
            onRetry: () => _handleRefresh(),
          );
        }

        if (!state.hasOrders) {
          return const OrderHistoryEmptyView();
        }

        // Use Set to ensure we only display unique orders
        final uniqueOrderIds = <String>{};
        final uniqueOrders = state.orders.where((order) {
          if (uniqueOrderIds.contains(order.orderId)) {
            return false; // Skip duplicate
          }
          uniqueOrderIds.add(order.orderId);
          return true;
        }).toList();

        AppLogger.logInfo('$TAG Displaying ${uniqueOrders.length} unique orders');

        return RefreshIndicator(
          onRefresh: () => _handleRefresh(),
          child: ListView.builder(
            itemCount: uniqueOrders.length,
            itemBuilder: (context, index) {
              return OrderHistoryCard(order: uniqueOrders[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildTopupTab() {
    return Consumer<WalletHistoryStateNotifier>(
      builder: (context, stateNotifier, child) {
        final state = stateNotifier.state;
        final viewModel = context.read<WalletHistoryViewModel>();

        if (state.isLoading && viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.hasError) {
          return WalletHistoryErrorView(
            error: state.errorMessage ?? 'Unknown error occurred',
            onRetry: () => _handleRefresh(),
          );
        }

        if (!state.hasTransactions) {
          return const WalletHistoryEmptyView();
        }

        // Use Set to ensure we only display unique transactions
        final uniqueTrxIds = <String>{};
        final uniqueTransactions = state.transactions.where((transaction) {
          if (uniqueTrxIds.contains(transaction.walletTrxId)) {
            return false; // Skip duplicate
          }
          uniqueTrxIds.add(transaction.walletTrxId);
          return true;
        }).toList();

        AppLogger.logInfo('$TAG Displaying ${uniqueTransactions.length} unique wallet transactions');

        return RefreshIndicator(
          onRefresh: () => _handleRefresh(),
          child: ListView.builder(
            itemCount: uniqueTransactions.length,
            itemBuilder: (context, index) {
              return WalletHistoryCard(transaction: uniqueTransactions[index]);
            },
          ),
        );
      },
    );
  }
}


// // lib/features/history/screens/order_history_screen.dart - Fix for duplicates
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../../common/widgets/custom_app_bar.dart';
// import '../../../../data/db/app_preferences.dart';
// import '../../../auth/verify/model/verify_model.dart';
// import '../state/order_history_state.dart';
// import '../../wallet_history/state/wallet_history_state.dart';
// import '../viewmodel/order_history_viewmodel.dart';
// import '../../wallet_history/viewmodel/wallet_history_viewmodel.dart';
// import '../widgets/order_history_card.dart';
// import '../widgets/order_history_empty_view.dart';
// import '../widgets/order_history_error_view.dart';
// import '../../wallet_history/widgets/wallet_history_card.dart';
// import '../../wallet_history/widgets/wallet_history_empty_view.dart';
// import '../../wallet_history/widgets/wallet_history_error_view.dart';
//
// class OrderHistoryScreen extends StatefulWidget {
//   final String customerId;
//
//   const OrderHistoryScreen({
//     super.key,
//     required this.customerId,
//   });
//
//   @override
//   State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
// }
//
// class _OrderHistoryScreenState extends State<OrderHistoryScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool _dataLoaded = false;
//   String? _loadedCustomerId;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//
//     // Load data when the screen is created, but only once
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeData();
//     });
//   }
//
//   Future<void> _initializeData() async {
//     // If data is already loaded for this customer ID, don't reload
//     if (_dataLoaded && _loadedCustomerId == widget.customerId) {
//       return;
//     }
//
//     // Get customer ID from preferences if not provided
//     String customerId = widget.customerId;
//     if (customerId.isEmpty) {
//       try {
//         final userData = await AppPreference.getUserData();
//         final customer = CustomerModel.fromJson(userData);
//         if (customer.b2cCustomerId != null) {
//           customerId = customer.b2cCustomerId!;
//         }
//       } catch (e) {
//         // Handle error quietly
//       }
//     }
//
//     if (customerId.isNotEmpty) {
//       // Initialize data loading
//       await _loadOrderHistory(customerId);
//       await _loadWalletHistory(customerId);
//
//       setState(() {
//         _dataLoaded = true;
//         _loadedCustomerId = customerId;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadOrderHistory(String customerId) async {
//     final viewModel = context.read<OrderHistoryViewModel>();
//     await viewModel.loadOrderHistory(customerId);
//   }
//
//   Future<void> _loadWalletHistory(String customerId) async {
//     final viewModel = context.read<WalletHistoryViewModel>();
//     await viewModel.loadWalletHistory(customerId);
//   }
//
//   // This method handles manual refresh requests
//   Future<void> _handleRefresh() async {
//     final customerId = _loadedCustomerId ?? widget.customerId;
//     if (customerId.isEmpty) return;
//
//     if (_tabController.index == 0) {
//       await _loadOrderHistory(customerId);
//     } else {
//       await _loadWalletHistory(customerId);
//     }
//   }
//
//   void _handleBack() {
//     Navigator.of(context).pop();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         _handleBack();
//         return false;
//       },
//       child: Scaffold(
//         appBar: CustomAppBar(
//           logoPath: 'assets/images/cw_image.png',
//           onBackPressed: _handleBack,
//           showNotification: false,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.refresh, color: Colors.black),
//               onPressed: _handleRefresh,
//             ),
//           ],
//         ),
//         body: Column(
//           children: [
//             Container(
//               color: Colors.white,
//               child: TabBar(
//                 controller: _tabController,
//                 labelColor: Theme.of(context).primaryColor,
//                 unselectedLabelColor: Colors.grey,
//                 indicatorColor: Theme.of(context).primaryColor,
//                 tabs: const [
//                   Tab(text: 'Orders'),
//                   Tab(text: 'Topup'),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildOrdersTab(),
//                   _buildTopupTab(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOrdersTab() {
//     return Consumer<OrderHistoryStateNotifier>(
//       builder: (context, stateNotifier, child) {
//         final state = stateNotifier.state;
//         final viewModel = context.read<OrderHistoryViewModel>();
//
//         if (state.isLoading && viewModel.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (state.hasError) {
//           return OrderHistoryErrorView(
//             error: state.errorMessage ?? 'Unknown error occurred',
//             onRetry: () => _handleRefresh(),
//           );
//         }
//
//         if (!state.hasOrders) {
//           return const OrderHistoryEmptyView();
//         }
//
//         return RefreshIndicator(
//           onRefresh: () => _handleRefresh(),
//           child: ListView.builder(
//             itemCount: state.orders.length,
//             itemBuilder: (context, index) {
//               return OrderHistoryCard(order_shared_common: state.orders[index]);
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTopupTab() {
//     return Consumer<WalletHistoryStateNotifier>(
//       builder: (context, stateNotifier, child) {
//         final state = stateNotifier.state;
//         final viewModel = context.read<WalletHistoryViewModel>();
//
//         if (state.isLoading && viewModel.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (state.hasError) {
//           return WalletHistoryErrorView(
//             error: state.errorMessage ?? 'Unknown error occurred',
//             onRetry: () => _handleRefresh(),
//           );
//         }
//
//         if (!state.hasTransactions) {
//           return const WalletHistoryEmptyView();
//         }
//
//         return RefreshIndicator(
//           onRefresh: () => _handleRefresh(),
//           child: ListView.builder(
//             itemCount: state.transactions.length,
//             itemBuilder: (context, index) {
//               return WalletHistoryCard(transaction: state.transactions[index]);
//             },
//           ),
//         );
//       },
//     );
//   }
// }




// // lib/features/history/screens/order_history_screen.dart
// // lib/features/history/screens/order_history_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../common/widgets/custom_app_bar.dart';
// import '../state/order_history_state.dart';
// import '../state/wallet_history_state.dart';
// import '../viewmodel/order_history_viewmodel.dart';
// import '../viewmodel/wallet_history_viewmodel.dart';
// import '../widgets/order_history_card.dart';
// import '../widgets/order_history_empty_view.dart';
// import '../widgets/order_history_error_view.dart';
// import '../widgets/wallet_history_card.dart';
// import '../widgets/wallet_history_empty_view.dart';
// import '../widgets/wallet_history_error_view.dart';
//
// class OrderHistoryScreen extends StatefulWidget {
//   final String customerId;
//
//   const OrderHistoryScreen({
//     super.key,
//     required this.customerId,
//   });
//
//   @override
//   State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
// }
//
// class _OrderHistoryScreenState extends State<OrderHistoryScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     // Schedule the data loading for the next frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadInitialData();
//     });
//   }
//
//   Future<void> _loadInitialData() async {
//     await _loadOrders();
//     await _loadWalletHistory();
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadOrders() async {
//     final viewModel = context.read<OrderHistoryViewModel>();
//     await viewModel.loadOrderHistory(widget.customerId);
//   }
//
//   Future<void> _loadWalletHistory() async {
//     final viewModel = context.read<WalletHistoryViewModel>();
//     await viewModel.loadWalletHistory(widget.customerId);
//   }
//
//   void _handleBack() {
//     Navigator.of(context).pop();
//   }
//
//   void _handleRefresh() {
//     if (_tabController.index == 0) {
//       _loadOrders();
//     } else {
//       _loadWalletHistory();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         _handleBack();
//         return false;
//       },
//       child: Scaffold(
//         appBar: CustomAppBar(
//           logoPath: 'assets/images/cw_image.png',
//           onBackPressed: _handleBack,
//           showNotification: false,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.refresh, color: Colors.black),
//               onPressed: _handleRefresh,
//             ),
//           ],
//         ),
//         body: Column(
//           children: [
//             Container(
//               color: Colors.white,
//               child: TabBar(
//                 controller: _tabController,
//                 labelColor: Theme.of(context).primaryColor,
//                 unselectedLabelColor: Colors.grey,
//                 indicatorColor: Theme.of(context).primaryColor,
//                 tabs: const [
//                   Tab(text: 'Orders'),
//                   Tab(text: 'Topup'),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildOrdersTab(),
//                   _buildTopupTab(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOrdersTab() {
//     return Consumer<OrderHistoryStateNotifier>(
//       builder: (context, stateNotifier, child) {
//         final state = stateNotifier.state;
//
//         if (state.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (state.hasError) {
//           return OrderHistoryErrorView(
//             error: state.errorMessage ?? 'Unknown error occurred',
//             onRetry: _loadOrders,
//           );
//         }
//
//         if (!state.hasOrders) {
//           return const OrderHistoryEmptyView();
//         }
//
//         return RefreshIndicator(
//           onRefresh: _loadOrders,
//           child: ListView.builder(
//             // padding: const EdgeInsets.symmetric(vertical: 6), // Reduce vertical padding
//
//             itemCount: state.orders.length,
//             itemBuilder: (context, index) {
//               return OrderHistoryCard(order_shared_common: state.orders[index]);
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTopupTab() {
//     return Consumer<WalletHistoryStateNotifier>(
//       builder: (context, stateNotifier, child) {
//         final state = stateNotifier.state;
//
//         if (state.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (state.hasError) {
//           return WalletHistoryErrorView(
//             error: state.errorMessage ?? 'Unknown error occurred',
//             onRetry: _loadWalletHistory,
//           );
//         }
//
//         if (!state.hasTransactions) {
//           return const WalletHistoryEmptyView();
//         }
//
//         return RefreshIndicator(
//           onRefresh: _loadWalletHistory,
//           child: ListView.builder(
//             itemCount: state.transactions.length,
//             itemBuilder: (context, index) {
//               return WalletHistoryCard(transaction: state.transactions[index]);
//             },
//           ),
//         );
//       },
//     );
//   }
// }
