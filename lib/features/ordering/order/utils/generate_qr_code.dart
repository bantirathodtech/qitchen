// filename: generate_qr_code.dart

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRCode extends StatelessWidget {
  final String generatedSOrderNo;

  const GenerateQRCode({super.key, required this.generatedSOrderNo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated QR Code'),
      ),
      body: Center(
        child: QrImageView(
          data: generatedSOrderNo,
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}
