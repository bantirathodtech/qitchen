// lib/features/wallet_history/viewmodel/wallet_history_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../../common/log/loggers.dart';
import '../../../../data/db/app_preferences.dart';
import '../../../auth/verify/model/verify_model.dart';
import '../../../ordering/wallet/model/get_wallet_transactions.dart';
import '../../../ordering/wallet/service/wallet_service.dart';
import '../cache/wallet_transaction_cache.dart';
import '../state/wallet_history_state.dart';

class WalletHistoryViewModel extends ChangeNotifier {
  static const String TAG = '[WalletHistoryViewModel]';

  final WalletService _walletService;
  final WalletHistoryStateNotifier _stateNotifier;
  String? _currentCustomerId;
  bool _isLoading = false;

  WalletHistoryViewModel({
    required WalletService walletService,
    required WalletHistoryStateNotifier stateNotifier,
  })  : _walletService = walletService,
        _stateNotifier = stateNotifier {
    // Initialize by trying to load customer data
    _initCustomerData();
  }

  // Getter for current state
  WalletHistoryState get state => _stateNotifier.state;
  bool get isLoading => _isLoading;

  // Initialize by trying to load customer ID
  Future<void> _initCustomerData() async {
    try {
      final userData = await AppPreference.getUserData();
      if (userData.isNotEmpty) {
        final customer = CustomerModel.fromJson(userData);
        if (customer.b2cCustomerId != null && customer.b2cCustomerId!.isNotEmpty) {
          _currentCustomerId = customer.b2cCustomerId;
          AppLogger.logInfo('$TAG Initialized with customer ID: $_currentCustomerId');

          // Try to load cached data immediately
          await _loadCachedWalletHistory();
        }
      }
    } catch (e) {
      AppLogger.logError('$TAG Error initializing customer data: $e');
    }
  }

  // Load cached wallet transaction data if available
  Future<void> _loadCachedWalletHistory() async {
    if (_currentCustomerId == null) return;

    try {
      AppLogger.logInfo('$TAG Attempting to load cached wallet transactions for customer: $_currentCustomerId');
      final cachedTransactions = await WalletTransactionCache.getWalletTransactionData(_currentCustomerId!);

      if (cachedTransactions != null && cachedTransactions.isNotEmpty) {
        AppLogger.logInfo('$TAG Loaded ${cachedTransactions.length} transactions from cache');

        // Filter out any potential duplicates in the cache
        final uniqueTransactions = _getUniqueTransactions(cachedTransactions);

        // Sort transactions by date in descending order_shared_common (newest first)
        uniqueTransactions.sort((a, b) => b.date.compareTo(a.date));

        AppLogger.logInfo('$TAG Setting ${uniqueTransactions.length} unique transactions from cache to state');
        _stateNotifier.setTransactions(uniqueTransactions);
      } else {
        AppLogger.logInfo('$TAG No valid cached wallet transaction data found');
      }
    } catch (e) {
      AppLogger.logError('$TAG Error loading cached wallet history: $e');
    }
  }

