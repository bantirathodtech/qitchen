// wallet_service.dart - UPDATED

import '../../../../common/log/loggers.dart';
import '../../../../core/services/base/api_base_service.dart';
import '../../../../core/services/endpoints/api_url_manager.dart';
import '../../../../data/db/app_preferences.dart';
import '../model/get_wallet_balance.dart';
import '../model/upsert_wallet_transaction.dart';

/// Service class for wallet operations
/// Handles direct API interactions for wallet balance, transactions, and payments
class WalletService {
  final ApiBaseService _apiBaseService;

  WalletService({required ApiBaseService apiBaseService})
      : _apiBaseService = apiBaseService;

  /// Safely parses balance value to double from different data types
  /// @param value - The value to parse, can be int, double, String or null
  /// @return Parsed double value, defaults to 0.0 if parsing fails
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
    AppLogger.logError('[WalletService] Unexpected balance type: ${value.runtimeType}');
    return 0.0;
  }

  /// Create or update wallet transaction
  /// API: POST /api/food-ordering/wallet
  /// This is the ONLY method that creates transactions
  ///
  /// @param b2cCustomerId - Customer ID required in request body
  /// @param trxType - Transaction type: 'CR' (credit), 'DR' (debit), 'DP' (deposit), 'SA' (spend)
  /// @param trxValue - Amount for the transaction
  /// @return API response with recordId (wallet ID) if successful
  Future<Map<String, dynamic>> upsertWalletTransaction({
    required String b2cCustomerId,
    required String trxType,
    required double trxValue,
  }) async {
    try {
      AppLogger.logInfo('[WalletService] Creating transaction:');
      AppLogger.logInfo('- CustomerId: $b2cCustomerId');
      AppLogger.logInfo('- Type: $trxType');
      AppLogger.logInfo('- Amount: $trxValue');

      // Send POST request with customer ID in body
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

      // Save wallet ID from response
      final recordId = UpsertWalletTransaction.fromJson(response).response.recordId;
      await AppPreference.saveWalletId(recordId);
      AppLogger.logInfo('[WalletService] Wallet ID updated: $recordId');

      return response;
    } catch (e) {
      AppLogger.logError('[WalletService] Transaction failed: $e');
      rethrow;
    }
  }

  /// Get all wallet transactions for a wallet
  /// API: GET /api/food-ordering/wallet?wallet_id={walletId}
  ///
  /// @return List of transaction records
  Future<List<dynamic>> getWalletTransactions() async {
    try {
      // Get wallet ID from storage - required for this API
      final walletId = await AppPreference.getWalletId();

      if (walletId == null || walletId.isEmpty) {
        AppLogger.logWarning('[WalletService] No wallet ID available for transaction fetch');
        return [];
      }

      AppLogger.logInfo('[WalletService] Fetching transactions for wallet ID: $walletId');

      // Send GET request with wallet_id as query parameter
      final response = await _apiBaseService.sendRestRequest(
        method: 'GET',
        endpoint: AppUrls.wallet,
        queryParams: {'wallet_id': walletId},
      );

      if (response == null) {
        AppLogger.logError('[WalletService] Server returned null response for transactions');
        return [];
      }

      // Handle different response formats
      List<dynamic> transactions = [];

      if (response is Map && response.containsKey('transactions')) {
        transactions = response['transactions'] as List;
        AppLogger.logInfo('[WalletService] Found transactions in map: ${transactions.length}');
      } else if (response is List) {
        transactions = response;
        AppLogger.logInfo('[WalletService] Response is directly a list: ${transactions.length}');
      } else {
        AppLogger.logError('[WalletService] Unexpected response format: $response');
        return [];
      }

      if (transactions.isEmpty) {
        AppLogger.logInfo('[WalletService] No wallet transactions found');
      } else {
        AppLogger.logInfo('[WalletService] Fetched ${transactions.length} transactions');
      }

      return transactions;
    } catch (e) {
      AppLogger.logError('[WalletService] Transaction fetch failed: $e');
      return [];  // Return empty list instead of throwing to avoid crashes
    }
  }

  /// Get wallet balance
  /// API: GET /api/food-ordering/wallet/{walletId}
  ///
  /// @return Wallet balance data including customer info and balance amount
  Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      // Get wallet ID from storage - required for this API
      final walletId = await AppPreference.getWalletId();

      if (walletId == null || walletId.isEmpty) {
        AppLogger.logWarning('[WalletService] No wallet ID available for balance fetch');
        return {
          'b2c_Customer_Id': '',
          'b2c_Customer_name': '',
          'balance_Amt': await _getCachedBalance()
        };
      }

      AppLogger.logInfo('[WalletService] Fetching balance for wallet ID: $walletId');

      // Send GET request with wallet ID in path
      final response = await _apiBaseService.sendRestRequest(
        method: 'GET',
        endpoint: '${AppUrls.getWalletBalance}/$walletId',
      );

      AppLogger.logInfo('[WalletService] Balance response: $response');

      if (response != null) {
        // Ensure balance is parsed as double
        final balance = _parseBalance(response['balance_Amt']);
        await _saveCachedWalletData(balance);

        AppLogger.logInfo('[WalletService] Balance fetched: $balance');

        return {
          ...response,
          'balance_Amt': balance,
        };
      }

      // Return cached balance if API call fails
      final cachedBalance = await _getCachedBalance();
      AppLogger.logInfo('[WalletService] Using cached balance: $cachedBalance');

      return {
        'b2c_Customer_Id': '',
        'b2c_Customer_name': '',
        'balance_Amt': cachedBalance
      };
    } catch (e) {
      AppLogger.logError('[WalletService] Balance fetch failed: $e');

      // Return cached balance in case of error
      final cachedBalance = await _getCachedBalance();
      return {
        'b2c_Customer_Id': '',
        'b2c_Customer_name': '',
        'balance_Amt': cachedBalance
      };
    }
  }

  /// Get cached wallet balance from user data storage
  /// @return Cached balance as double, 0.0 if not found
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

  /// Save wallet balance to user data storage for offline access
  /// @param balance - Balance amount to cache
  Future<void> _saveCachedWalletData(double balance) async {
    try {
      final userData = await AppPreference.getUserData() ?? {};
      final updatedData = {
        ...userData,
        'walletBalance': balance.toString(),
      };
      await AppPreference.saveUserData(updatedData);
      AppLogger.logInfo('[WalletService] Cached balance updated: $balance');
    } catch (e) {
      AppLogger.logError('[WalletService] Cache update error: $e');
    }
  }
}

/// Result class for wallet transactions
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
