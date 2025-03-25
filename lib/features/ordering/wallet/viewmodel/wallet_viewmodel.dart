import 'package:flutter/foundation.dart';
import '../../../../common/log/loggers.dart';
import '../model/get_wallet_balance.dart';
import '../repository/wallet_repository.dart';
import '../service/wallet_service.dart';

/// ViewModel class for wallet functionality
/// Manages state and business logic for wallet-related UI
class WalletViewModel extends ChangeNotifier {
  final WalletRepository _repository;

  GetWalletBalanceModel? _walletBalance;
  bool _isLoading = false;
  String? _error;

  WalletViewModel({required WalletRepository repository})
      : _repository = repository;

  // Getters
  GetWalletBalanceModel? get walletBalance => _walletBalance;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Fetch wallet balance
  /// Flow: Call repository → Update state → Notify listeners
  ///
  /// @param customerId - Required for UI, but not used in API call
  ///        (kept for backward compatibility)
  Future<void> fetchWalletBalance(String customerId) async {
    try {
      _setLoading(true);
      _clearError();

      // Step 1: Get balance from repository
      // (customerId is not actually used in the repository or service)
      _walletBalance = await _repository.getWalletBalance();

      AppLogger.logInfo(
          '[WalletViewModel] Balance fetched: ${_walletBalance?.balanceAmt}');
    } catch (e) {
      _setError('Failed to fetch wallet balance: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch wallet transactions
  /// Flow: Call repository → Process transactions → Notify listeners
  Future<List<dynamic>> fetchWalletTransactions() async {
    try {
      _setLoading(true);
      _clearError();

      // Step 1: Get transactions from repository
      final transactions = await _repository.getWalletTransactions();

      AppLogger.logInfo(
          '[WalletViewModel] Fetched ${transactions.length} wallet transactions');

      return transactions;
    } catch (e) {
      _setError('Failed to fetch wallet transactions: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Add money to wallet
  /// Flow: Call repository → Update balance → Notify listeners
  ///
  /// @param customerId - Customer ID required for the transaction
  /// @param amount - Amount to add to wallet
  /// @return Transaction result
  Future<WalletTransactionResult> addMoneyToWallet(
      String customerId,
      double amount,
      ) async {
    try {
      _setLoading(true);
      _clearError();

      // Step 1: Add money through repository
      final result = await _repository.addMoneyToWallet(
        customerId: customerId,
        amount: amount,
      );

      // Step 2: Handle result
      if (result.success) {
        // Step 3: Update wallet balance
        await fetchWalletBalance(customerId);
        AppLogger.logInfo(
            '[WalletViewModel] Money added successfully. New balance: ${_walletBalance?.balanceAmt}');
      } else {
        _setError(result.error ?? 'Failed to add money to wallet');
      }

      return result;
    } catch (e) {
      _setError('Failed to add money to wallet: $e');
      return WalletTransactionResult(
        success: false,
        error: e.toString(),
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Spend from wallet
  /// Flow: Validate balance → Call repository → Update balance → Notify listeners
  ///
  /// @param customerId - Customer ID required for the transaction
  /// @param amount - Amount to spend
  /// @param orderNumber - Order reference number
  /// @return Transaction result
  Future<WalletTransactionResult> spendFromWallet(
      String customerId,
      double amount,
      String orderNumber,
      ) async {
    try {
      _setLoading(true);
      _clearError();

      // Step 1: Validate sufficient balance
      if ((_walletBalance?.balanceAmt ?? 0) < amount) {
        throw Exception('Insufficient wallet balance');
      }

      // Step 2: Process payment through repository
      final result = await _repository.spendFromWallet(
        customerId: customerId,
        amount: amount,
        orderNumber: orderNumber,
      );

      // Step 3: Handle result
      if (result.success) {
        // Step 4: Update local balance
        await fetchWalletBalance(customerId);
        AppLogger.logInfo(
            '[WalletViewModel] Wallet payment successful. New balance: ${_walletBalance?.balanceAmt}');
      } else {
        _setError(result.error ?? 'Failed to process wallet payment');
      }

      return result;
    } catch (e) {
      _setError(e.toString());
      return WalletTransactionResult(
        success: false,
        error: e.toString(),
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message and notify listeners
  void _setError(String error) {
    _error = error;
    AppLogger.logError('[WalletViewModel] $_error');
    notifyListeners();
  }

  /// Clear error state and notify listeners
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}