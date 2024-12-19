import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  final MobileScannerController scannerController = MobileScannerController();
  String message = 'QR코드를 카메라에 대주세요.';
  bool isProcessing = false;
  bool isScanned = false; // 중복 스캔 방지용 플래그

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    // capture.barcodes 리스트 안에 인식된 QR/바코드 정보가 들어있습니다.
    final barcodes = capture.barcodes;
    //final args = capture.args; // 필요하다면 사용
    if (barcodes.isEmpty) {
      setState(() {
        message = 'QR코드가 유효하지 않습니다. 다시 시도해주세요.';
      });
      return;
    }

    // 여러 바코드 중 첫 번째 것 사용
    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) {
      setState(() {
        message = 'QR코드가 유효하지 않습니다. 다시 시도해주세요.';
      });
      return;
    }

    // 이후 결제 로직 진행
    if (isProcessing || isScanned) return;
    setState(() {
      isProcessing = true;
      isScanned = true;
      message = '결제 진행중...';
    });

    try {
      final result = await FestivalApi.processQrPaymentWithToken(
        code,
        widget.productId,
        widget.isActivity,
      );
      if (result['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PaymentSuccessPage()),
        );
      } else {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Payment'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: scannerController,
              onDetect: (capture) => _onDetect(capture),
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