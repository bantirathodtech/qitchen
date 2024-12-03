// lib/features/history/widgets/wallet_history_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../wallet/model/get_wallet_transactions.dart';

class WalletHistoryCard extends StatelessWidget {
  final WalletTransactionModel transaction;

  const WalletHistoryCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCredit =
        transaction.trxType == 'CR' || transaction.trxType == 'DP';
    final Color amountColor = isCredit ? Colors.green : Colors.red;
    final IconData icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    final String transactionTitle = _getTransactionTitle(transaction.trxType);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: amountColor.withOpacity(0.1),
          child: Icon(icon, color: amountColor),
        ),
        title: Text(
          transactionTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM dd, yyyy HH:mm').format(transaction.date)),
            Text(
              'Balance: ₹${transaction.closingAmt.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Text(
          '${isCredit ? '+' : '-'}₹${transaction.trxValue.abs().toStringAsFixed(2)}',
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _getTransactionTitle(String trxType) {
    switch (trxType) {
      case 'DP':
        return 'Deposit';
      case 'SA':
        return 'Spent Amount';
      case 'CR':
        return 'Credit';
      default:
        return 'Transaction';
    }
  }
}
