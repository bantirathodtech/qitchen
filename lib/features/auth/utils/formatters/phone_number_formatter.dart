import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow only 10 digits
    if (newValue.text.length > 10) {
      return oldValue; // Disallow more than 10 digits
    }

    // Allow numbers only
    if (newValue.text.isNotEmpty && !RegExp(r'^\d*$').hasMatch(newValue.text)) {
      return oldValue; // Disallow non-numeric input
    }

    return newValue; // Return the valid input
  }
}
