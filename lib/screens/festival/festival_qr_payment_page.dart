import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../services/festival_api.dart';
import 'payment_success_page.dart';
import 'payment_failed_page.dart';

class FestivalQrPaymentPage extends StatefulWidget {
  final int productId;
  final int festivalId;
  final bool isActivity;

  FestivalQrPaymentPage({
    required this.productId,
    required this.festivalId,
    required this.isActivity,
  });

  @override
  _FestivalQrPaymentPageState createState() => _FestivalQrPaymentPageState();
}

class _FestivalQrPaymentPageState extends State<FestivalQrPaymentPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String message = 'QR코드를 카메라에 대주세요.';
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
          message = 'QR코드가 유효하지 않습니다. 다시 시도해주세요.';
        });
        controller.resumeCamera();
        return;
      }

      setState(() {
        isProcessing = true;
        message = '결제 진행중...';
      });

      try {
        final result = await FestivalApi.processQrPaymentWithToken(
          token,
          widget.productId,
          widget.isActivity,
        );

        if (result['success']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PaymentSuccessPage()),
          );
        } else {
          // Navigate to PaymentFailedPage with the error message
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentFailedPage(
                errorMessage: result['message'] ?? '결제에 실패하였습니다.',
              ),
            ),
          );
        }
      } catch (e) {
        // Handle QR payment failure
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentFailedPage(
              errorMessage: '결제에 실패하였습니다.',
            ),
          ),
        );
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