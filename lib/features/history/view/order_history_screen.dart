// lib/features/history/screens/order_history_screen.dart
// lib/features/history/screens/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/custom_app_bar.dart';
import '../state/order_history_state.dart';
import '../state/wallet_history_state.dart';
import '../viewmodel/order_history_viewmodel.dart';
import '../viewmodel/wallet_history_viewmodel.dart';
import '../widgets/order_history_card.dart';
import '../widgets/order_history_empty_view.dart';
import '../widgets/order_history_error_view.dart';
import '../widgets/wallet_history_card.dart';
import '../widgets/wallet_history_empty_view.dart';
import '../widgets/wallet_history_error_view.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Schedule the data loading for the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    await _loadOrders();
    await _loadWalletHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    final viewModel = context.read<OrderHistoryViewModel>();
    await viewModel.loadOrderHistory(widget.customerId);
  }

  Future<void> _loadWalletHistory() async {
    final viewModel = context.read<WalletHistoryViewModel>();
    await viewModel.loadWalletHistory(widget.customerId);
  }

  void _handleBack() {
    Navigator.of(context).pop();
  }

  void _handleRefresh() {
    if (_tabController.index == 0) {
      _loadOrders();
    } else {
      _loadWalletHistory();
    }
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

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.hasError) {
          return OrderHistoryErrorView(
            error: state.errorMessage ?? 'Unknown error occurred',
            onRetry: _loadOrders,
          );
        }

        if (!state.hasOrders) {
          return const OrderHistoryEmptyView();
        }

        return RefreshIndicator(
          onRefresh: _loadOrders,
          child: ListView.builder(
            itemCount: state.orders.length,
            itemBuilder: (context, index) {
              return OrderHistoryCard(order: state.orders[index]);
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

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.hasError) {
          return WalletHistoryErrorView(
            error: state.errorMessage ?? 'Unknown error occurred',
            onRetry: _loadWalletHistory,
          );
        }

        if (!state.hasTransactions) {
          return const WalletHistoryEmptyView();
        }

        return RefreshIndicator(
          onRefresh: _loadWalletHistory,
          child: ListView.builder(
            itemCount: state.transactions.length,
            itemBuilder: (context, index) {
              return WalletHistoryCard(transaction: state.transactions[index]);
            },
          ),
        );
      },
    );
  }
}
