// wallet_balance_card.dart
import 'package:flutter/material.dart';
import '../../../../common/styles/app_text_styles.dart';
import '../model/get_wallet_balance.dart';

class WalletBalanceCard extends StatelessWidget {
  final GetWalletBalanceModel? walletBalance;
  final bool isLoading;

  const WalletBalanceCard({
    super.key,
    required this.walletBalance,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(36, 60, 36, 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromRGBO(225, 227, 242, 1),
            const Color.fromRGBO(237, 237, 241, 1),
            const Color.fromRGBO(225, 227, 242, 1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if (walletBalance?.b2cCustomerName.isNotEmpty ?? false) ...[
          //   Text(
          //     'Hello, ${walletBalance!.b2cCustomerName}',
          //     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          //   ),
          //   const SizedBox(height: 16),
          // ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Available Balance:', style: AppTextStyles.h3),
              const SizedBox(width: 16),
              if (isLoading)
                const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Text(
                  '₹${(walletBalance?.balanceAmt ?? 0).toStringAsFixed(2)}',
                  style: AppTextStyles.h2,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
