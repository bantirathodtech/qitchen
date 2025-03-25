// lib/features/history/cache/wallet_transaction_cache.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/log/loggers.dart';
import '../../../ordering/wallet/model/get_wallet_transactions.dart';

/// Dedicated class for caching wallet transaction data
class WalletTransactionCache {
  static const String TAG = '[WalletTransactionCache]';
  static const String WALLET_TRX_DATA_KEY = 'cached_wallet_transactions_';
  static const String CACHE_TIMESTAMP_KEY = 'wallet_transactions_cache_timestamp_';
  static const int CACHE_DURATION_MS = 300000; // 5 min in milliseconds

  /// Save wallet transaction data to cache for a specific customer
  static Future<bool> saveWalletTransactionData(String customerId, List<WalletTransactionModel> transactions) async {
    try {
      AppLogger.logInfo('$TAG: Saving wallet transaction data to cache for customer: $customerId');
      final prefs = await SharedPreferences.getInstance();

      // Create a list of transaction JSON objects
      final transactionsList = transactions.map((transaction) => _convertTransactionToJson(transaction)).toList();

      // Convert to JSON string
      final jsonData = json.encode(transactionsList);

      // Save data and timestamp using customer-specific keys
      await prefs.setString('$WALLET_TRX_DATA_KEY$customerId', jsonData);
      await prefs.setInt('$CACHE_TIMESTAMP_KEY$customerId', DateTime.now().millisecondsSinceEpoch);

      AppLogger.logInfo('$TAG: Wallet transaction data cached successfully for customer: $customerId (${transactions.length} items)');
      return true;
    } catch (e) {
      AppLogger.logError('$TAG: Error caching wallet transaction data: $e');
      return false;
    }
  }

  /// Get cached wallet transaction data if available and not expired
  static Future<List<WalletTransactionModel>?> getWalletTransactionData(String customerId) async {
    try {
      AppLogger.logInfo('$TAG: Attempting to get cached wallet transaction data for customer: $customerId');
      final prefs = await SharedPreferences.getInstance();

      // Check if cache exists
      final cacheKey = '$WALLET_TRX_DATA_KEY$customerId';
      if (!prefs.containsKey(cacheKey)) {
        AppLogger.logInfo('$TAG: No cached wallet transaction data found for customer: $customerId');
        return null;
      }

      // Check if cache is expired
      final timestamp = prefs.getInt('$CACHE_TIMESTAMP_KEY$customerId') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheDuration = now - timestamp;

      if (cacheDuration > CACHE_DURATION_MS) {
        AppLogger.logInfo('$TAG: Cached wallet transaction data is expired for customer: $customerId');
        return null;
      }

      // Retrieve and parse cached data
      final jsonData = prefs.getString(cacheKey);
      if (jsonData == null) return null;

      final transactionsList = (json.decode(jsonData) as List)
          .map((item) => _convertJsonToTransaction(item as Map<String, dynamic>))
          .toList();

      AppLogger.logInfo('$TAG: Successfully retrieved ${transactionsList.length} cached wallet transactions for customer: $customerId');
      return transactionsList;
    } catch (e) {
      AppLogger.logError('$TAG: Error retrieving cached wallet transaction data: $e');
      return null;
    }
  }

  /// Clear wallet transaction data cache for a specific customer or all customers
  static Future<void> clearCache([String? customerId]) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (customerId != null) {
        // Clear cache for specific customer
        AppLogger.logInfo('$TAG: Clearing wallet transaction cache for customer: $customerId');
        await prefs.remove('$WALLET_TRX_DATA_KEY$customerId');
        await prefs.remove('$CACHE_TIMESTAMP_KEY$customerId');
      } else {
        // Clear all wallet transaction caches
        AppLogger.logInfo('$TAG: Clearing all wallet transaction caches');
        final keys = prefs.getKeys();
        for (final key in keys) {
          if (key.startsWith(WALLET_TRX_DATA_KEY) || key.startsWith(CACHE_TIMESTAMP_KEY)) {
            await prefs.remove(key);
          }
        }
      }
      AppLogger.logInfo('$TAG: Wallet transaction cache cleared ${customerId != null ? 'for customer: $customerId' : 'for all customers'}');
    } catch (e) {
      AppLogger.logError('$TAG: Error clearing wallet transaction cache: $e');
    }
  }

  // Helper method to convert WalletTransactionModel to JSON map
  static Map<String, dynamic> _convertTransactionToJson(WalletTransactionModel transaction) {
    return {
      'wallet_trx_id': transaction.walletTrxId,
      'date': transaction.date.toIso8601String(),
      'trx_type': transaction.trxType,
      'trx_value': transaction.trxValue,
      'opening_amt': transaction.openingAmt,
      'closing_amt': transaction.closingAmt,
    };
  }

  // Helper method to convert JSON map to WalletTransactionModel
  static WalletTransactionModel _convertJsonToTransaction(Map<String, dynamic> json) {
    return WalletTransactionModel(
      walletTrxId: json['wallet_trx_id'] ?? '',
      date: DateTime.parse(json['date']),
      trxType: json['trx_type'] ?? '',
      trxValue: (json['trx_value'] ?? 0).toDouble(),
      openingAmt: (json['opening_amt'] ?? 0).toDouble(),
      closingAmt: (json['closing_amt'] ?? 0).toDouble(),
    );
  }
}