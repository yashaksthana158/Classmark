import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:typed_data';

class QrCodePage extends StatelessWidget {
  final String qrCodeUrl;

  QrCodePage({required this.qrCodeUrl});

  Future<Uint8List?> _fetchQrCode() async {
    final response = await http.get(Uri.parse(qrCodeUrl));

    if (response.statusCode == 200) {
      return response.bodyBytes; // Get image data directly as bytes
    } else {
      print('Failed to load QR code');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code'),
      ),
      body: FutureBuilder<Uint8List?>(
        future: _fetchQrCode(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Failed to load QR code.'));
          } else {
            return Center(
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              ),
            );
          }
        },
      ),
    );
  }
}
