import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpInputWidget extends StatefulWidget {
  final ValueChanged<String> onCodeComplete;
  final Color activeColor;
  final Color inactiveColor;

  const OtpInputWidget({
    super.key,
    required this.onCodeComplete,
    this.activeColor = Colors.yellow,
    this.inactiveColor = Colors.grey,
  });

  @override
  OtpInputWidgetState createState() => OtpInputWidgetState();
}

class OtpInputWidgetState extends State<OtpInputWidget> {
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  StreamController<ErrorAnimationType>? errorController =
      StreamController<ErrorAnimationType>();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        // Optionally, you can perform actions when the field gains focus
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
        child: PinCodeTextField(
          appContext: context,
          length: 6,
          obscureText: false,
          animationType: AnimationType.fade,
          validator: (v) {
            if (v!.length < 3) {
              return "I'm from validator";
            } else {
              return null;
            }
          },
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(5),
            fieldHeight: 50,
            fieldWidth: 40,
            activeFillColor: HexColor("#FFFFFF"),
            inactiveFillColor: HexColor("#FFFFFF"),
          ),
          cursorColor: Colors.black, //DON'T CHANGE
          animationDuration: const Duration(milliseconds: 300),
          enableActiveFill: true,
          errorAnimationController: errorController,
          controller: textEditingController,
          keyboardType: TextInputType.number,
          focusNode: focusNode, // Set focus node
          onCompleted: (v) {
            widget.onCodeComplete(v);
          },
          onChanged: (value) {
            // Add any additional logic if needed
          },
          beforeTextPaste: (text) {
            return true; // Allow pasting
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