  Future<void> loadWalletHistory(String customerId) async {
    if (_isLoading) {
      AppLogger.logInfo('$TAG Already loading data, ignoring request');
      return; // Prevent multiple simultaneous loads
    }

    try {
      _isLoading = true;
      _currentCustomerId = customerId;
      AppLogger.logInfo('$TAG Loading wallet history for customer: $customerId');
      _stateNotifier.setLoading(true);

      // First try to load from cache
      final cachedTransactions = await WalletTransactionCache.getWalletTransactionData(customerId);

      if (cachedTransactions != null && cachedTransactions.isNotEmpty) {
        AppLogger.logInfo('$TAG Using cached wallet transaction data (${cachedTransactions.length} transactions)');

        // Filter and sort cached transactions
        final uniqueCachedTransactions = _getUniqueTransactions(cachedTransactions);
        uniqueCachedTransactions.sort((a, b) => b.date.compareTo(a.date));

        // Update UI with cached data while we fetch fresh data
        _stateNotifier.setTransactions(uniqueCachedTransactions);
      }

      // Then fetch fresh data from server
      AppLogger.logInfo('$TAG Fetching fresh wallet transaction data from server');
      final response = await _walletService.getWalletTransactions();

      AppLogger.logInfo('$TAG Raw response type: ${response.runtimeType}, isEmpty: ${response is List && response.isEmpty}');

      if (response is List && response.isNotEmpty) {
        final transactions = response
            .map((item) => WalletTransactionModel.fromJson(item))
            .toList();

        AppLogger.logInfo('$TAG Parsed ${transactions.length} transactions from API response');

        // Filter out duplicates
        final uniqueTransactions = _getUniqueTransactions(transactions);

        // Sort transactions by date in descending order_shared_common (newest first)
        uniqueTransactions.sort((a, b) => b.date.compareTo(a.date));

        AppLogger.logInfo('$TAG After filtering: ${uniqueTransactions.length} unique transactions');

        // Only update state if we have different transactions
        if (!_transactionsEqual(uniqueTransactions, _stateNotifier.state.transactions)) {
          AppLogger.logInfo('$TAG Transactions changed, updating state');
          _stateNotifier.setTransactions(uniqueTransactions);
        } else {
          AppLogger.logInfo('$TAG Transactions unchanged, not updating state');
        }

        // Cache the fetched data
        AppLogger.logInfo('$TAG Caching ${uniqueTransactions.length} transactions');
        await WalletTransactionCache.saveWalletTransactionData(customerId, uniqueTransactions);
      } else {
        // Only set empty state if current state is not already empty
        if (_stateNotifier.state.transactions.isNotEmpty) {
          AppLogger.logInfo('$TAG No transactions found in API response, clearing state');
          _stateNotifier.setTransactions([]);
        } else {
          AppLogger.logInfo('$TAG No transactions found in API response, state already empty');
        }
      }
    } catch (e) {
      AppLogger.logError('$TAG Failed to load wallet history: $e');
      _stateNotifier.setError('Failed to load wallet history: $e');
    } finally {
      _stateNotifier.setLoading(false);
      _isLoading = false;
    }
  }

  // Prefetch wallet transactions in the background
  Future<void> prefetchWalletHistory() async {
    try {
      // Skip if already loading
      if (_isLoading) {
        AppLogger.logInfo('$TAG Already loading data, skipping prefetch');
        return;
      }

      // Get customer ID if needed
      if (_currentCustomerId == null) {
        try {
          final userData = await AppPreference.getUserData();
          if (userData.isNotEmpty) {
            final customer = CustomerModel.fromJson(userData);
            if (customer.b2cCustomerId != null && customer.b2cCustomerId!.isNotEmpty) {
              _currentCustomerId = customer.b2cCustomerId;
            } else {
              AppLogger.logInfo('$TAG No customer ID available for prefetch');
              return;
            }
          } else {
            AppLogger.logInfo('$TAG No user data available for prefetch');
            return;
          }
        } catch (e) {
          AppLogger.logError('$TAG Error getting customer ID: $e');
          return;
        }
      }

      // Check cache first
      final cachedTransactions = await WalletTransactionCache.getWalletTransactionData(_currentCustomerId!);
      if (cachedTransactions != null && cachedTransactions.isNotEmpty) {
        AppLogger.logInfo('$TAG Found ${cachedTransactions.length} cached wallet transactions');

        // Filter out duplicates from cache
        final uniqueTransactions = _getUniqueTransactions(cachedTransactions);

        // Sort transactions by date (newest first)
        uniqueTransactions.sort((a, b) => b.date.compareTo(a.date));

        // Update state with cached data
        _stateNotifier.setTransactions(uniqueTransactions);
        AppLogger.logInfo('$TAG Set ${uniqueTransactions.length} transactions from cache to state');
        return;
      }

      // No valid cache, fetch from API
      AppLogger.logInfo('$TAG No valid cache, fetching wallet transaction data from API');

      // Silently fetch (no loading indicator)
      final response = await _walletService.getWalletTransactions();

      // Process response
      if (response is List && response.isNotEmpty) {
        final transactions = response
            .map((item) => WalletTransactionModel.fromJson(item))
            .toList();

        // Filter out duplicates
        final uniqueTransactions = _getUniqueTransactions(transactions);

        // Sort by date (newest first)
        uniqueTransactions.sort((a, b) => b.date.compareTo(a.date));

        // Update state with fresh data
        _stateNotifier.setTransactions(uniqueTransactions);

        // Save to cache for future use
        await WalletTransactionCache.saveWalletTransactionData(_currentCustomerId!, uniqueTransactions);

        AppLogger.logInfo('$TAG Successfully prefetched and cached ${uniqueTransactions.length} wallet transactions');
      } else {
        AppLogger.logInfo('$TAG No wallet transactions found during prefetch');
      }
    } catch (e) {
      AppLogger.logError('$TAG Error prefetching wallet history: $e');
      // Don't update state with error for background prefetch
    }
  }
  // Helper method to filter unique transactions by walletTrxId
  List<WalletTransactionModel> _getUniqueTransactions(List<WalletTransactionModel> transactions) {
    final uniqueTransactions = <WalletTransactionModel>[];
    final transactionIds = <String>{};

    for (final transaction in transactions) {
      if (!transactionIds.contains(transaction.walletTrxId)) {
        transactionIds.add(transaction.walletTrxId);
        uniqueTransactions.add(transaction);
      }
    }

    return uniqueTransactions;
  }

