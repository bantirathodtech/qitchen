import 'package:flutter/foundation.dart';
import '../../../../common/log/loggers.dart';
import '../model/get_wallet_balance.dart';
import '../repository/wallet_repository.dart';
import '../service/wallet_service.dart';

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

  Future<void> fetchWalletBalance(String customerId) async {
    try {
      _setLoading(true);
      _clearError();

      // Get balance directly from repository - no need for extra fromJson
      _walletBalance = await _repository.getWalletBalance(customerId);

      AppLogger.logInfo(
          '[WalletViewModel] Balance fetched: ${_walletBalance?.balanceAmt}');
    } catch (e) {
      _setError('Failed to fetch wallet balance: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<WalletTransactionResult> addMoneyToWallet(
    String customerId,
    double amount,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _repository.addMoneyToWallet(
        customerId: customerId, // Updated to use named parameters
        amount: amount,
      );

      if (result.success) {
        // Update wallet balance after successful transaction
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

  Future<WalletTransactionResult> spendFromWallet(
    String customerId,
    double amount,
    String orderNumber,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      if ((_walletBalance?.balanceAmt ?? 0) < amount) {
        throw Exception('Insufficient wallet balance');
      }

      final result = await _repository.spendFromWallet(
        customerId: customerId,
        amount: amount,
        orderNumber: orderNumber,
      );

      if (result.success) {
        // Update local balance
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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    AppLogger.logError('[WalletViewModel] $_error');
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
