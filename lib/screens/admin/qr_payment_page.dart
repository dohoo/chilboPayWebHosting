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
  bool isProcessing = false; // 추가: 결제 처리 상태 확인을 위한 변수

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera(); // 카메라 일시 중지
      final userIdString = scanData.code;

      if (userIdString != null) {
        final userId = int.tryParse(userIdString);
        if (userId == null) {
          setState(() {
            message = 'Invalid QR code';
          });
        } else {
          // 결제 진행 상태 표시
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
              isProcessing = false; // 결제 완료 후 상태 업데이트
            });
          }
        }
      }

      // 결제 처리 완료 후 카메라 재개
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
              child: isProcessing
                  ? CircularProgressIndicator() // 결제 진행 중일 때 로딩 인디케이터 표시
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