  // Helper method to deeply compare transaction lists
  bool _transactionsEqual(List<WalletTransactionModel> a, List<WalletTransactionModel> b) {
    if (a.length != b.length) return false;

    // Convert to Set of transaction IDs for quick comparison
    final aIds = a.map((transaction) => transaction.walletTrxId).toSet();
    final bIds = b.map((transaction) => transaction.walletTrxId).toSet();

    return setEquals(aIds, bIds);
  }

  // Helper to compare sets
  bool setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
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
}


// // lib/features/history/viewmodel/wallet_history_viewmodel.dart - Updated version
//
//
// import '../../../../common/log/loggers.dart';
// import '../../../../data/db/app_preferences.dart';
// import '../../../auth/verify/model/verify_model.dart';
// import '../../../ordering/wallet/model/get_wallet_transactions.dart';
// import '../../../ordering/wallet/service/wallet_service.dart';
// import '../cache/wallet_transaction_cache.dart';
// import '../state/wallet_history_state.dart';
//
// class WalletHistoryViewModel {
//   static const String TAG = '[WalletHistoryViewModel]';
//
//   final WalletService _walletService;
//   final WalletHistoryStateNotifier _stateNotifier;
//   String? _currentCustomerId;
//   bool _isLoading = false;
//
//   WalletHistoryViewModel({
//     required WalletService walletService,
//     required WalletHistoryStateNotifier stateNotifier,
//   })
//       : _walletService = walletService,
//         _stateNotifier = stateNotifier {
//     // Initialize by trying to load customer data
//     _initCustomerData();
//   }
//
//   // Getter for current state
//   WalletHistoryState get state => _stateNotifier.state;
//
//   bool get isLoading => _isLoading;
//
//   // Initialize by trying to load customer ID
//   Future<void> _initCustomerData() async {
//     try {
//       final userData = await AppPreference.getUserData();
//       if (userData.isNotEmpty) {
//         final customer = CustomerModel.fromJson(userData);
//         if (customer.b2cCustomerId != null &&
//             customer.b2cCustomerId!.isNotEmpty) {
//           _currentCustomerId = customer.b2cCustomerId;
//
//           // Try to load cached data immediately
//           _loadCachedWalletHistory();
//         }
//       }
//     } catch (e) {
//       AppLogger.logError('$TAG Error initializing customer data: $e');
//     }
//   }
//
//   // Load cached wallet transaction data if available
//   Future<void> _loadCachedWalletHistory() async {
//     if (_currentCustomerId == null) return;
//
//     try {
//       final cachedTransactions = await WalletTransactionCache
//           .getWalletTransactionData(_currentCustomerId!);
//
//       if (cachedTransactions != null && cachedTransactions.isNotEmpty) {
//         AppLogger.logInfo(
//             '$TAG Loaded ${cachedTransactions.length} transactions from cache');
//         // Sort transactions by date in descending order_shared_common (newest first)
//         cachedTransactions.sort((a, b) => b.date.compareTo(a.date));
//         _stateNotifier.setTransactions(cachedTransactions);
//       }
//     } catch (e) {
//       AppLogger.logError('$TAG Error loading cached wallet history: $e');
//     }
//   }
//
//   Future<void> loadWalletHistory(String customerId) async {
//     if (_isLoading) return; // Prevent multiple simultaneous loads
//
//     try {
//       _isLoading = true;
//       _currentCustomerId = customerId;
//       _stateNotifier.setLoading(true);
//
//       // First try to load from cache
//       final cachedTransactions = await WalletTransactionCache
//           .getWalletTransactionData(customerId);
//
//       if (cachedTransactions != null && cachedTransactions.isNotEmpty) {
//         AppLogger.logInfo(
//             '$TAG Using cached wallet transaction data for customer: $customerId');
//         cachedTransactions.sort((a, b) => b.date.compareTo(a.date));
//         _stateNotifier.setTransactions(cachedTransactions);
//       }
//
//       // Then fetch fresh data from server
//       final response = await _walletService.getWalletTransactions(customerId);
//
//       AppLogger.logInfo('$TAG Raw response: $response');
//
//       if (response is List && response.isNotEmpty) {
//         final transactions = response
//             .map((item) => WalletTransactionModel.fromJson(item))
//             .toList();
//
//         // Sort transactions by date in descending order_shared_common (newest first)
//         transactions.sort((a, b) => b.date.compareTo(a.date));
//
//         // Only update state if we have different transactions (avoiding duplicates)
//         if (!_listEquals(transactions, _stateNotifier.state.transactions)) {
//           _stateNotifier.setTransactions(transactions);
//         }
//
//         // Cache the fetched data
//         await WalletTransactionCache.saveWalletTransactionData(
//             customerId, transactions);
//
//         AppLogger.logInfo(
//             '$TAG Loaded ${transactions.length} transactions');
//       } else {
//         // Only set empty state if current state is not already empty
//         if (_stateNotifier.state.transactions.isNotEmpty) {
//           _stateNotifier.setTransactions([]);
//         }
//         AppLogger.logInfo('$TAG No transactions found');
//       }
//     } catch (e) {
//       AppLogger.logError('$TAG Failed to load history: $e');
//       _stateNotifier.setError('Failed to load wallet history: $e');
//     } finally {
//       _stateNotifier.setLoading(false);
//       _isLoading = false;
//     }
//   }
//
//   // Prefetch wallet transactions in the background (can be called from app startup or main tab)
//   Future<void> prefetchWalletHistory() async {
//     try {
//       if (_currentCustomerId == null) {
//         final userData = await AppPreference.getUserData();
//         if (userData.isNotEmpty) {
//           final customer = CustomerModel.fromJson(userData);
//           if (customer.b2cCustomerId != null &&
//               customer.b2cCustomerId!.isNotEmpty) {
//             _currentCustomerId = customer.b2cCustomerId;
//           } else {
//             return; // No customer ID available
//           }
//         } else {
//           return; // No user data available
//         }
//       }
//
//       // First check if we have cached data that is still valid
//       final cachedTransactions = await WalletTransactionCache
//           .getWalletTransactionData(_currentCustomerId!);
//       if (cachedTransactions != null && cachedTransactions.isNotEmpty) {
//         AppLogger.logInfo('$TAG Using existing valid cached data for prefetch');
//         return; // Skip prefetch if we have valid cache
//       }
//
//       // Otherwise fetch in background
//       AppLogger.logInfo(
//           '$TAG Prefetching wallet transaction data for customer: $_currentCustomerId');
//       final response = await _walletService.getWalletTransactions(
//           _currentCustomerId!);
//
//       if (response is List && response.isNotEmpty) {
//         final transactions = response
//             .map((item) => WalletTransactionModel.fromJson(item))
//             .toList();
//
//         await WalletTransactionCache.saveWalletTransactionData(
//             _currentCustomerId!, transactions);
//         AppLogger.logInfo(
//             '$TAG Successfully prefetched and cached ${transactions
//                 .length} transactions');
//       }
//     } catch (e) {
//       AppLogger.logError('$TAG Error prefetching wallet history: $e');
//       // Don't update UI state for background prefetch errors
//     }
//   }
//
//   // Refresh wallet history
//   Future<void> refreshTransactions(String customerId) async {
//     await loadWalletHistory(customerId);
//   }
//
//   // Helper method to compare lists of WalletTransactionModel objects
//   bool _listEquals(List<WalletTransactionModel> a,
//       List<WalletTransactionModel> b) {
//     if (a.length != b.length) return false;
//
//     for (int i = 0; i < a.length; i++) {
//       if (a[i].walletTrxId != b[i].walletTrxId) return false;
//     }
//
//     return true;
//   }
//
//   // Helper method to get total number of transactions
//   int get totalTransactionCount => state.transactions.length;
//
//   // Helper method to get total transaction amount
//   double get totalTransactionAmount {
//     return state.transactions
//         .fold(0, (total, transaction) => total + transaction.trxValue);
//   }
//
//   // Helper to get transactions by type
//   List<WalletTransactionModel> getTransactionsByType(String type) {
//     return state.transactions
//         .where((transaction) => transaction.trxType == type)
//         .toList();
//   }
//
//   void dispose() {
//     // Add any cleanup if needed
//   }
// }

