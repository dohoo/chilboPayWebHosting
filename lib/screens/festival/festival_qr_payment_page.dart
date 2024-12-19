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

  Future<void> _onDetect(BarcodeCapture capture) async {
    // 이미 처리 중이거나, 한 번 스캔된 상태라면 무시
    if (isProcessing || isScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) {
      setState(() {
        message = 'QR코드가 유효하지 않습니다. 다시 시도해주세요.';
      });
      return;
    }

    // 여러개 감지 시 첫 번째 바코드만 처리
    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) {
      setState(() {
        message = 'QR코드가 유효하지 않습니다. 다시 시도해주세요.';
      });
      return;
    }

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
              // 콜백 시그니처 변경된 형태
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
