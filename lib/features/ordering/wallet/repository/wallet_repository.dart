// wallet_repository.dart - UPDATED
import '../../../../common/log/loggers.dart';
import '../../../../data/db/app_preferences.dart';
import '../model/get_wallet_balance.dart';
import '../model/upsert_wallet_transaction.dart';
import '../service/wallet_service.dart';

/// Repository class for wallet operations
/// Provides a clean API for the ViewModels by abstracting service details
class WalletRepository {
  final WalletService walletService;

  WalletRepository({required this.walletService});

  /// Get wallet balance
  /// Flow: Call service → Parse model
  ///
  /// @return GetWalletBalanceModel with balance and customer info
  Future<GetWalletBalanceModel> getWalletBalance() async {
    try {
      // Step 1: Get balance data from service
      final responseData = await walletService.getWalletBalance();

      // Step 2: Convert to model
      final walletBalance = GetWalletBalanceModel.fromJson(responseData);

      AppLogger.logInfo('[WalletRepository] Balance: ${walletBalance.balanceAmt}');
      return walletBalance;
    } catch (e) {
      AppLogger.logError('[WalletRepository] Balance fetch failed: $e');
      rethrow;
    }
  }

  /// Get wallet transactions
  /// Flow: Call service → Return transactions
  ///
  /// @return List of transaction records
  Future<List<dynamic>> getWalletTransactions() async {
    try {
      // Step 1: Get transactions from service
      final transactions = await walletService.getWalletTransactions();

      AppLogger.logInfo('[WalletRepository] Fetched ${transactions.length} transactions');
      return transactions;
    } catch (e) {
      AppLogger.logError('[WalletRepository] Transaction fetch failed: $e');
      return [];
    }
  }

  /// Add money to wallet - UPDATED
  /// Flow: Create a single transaction → Save wallet ID → Get updated balance
  ///
  /// @param customerId - Customer ID required for the transaction
  /// @param amount - Amount to add to the wallet
  /// @return Transaction result with success status, wallet ID, and updated balance
  Future<WalletTransactionResult> addMoneyToWallet({
    required String customerId,
    required double amount,
  }) async {
    try {
      AppLogger.logInfo('[WalletRepository] Adding money to wallet:');
      AppLogger.logInfo('- CustomerId: $customerId');
      AppLogger.logInfo('- Amount: $amount');

      // Step 1: Create a single transaction with deposit type (DP)
      // NOTE: This is the ONLY transaction we create
      final response = await walletService.upsertWalletTransaction(
        b2cCustomerId: customerId,
        trxType: 'DP', // Deposit transaction type
        trxValue: amount,
      );

      // Step 2: Convert response to model
      final transaction = UpsertWalletTransaction.fromJson(response);

      // Step 3: Check transaction status
      if (transaction.response.status == '200') {
        AppLogger.logInfo(
            '[WalletRepository] Transaction successful. RecordId: ${transaction.response.recordId}, Amount: $amount');

        // Step 4: Save wallet ID from response
        final recordId = transaction.response.recordId;
        await AppPreference.saveWalletId(recordId);

        // Step 5: Get updated balance
        // Note: We get the balance directly from service without creating another transaction
        final balanceResponse = await walletService.getWalletBalance();
        final balance = GetWalletBalanceModel.fromJson(balanceResponse).balanceAmt;

        AppLogger.logInfo(
            '[WalletRepository] Money added successfully. Amount: $amount, New Balance: $balance');

        // Step 6: Return success result with wallet ID and updated balance
        return WalletTransactionResult(
          success: true,
          walletId: recordId,
          balance: balance,
        );
      } else {
        AppLogger.logError(
            '[WalletRepository] Transaction failed. Status: ${transaction.response.status}, Amount: $amount');

        return WalletTransactionResult(
          success: false,
          error: transaction.response.message,
        );
      }
    } catch (e) {
      AppLogger.logError('[WalletRepository] Add money failed: $e');
      return WalletTransactionResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Spend from wallet - UPDATED
  /// Flow: Create a single transaction → Save wallet ID → Get updated balance
  ///
  /// @param customerId - Customer ID required for the transaction
  /// @param amount - Amount to spend from the wallet
  /// @param orderNumber - Order reference number
  /// @return Transaction result with success status, wallet ID, and updated balance
  Future<WalletTransactionResult> spendFromWallet({
    required String customerId,
    required double amount,
    required String orderNumber,
  }) async {
    try {
      AppLogger.logInfo('[WalletRepository] Processing wallet payment:');
      AppLogger.logInfo('- CustomerId: $customerId');
      AppLogger.logInfo('- Amount: $amount');
      AppLogger.logInfo('- Order: $orderNumber');

      // Step 1: Create a single transaction with spend type (SA)
      final response = await walletService.upsertWalletTransaction(
        b2cCustomerId: customerId,
        trxType: 'SA', // Spend Amount transaction type
        trxValue: amount,
      );

      // Step 2: Convert response to model
      final transaction = UpsertWalletTransaction.fromJson(response);

      // Step 3: Check transaction status
      if (transaction.response.status == '200') {
        // Step 4: Save wallet ID from response
        final recordId = transaction.response.recordId;
        await AppPreference.saveWalletId(recordId);

        // Step 5: Get updated balance
        final balanceResponse = await walletService.getWalletBalance();
        final balance = GetWalletBalanceModel.fromJson(balanceResponse).balanceAmt;

        AppLogger.logInfo(
            '[WalletRepository] Spend successful. Amount: $amount, New Balance: $balance');

        return WalletTransactionResult(
          success: true,
          walletId: recordId,
          balance: balance,
        );
      } else {
        AppLogger.logError(
            '[WalletRepository] Transaction failed. Status: ${transaction.response.status}, Amount: $amount');

        return WalletTransactionResult(
          success: false,
          error: transaction.response.message,
        );
      }
    } catch (e) {
      AppLogger.logError('[WalletRepository] Spend failed: $e');
      return WalletTransactionResult(
        success: false,
        error: e.toString(),
      );
    }
  }
}