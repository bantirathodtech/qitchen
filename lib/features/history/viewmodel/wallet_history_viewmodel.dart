// lib/features/history/viewmodel/wallet_history_viewmodel.dart
import '../../../common/log/loggers.dart';
import '../../wallet/model/get_wallet_transactions.dart';
import '../../wallet/service/wallet_service.dart';
import '../state/wallet_history_state.dart';

class WalletHistoryViewModel {
  final WalletService _walletService;
  final WalletHistoryStateNotifier _stateNotifier;

  WalletHistoryViewModel({
    required WalletService walletService,
    required WalletHistoryStateNotifier stateNotifier,
  })  : _walletService = walletService,
        _stateNotifier = stateNotifier;

  // Getter for current state
  WalletHistoryState get state => _stateNotifier.state;

  Future<void> loadWalletHistory(String customerId) async {
    try {
      _stateNotifier.setLoading(true);

      final response = await _walletService.getWalletTransactions(customerId);

      AppLogger.logInfo('[WalletHistoryViewModel] Raw response: $response');

      if (response is List && response.isNotEmpty) {
        final transactions = response
            .map((item) => WalletTransactionModel.fromJson(item))
            .toList();

        // Sort transactions by date in descending order (newest first)
        transactions.sort((a, b) => b.date.compareTo(a.date));

        _stateNotifier.setTransactions(transactions);

        AppLogger.logInfo(
            '[WalletHistoryViewModel] Loaded ${transactions.length} transactions');
      } else {
        _stateNotifier.setTransactions([]);
        AppLogger.logInfo('[WalletHistoryViewModel] No transactions found');
      }
    } catch (e) {
      AppLogger.logError('[WalletHistoryViewModel] Failed to load history: $e');
      _stateNotifier.setError('Failed to load wallet history: $e');
    } finally {
      _stateNotifier.setLoading(false);
    }
  }

  // Refresh wallet history
  Future<void> refreshTransactions(String customerId) async {
    await loadWalletHistory(customerId);
  }

  // Helper method to get total number of transactions
  int get totalTransactionCount => state.transactions.length;

  // Helper method to get total transaction amount
  double get totalTransactionAmount {
    return state.transactions
        .fold(0, (total, transaction) => total + transaction.trxValue);
  }

  // Helper to get transactions by type
  List<WalletTransactionModel> getTransactionsByType(String type) {
    return state.transactions
        .where((transaction) => transaction.trxType == type)
        .toList();
  }

  void dispose() {
    // Add any cleanup if needed
  }
}
