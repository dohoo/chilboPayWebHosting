import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../services/admin_api.dart';
import 'payment_complete_page.dart'; // 결제 완료 페이지 import

class QrPaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedProducts;

  QrPaymentPage({required this.selectedProducts});

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

      final token = scanData.code;
      if (token == null) {
        setState(() {
          message = 'Invalid QR code.';
        });
        controller.resumeCamera();
        return;
      }

      setState(() {
        isProcessing = true;
        message = 'Processing payment...';
      });

      try {
        for (var product in widget.selectedProducts) {
          final int productId = product['id'];
          final int count = product['count'];

          for (int i = 0; i < count; i++) {
            final result = await AdminApi.processPaymentWithToken(token, productId);
            if (!result['success']) {
              setState(() {
                message = result['message'];
                isProcessing = false; // 결제 실패 시 로딩 종료
              });
              controller.resumeCamera();
              return; // 결제 실패 시 종료
            }
          }
        }

        setState(() {
          message = 'Payment completed successfully!';
        });

        // 모든 결제가 완료되면 결제 완료 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentCompletePage(),
          ),
        );
      } catch (e) {
        setState(() {
          message = 'Failed to pay with QR code: $e';
        });
      } finally {
        setState(() {
          isProcessing = false; // 모든 결제 처리 종료 후 로딩 종료
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
