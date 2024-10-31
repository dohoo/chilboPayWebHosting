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
  bool isProcessing = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();

      // QR 데이터 파싱
      final qrData = scanData.code;
      if (qrData == null || !qrData.contains("_")) {
        setState(() {
          message = 'Invalid QR format';
        });
        controller.resumeCamera(); // 잘못된 형식이면 다시 카메라 재개
        return;
      }

      // QR 데이터 구조 검증
      final parts = qrData.split("_");
      final userId = int.tryParse(parts[0]);
      final timestamp = int.tryParse(parts[1]);

      if (userId == null || timestamp == null) {
        setState(() {
          message = 'Invalid QR code';
        });
        controller.resumeCamera();
        return;
      }

      setState(() {
        isProcessing = true;
        message = 'Processing payment...';
      });

      try {
        final result = await AdminApi.processPayment(userId, widget.productId);
        setState(() {
          message = result['message'];
        });
      } catch (e) {
        setState(() {
          message = 'Failed to pay with QR code: $e';
        });
      } finally {
        setState(() {
          isProcessing = false;
        });
        controller.resumeCamera();
      }
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
              child: isProcessing
                  ? CircularProgressIndicator()
                  : Text(
                message,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
