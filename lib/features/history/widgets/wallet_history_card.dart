import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../ordering/wallet/model/get_wallet_transactions.dart';

/// WalletHistoryCard - Displays a transaction from the user's wallet history
/// - Uses an ultra-compact design to maximize screen space efficiency
/// - Matches the same design pattern as OrderHistoryCard for consistency
class WalletHistoryCard extends StatelessWidget {
  final WalletTransactionModel transaction;

  const WalletHistoryCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    // Determine transaction characteristics
    final bool isCredit =
        transaction.trxType == 'CR' || transaction.trxType == 'DP';
    final Color amountColor = isCredit ? Colors.green : Colors.red;
    final IconData icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    final String transactionTitle = _getTransactionTitle(transaction.trxType);

    // Build the card using the ultra-compact design pattern
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.grey, width: 0.1),
      ),
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16), // Reduced vertical margin
      // elevation: 0, // Matching OrderHistoryCard
      // color: Colors.white,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(8),
      //   side: const BorderSide(color: Colors.black, width: 0.2), // Black border
      // ),
      // margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Theme(
          // Override ExpansionTile's default spacing behavior
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            visualDensity: VisualDensity.compact, // Reduce internal spacing
          ),
          child: ExpansionTile(
            // Use empty title to take control of the layout
            title: const SizedBox.shrink(),
            // Position the expansion arrow on the right
            trailing: const Icon(Icons.expand_more, color: Colors.black),
            // Custom leading widget that contains transaction info
            leading: _WalletCompactHeader(
              title: transactionTitle,
              date: DateFormat('MMM dd, yyyy HH:mm').format(transaction.date),
              amount: '${isCredit ? '+' : '-'}₹${transaction.trxValue.abs().toStringAsFixed(2)}',
              icon: icon,
              amountColor: amountColor,
              isCredit: isCredit,
            ),
            // Fine-tune padding to optimize space
            tilePadding: const EdgeInsets.only(right: 32, left: 16),
            childrenPadding: EdgeInsets.zero,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            maintainState: true,
            collapsedIconColor: Colors.black,
            iconColor: Colors.black,
            // Expandable content section
            children: [
              Column(
                mainAxisSize: MainAxisSize.min, // Use minimum required space
                children: [
                  // Divider between header and expanded content
                  const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  // Transaction details section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Display each transaction detail in a row
                        _buildDetailRow('Transaction Type:', transactionTitle),
                        const SizedBox(height: 8),
                        _buildDetailRow('Date & Time:', DateFormat('MMM dd, yyyy HH:mm').format(transaction.date)),
                        const SizedBox(height: 8),
                        _buildDetailRow('Amount:', '${isCredit ? '+' : '-'}₹${transaction.trxValue.abs().toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        _buildDetailRow('Closing Balance:', '₹${transaction.closingAmt.toStringAsFixed(2)}'),
                        const SizedBox(height: 16),
                        // Action button(s)
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 28, // Reduced height
                                child: OutlinedButton(
                                  onPressed: () {
                                    // Add receipt download functionality
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.black),
                                    padding: EdgeInsets.zero,
                                    foregroundColor: Colors.black,
                                    minimumSize: Size.zero, // Allow smaller size
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap target
                                  ),
                                  child: const Text(
                                    'Download Receipt',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates a consistent row layout for transaction details
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// Returns a readable title based on transaction type
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

/// Custom compact header for wallet transactions
/// Optimizes vertical space while displaying essential transaction information
class _WalletCompactHeader extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final IconData icon;
  final Color amountColor;
  final bool isCredit;

  const _WalletCompactHeader({
    required this.title,
    required this.date,
    required this.amount,
    required this.icon,
    required this.amountColor,
    required this.isCredit,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate available width, accounting for screen size and other elements
    final availableWidth = MediaQuery.of(context).size.width * 0.7;

    return SizedBox(
      height: 36, // Fixed compact height
      width: availableWidth, // Control width to avoid overflow
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Transaction type indicator
          CircleAvatar(
            radius: 14, // Smaller circle
            backgroundColor: amountColor.withOpacity(0.1),
            child: Icon(
              icon,
              color: amountColor,
              size: 16, // Smaller icon
            ),
          ),
          const SizedBox(width: 8),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              children: [
                // Top row with title and amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Transaction title (left)
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          height: 1.1, // Tighter line height
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Amount (right)
                    Text(
                      amount,
                      style: TextStyle(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1), // Minimal spacing
                // Date on bottom row
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.0, // Tighter line height
                    color: Color(0xFF666666),
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}