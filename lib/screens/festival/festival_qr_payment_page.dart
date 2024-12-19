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

  void _showLogMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: Duration(seconds: 2)),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLogMessage('[initState]: productId=${widget.productId}, festivalId=${widget.festivalId}, isActivity=${widget.isActivity}');
      _startCamera();
    });
  }

// 카메라를 시작하는 메서드
  void _startCamera() {
    try {
      scannerController.start();
      _showLogMessage('Camera started successfully');
    } catch (e) {
      _showLogMessage('Failed to start camera: $e');
    }
  }

  @override
  void dispose() {
    _showLogMessage('[dispose]: Scanner controller disposing...');
    scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    _showLogMessage('_onDetect called');
    // 이미 처리 중이거나, 한 번 스캔된 상태라면 무시
    if (isProcessing || isScanned) {
      _showLogMessage('_onDetect: Already processing or scanned. isProcessing=$isProcessing, isScanned=$isScanned');
      return;
    }

    final barcodes = capture.barcodes;
    _showLogMessage('_onDetect: barcodes count=${barcodes.length}');

    if (barcodes.isEmpty) {
      _showLogMessage('_onDetect: No barcode detected');
      setState(() {
        message = 'QR코드가 유효하지 않습니다. 다시 시도해주세요.';
      });
      return;
    }

    // 여러개 감지 시 첫 번째 바코드만 처리
    final code = barcodes.first.rawValue;
    _showLogMessage('_onDetect: First barcode rawValue=$code');

    if (code == null || code.isEmpty) {
      _showLogMessage('_onDetect: Barcode code is null or empty');
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

    _showLogMessage('_onDetect: Starting payment with code=$code, productId=${widget.productId}, isActivity=${widget.isActivity}');

    try {
      final result = await FestivalApi.processQrPaymentWithToken(
        code,
        widget.productId,
        widget.isActivity,
      );
      _showLogMessage('Payment API call result: $result');

      if (result['success']) {
        _showLogMessage('Payment succeeded. Navigating to PaymentSuccessPage.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PaymentSuccessPage()),
        );
      } else {
        _showLogMessage('Payment failed. Reason: ${result['message'] ?? 'Unknown error'}');
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
      _showLogMessage('Payment API call exception: $e');
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
      _showLogMessage('Payment process completed. isProcessing set to false.');
    }
  }

  @override
  Widget build(BuildContext context) {
    _showLogMessage('[build]: message="$message", isProcessing=$isProcessing, isScanned=$isScanned');
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