// // lib/features/history/viewmodel/wallet_history_viewmodel.dart
// import '../../../common/log/loggers.dart';
// import '../../ordering/wallet/model/get_wallet_transactions.dart';
// import '../../ordering/wallet/service/wallet_service.dart';
// import '../state/wallet_history_state.dart';
//
// class WalletHistoryViewModel {
//   final WalletService _walletService;
//   final WalletHistoryStateNotifier _stateNotifier;
//
//   WalletHistoryViewModel({
//     required WalletService walletService,
//     required WalletHistoryStateNotifier stateNotifier,
//   })  : _walletService = walletService,
//         _stateNotifier = stateNotifier;
//
//   // Getter for current state
//   WalletHistoryState get state => _stateNotifier.state;
//
//   Future<void> loadWalletHistory(String customerId) async {
//     try {
//       _stateNotifier.setLoading(true);
//
//       final response = await _walletService.getWalletTransactions(customerId);
//
//       AppLogger.logInfo('[WalletHistoryViewModel] Raw response: $response');
//
//       if (response is List && response.isNotEmpty) {
//         final transactions = response
//             .map((item) => WalletTransactionModel.fromJson(item))
//             .toList();
//
//         // Sort transactions by date in descending order_shared_common (newest first)
//         transactions.sort((a, b) => b.date.compareTo(a.date));
//
//         _stateNotifier.setTransactions(transactions);
//
//         AppLogger.logInfo(
//             '[WalletHistoryViewModel] Loaded ${transactions.length} transactions');
//       } else {
//         _stateNotifier.setTransactions([]);
//         AppLogger.logInfo('[WalletHistoryViewModel] No transactions found');
//       }
//     } catch (e) {
//       AppLogger.logError('[WalletHistoryViewModel] Failed to load history: $e');
//       _stateNotifier.setError('Failed to load wallet history: $e');
//     } finally {
//       _stateNotifier.setLoading(false);
//     }
//   }
//
//   // Refresh wallet history
//   Future<void> refreshTransactions(String customerId) async {
//     await loadWalletHistory(customerId);
//   }
//
//   // Helper method to get total number of transactions
//   int get totalTransactionCount => state.transactions.length;
//
//   // Helper method to get total transaction amount
//   double get totalTransactionAmount {
//     return state.transactions
//         .fold(0, (total, transaction) => total + transaction.trxValue);
//   }
//
//   // Helper to get transactions by type
//   List<WalletTransactionModel> getTransactionsByType(String type) {
//     return state.transactions
//         .where((transaction) => transaction.trxType == type)
//         .toList();
//   }
//
//   void dispose() {
//     // Add any cleanup if needed
//   }
// }
