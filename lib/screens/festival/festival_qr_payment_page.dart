import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../services/festival_api.dart';
import 'payment_success_page.dart';

class FestivalQrPaymentPage extends StatefulWidget {
  final int productId;
  final int festivalId;
  final bool isActivity;

  FestivalQrPaymentPage({
    required this.productId,
    required this.festivalId,
    required this.isActivity, // 추가된 isActivity 파라미터
  });

  @override
  _FestivalQrPaymentPageState createState() => _FestivalQrPaymentPageState();
}

class _FestivalQrPaymentPageState extends State<FestivalQrPaymentPage> {
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

      final token = scanData.code;
      if (token == null || token.isEmpty) {
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
        final result = await FestivalApi.processQrPaymentWithToken(token, widget.productId, widget.isActivity);
        if (result['success']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PaymentSuccessPage()),
          );
        } else {
          setState(() {
            message = result['message'];
          });
        }
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
