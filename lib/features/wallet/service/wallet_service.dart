import '../../../common/log/loggers.dart';
import '../../../core/api/api_base_service.dart';
import '../../../core/api/api_url_manager.dart';
import '../../../data/db/app_preferences.dart';
import '../model/get_wallet_balance.dart';
import '../model/upsert_wallet_transaction.dart';

class WalletService {
  final ApiBaseService _apiBaseService;

  WalletService({required ApiBaseService apiBaseService})
      : _apiBaseService = apiBaseService;

  // Helper method to safely convert balance to double
  double _parseBalance(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        AppLogger.logError('[WalletService] Error parsing balance: $e');
        return 0.0;
      }
    }
    AppLogger.logError(
        '[WalletService] Unexpected balance type: ${value.runtimeType}');
    return 0.0;
  }

  Future<Map<String, dynamic>> upsertWalletTransaction({
    required String b2cCustomerId,
    required String trxType, // 'CR' for credit, 'DR' for debit
    required double trxValue,
  }) async {
    try {
      final response = await _apiBaseService.sendRestRequest(
        method: 'POST',
        endpoint: AppUrls.upsertWallet,
        body: {
          'b2c_Customer_Id': b2cCustomerId,
          'trx_type': trxType,
          'trx_value': trxValue,
        },
      );

      if (response == null) {
        throw Exception('Server returned null response');
      }

      // Only save the walletId if it hasn't been saved before
      final existingWalletId = await AppPreference.getWalletId();
      if (existingWalletId == null) {
        final recordId =
            UpsertWalletTransaction.fromJson(response).response.recordId;
        await AppPreference.saveWalletId(recordId);
        AppLogger.logInfo(
            '[WalletService] First transaction - Saved new walletId: $recordId');
      }

      return response;
    } catch (e) {
      AppLogger.logError('[WalletService] Transaction failed: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getWalletTransactions(String customerId) async {
    try {
      AppLogger.logInfo(
          '[WalletService] Fetching wallet transactions for customer: $customerId');

      final storedWalletId = await AppPreference.getWalletId();
      final effectiveWalletId = storedWalletId ?? customerId;

      final response = await _apiBaseService.sendRestRequest(
        method: 'GET',
        endpoint: '${AppUrls.wallet}',
        queryParams: {'wallet_id': effectiveWalletId},
      );

      if (response == null) {
        throw Exception('Server returned null response');
      }

      // Ensure we're working with a List
      if (response is! List) {
        if (response is Map && response.containsKey('transactions')) {
          return response['transactions'] as List;
        }
        return [];
      }

      return response;
    } catch (e) {
      AppLogger.logError('[WalletService] Transaction fetch failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWalletBalance(String customerId) async {
    try {
      AppLogger.logInfo(
          '[WalletService] Fetching wallet balance for customer: $customerId');

      final storedWalletId = await AppPreference.getWalletId();
      final effectiveWalletId = storedWalletId ?? customerId;

      AppLogger.logInfo(
          '[WalletService] Using effectiveWalletId: $effectiveWalletId');

      final response = await _apiBaseService.sendRestRequest(
        method: 'GET',
        endpoint: '${AppUrls.getWalletBalance}/$effectiveWalletId',
      );

      if (response != null) {
        final balance = _parseBalance(response['balance_Amt']);
        await _saveCachedWalletData(balance);

        // Ensure we return the balance as a double
        return {
          ...response,
          'balance_Amt': balance,
        };
      }

      final cachedBalance = await _getCachedBalance();
      return {
        'b2c_Customer_Id': customerId,
        'b2c_Customer_name': '',
        'balance_Amt': cachedBalance
      };
    } catch (e) {
      AppLogger.logError('[WalletService] Balance fetch failed: $e');
      final cachedBalance = await _getCachedBalance();
      return {
        'b2c_Customer_Id': customerId,
        'b2c_Customer_name': '',
        'balance_Amt': cachedBalance
      };
    }
  }

  Future<WalletTransactionResult> addMoneyToWallet(
    String customerId,
    double amount,
  ) async {
    try {
      AppLogger.logInfo('[WalletService] Adding money to wallet:');
      AppLogger.logInfo('- CustomerId: $customerId');
      AppLogger.logInfo('- Amount: $amount');

      //trxType CR/DP/SA

      final response = await upsertWalletTransaction(
        b2cCustomerId: customerId,
        trxType: 'DP',
        trxValue: amount,
      );

      if (response == null) {
        throw Exception('Server returned null response');
      }

      final result = UpsertWalletTransaction.fromJson(response);

      if (result.response.status == '200') {
        final balanceResponse = await getWalletBalance(customerId);
        final balance = _parseBalance(
            GetWalletBalanceModel.fromJson(balanceResponse).balanceAmt);

        AppLogger.logInfo(
            '[WalletService] Updated balance after transaction: $balance');

        return WalletTransactionResult(
          success: true,
          walletId: await AppPreference.getWalletId(),
          balance: balance,
        );
      }

      return WalletTransactionResult(
        success: false,
        error: result.response.message ?? 'Transaction failed',
      );
    } catch (e) {
      AppLogger.logError('[WalletService] Add money failed: $e');
      return WalletTransactionResult(
        success: false,
        error: e.toString(),
      );
    }
  }

// In wallet_service.dart
//   Future<WalletTransactionResult> spendFromWallet(
//     String customerId,
//     double amount,
//   ) async {
//     try {
//       AppLogger.logInfo('[WalletService] Processing wallet payment:');
//       AppLogger.logInfo('- CustomerId: $customerId');
//       AppLogger.logInfo('- Amount: $amount');
//
//       // Process spend transaction
//       final response = await upsertWalletTransaction(
//         b2cCustomerId: customerId,
//         trxType: 'SA', // Spend Amount transaction type
//         trxValue: amount,
//       );
//
//       if (response == null) {
//         throw Exception('Server returned null response');
//       }
//
//       final result = UpsertWalletTransaction.fromJson(response);
//
//       if (result.response.status == '200') {
//         // Get updated balance after spend
//         final balanceResponse = await getWalletBalance(customerId);
//         final balance = _parseBalance(
//             GetWalletBalanceModel.fromJson(balanceResponse).balanceAmt);
//
//         AppLogger.logInfo(
//             '[WalletService] Updated balance after spend: $balance');
//
//         return WalletTransactionResult(
//           success: true,
//           walletId: await AppPreference.getWalletId(),
//           balance: balance,
//         );
//       }
//
//       return WalletTransactionResult(
//         success: false,
//         error: result.response.message ?? 'Transaction failed',
//       );
//     } catch (e) {
//       AppLogger.logError('[WalletService] Wallet payment failed: $e');
//       return WalletTransactionResult(
//         success: false,
//         error: e.toString(),
//       );
//     }
//   }

  Future<double> _getCachedBalance() async {
    try {
      final userData = await AppPreference.getUserData();
      if (userData != null && userData['walletBalance'] != null) {
        return _parseBalance(userData['walletBalance']);
      }
    } catch (e) {
      AppLogger.logError('[WalletService] Error getting cached balance: $e');
    }
    return 0.0;
  }

  Future<void> _saveCachedWalletData(double balance) async {
    try {
      final userData = await AppPreference.getUserData() ?? {};
      final updatedData = {
        ...userData,
        'walletBalance': balance.toString(),
      };
      await AppPreference.saveUserData(updatedData);
      AppLogger.logInfo(
          '[WalletService] Cached wallet data updated. Balance: $balance');
    } catch (e) {
      AppLogger.logError('[WalletService] Cache update error: $e');
    }
  }
}

class WalletTransactionResult {
  final bool success;
  final String? walletId;
  final double? balance;
  final String? error;

  WalletTransactionResult({
    required this.success,
    this.walletId,
    this.balance,
    this.error,
  });
}
