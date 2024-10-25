import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../services/admin_api.dart';

class QrPaymentPage extends StatefulWidget {
  final int productId;

  QrPaymentPage({required this.productId});

  @override
  _QrPaymentPageState createState() => _QrPaymentPageState();
}

class _QrPaymentPageState extends State<QrPaymentPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String message = 'Please scan your QR code';
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      final userIdString = scanData.code;

      if (userIdString != null) {
        try {
          // userIdString을 int로 변환
          final userId = int.tryParse(userIdString);
          if (userId == null) {
            setState(() {
              message = 'Invalid QR code';
            });
          } else {
            final result = await AdminApi.processPayment(userId, widget.productId);
            setState(() {
              message = result['message'];
            });
          }
        } catch (e) {
          setState(() {
            message = 'Failed to pay with QR code: $e';
          });
        }
      }

      controller.resumeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Code Payment')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(message),
            ),
          ),
        ],
      ),
    );
  }
}
