import '../../../../common/log/loggers.dart';
import '../../../../data/db/app_preferences.dart';
import '../model/get_wallet_balance.dart';
import '../model/upsert_wallet_transaction.dart';
import '../service/wallet_service.dart';

class WalletRepository {
  final WalletService walletService;

  WalletRepository({required this.walletService});

  Future<GetWalletBalanceModel> getWalletBalance(String walletId) async {
    try {
      final responseData = await walletService.getWalletBalance(walletId);
      final walletBalance = GetWalletBalanceModel.fromJson(responseData);
      AppLogger.logInfo(
          '[WalletRepository] Balance: ${walletBalance.balanceAmt}');
      return walletBalance;
    } catch (e) {
      AppLogger.logError('[WalletRepository] Balance fetch failed: $e');
      rethrow;
    }
  }

  Future<WalletTransactionResult> addMoneyToWallet({
    required String customerId,
    required double amount,
  }) async {
    try {
      // Process transaction
      final response = await walletService.upsertWalletTransaction(
        b2cCustomerId: customerId,
        trxType: 'DP',
        trxValue: amount,
      );

      // Convert response to UpsertWalletTransaction
      final transaction = UpsertWalletTransaction.fromJson(response);

      // Store the new walletId (recordId) on success
      if (transaction.response.status == '200') {
        AppLogger.logInfo(
            'Repository: Transaction successful. RecordId: ${transaction.response.recordId}, Amount: $amount');
        await AppPreference.saveWalletId(transaction.response.recordId);

        // Get updated balance
        final result = await walletService.addMoneyToWallet(customerId, amount);

        if (result.success) {
          AppLogger.logInfo(
              '[WalletRepository] Money added successfully. Amount: $amount, New Balance: ${result.balance}');
        } else {
          AppLogger.logError(
              '[WalletRepository] Add money failed. Error: ${result.error}');
        }

        return result;
      } else {
        AppLogger.logError(
            'Repository: Transaction failed. Status: ${transaction.response.status}, Amount: $amount');

        return WalletTransactionResult(
          success: false,
          error: transaction.response.message,
        );
      }
    } catch (e) {
      AppLogger.logError('[WalletRepository] Add money failed: $e');
      rethrow;
    }
  }

  Future<WalletTransactionResult> spendFromWallet({
    required String customerId,
    required double amount,
    required String orderNumber,
  }) async {
    try {
      // Process single transaction
      final response = await walletService.upsertWalletTransaction(
        b2cCustomerId: customerId,
        trxType: 'SA',
        trxValue: amount,
      );

      // Convert response to UpsertWalletTransaction
      final transaction = UpsertWalletTransaction.fromJson(response);

      // If transaction successful, store walletId if needed and get updated balance
      if (transaction.response.status == '200') {
        // Store walletId if not already stored
        await AppPreference.saveWalletId(transaction.response.recordId);

        // // Get updated balance and status from service
        // final result = await walletService.spendFromWallet(customerId, amount);
        //
        // if (result.success) {
        //   AppLogger.logInfo(
        //       '[WalletRepository] Spend successful. Amount: $amount, New Balance: ${result.balance}');
        // } else {
        //   AppLogger.logError(
        //       '[WalletRepository] Spend failed. Error: ${result.error}');
        // }
        //
        // return result;
        // Get updated balance
        final balanceResponse =
            await walletService.getWalletBalance(customerId);
        final balance =
            GetWalletBalanceModel.fromJson(balanceResponse).balanceAmt;

        AppLogger.logInfo(
            '[WalletRepository] Spend successful. Amount: $amount, New Balance: $balance');

        return WalletTransactionResult(
          success: true,
          walletId: transaction.response.recordId,
          balance: balance,
        );
      } else {
        AppLogger.logError(
            'Repository: Transaction failed. Status: ${transaction.response.status}, Amount: $amount');

        return WalletTransactionResult(
          success: false,
          error: transaction.response.message,
        );
      }
    } catch (e) {
      AppLogger.logError('[WalletRepository] Spend failed: $e');
      rethrow;
    }
  }
}
