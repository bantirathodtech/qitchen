import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpPinInput extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final Color? activeColor;
  final Color? inactiveColor;
  final String? errorText;
  final String? Function(String?)? validator;

  const OtpPinInput({
    super.key,
    required this.onCompleted,
    this.activeColor,
    this.inactiveColor,
    this.errorText,
    this.validator,
  });

  @override
  State<OtpPinInput> createState() => _OtpPinInputState();
}

class _OtpPinInputState extends State<OtpPinInput> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const length = 6;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: widget.inactiveColor ?? const Color.fromRGBO(234, 239, 243, 1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: widget.activeColor ?? Colors.black,
          width: 2,
        ),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 0.1),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: Colors.red,
        ),
      ),
    );

    return Pinput(
      length: length,
      controller: pinController,
      focusNode: focusNode,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      errorPinTheme: errorPinTheme,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      validator: widget.validator,
      errorText: widget.errorText,
      onCompleted: widget.onCompleted,
      onChanged: (value) {
        // You can add additional logic here if needed
      },
    );
  }
}
