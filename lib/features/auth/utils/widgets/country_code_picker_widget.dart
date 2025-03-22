import 'package:country_code_picker_plus/country_code_picker_plus.dart';
import 'package:flutter/material.dart';

class CountryCodePickerWidget extends StatelessWidget {
  final String selectedCountryCode;
  final Function(String) onChanged;

  const CountryCodePickerWidget({
    super.key,
    required this.selectedCountryCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CountryCodePicker(
      onChanged: (country) {
        onChanged(country.dialCode ?? '+91');
      },
      initialSelection: 'IN',
      favorite: const ['+91'],
      showFlag: true,
      showDropDownButton: true,
      flagDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
      ),
    );
  }
}
