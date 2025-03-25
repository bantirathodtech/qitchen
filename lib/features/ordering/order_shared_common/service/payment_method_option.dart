// widgets/payment_method_option.dart
import 'package:flutter/material.dart';

class PaymentMethodOption extends StatelessWidget {
  final String title;
  // final IconData icon;
  final Widget icon; // Changed from IconData to Widget
  final bool isSelected;
  final bool isWallet;
  final bool isLoading;
  final double? walletBalance;
  final VoidCallback onSelect;
  final VoidCallback? onAddMoney;

  const PaymentMethodOption({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    this.isWallet = false,
    this.isLoading = false,
    this.walletBalance,
    required this.onSelect,
    this.onAddMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300, // Light grey for the border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400, // Slightly darker grey for shadow
            offset: const Offset(1, 1), // Slight offset for a 3D effect
            blurRadius: 3,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white, // Inner highlight for the top-left corner
            offset: const Offset(-1, -1),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon(icon, color: Colors.black54),
                icon, // Use the passed Widget directly
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isWallet) // Only show this for non-wallet options
                        Text(
                          '(Credit card/debit card etc)',
                          style: TextStyle(color: Colors.black),
                        ),
                    ],
                  ),
                ),
                if (isWallet && onAddMoney != null) ...[
                  // _buildWalletBalance(isLoading, walletBalance), // Moved here
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      _buildWalletBalance(
                          isLoading, walletBalance), // Moved here
                      const SizedBox(height: 8),

                      ElevatedButton(
                        onPressed: onAddMoney,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(55, 84, 211, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Add Money',
                          style: TextStyle(
                              color: Colors
                                  .white), // Ensures the text color is pure white
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
                _buildSelectionIndicator(isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletBalance(bool isLoading, double? balance) {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Text(
      '₹${balance?.toStringAsFixed(2) ?? '0.00'}',
      style: TextStyle(
        color: Colors.black,
        fontSize: 18, // Adjust the size as per your needs
        fontWeight: FontWeight.bold, // Make the text bold
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected) {
    return isSelected
        ? const Icon(Icons.check_circle, color: Color.fromRGBO(55, 84, 211, 1))
        : Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
          );
  }
}
