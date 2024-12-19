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
  void initState() {
    super.initState();
    // 필요하다면 권한 체크를 직접 수행하거나,
    // mobile_scanner 최신 버전을 사용해 자동권한 요청을 시도해볼 수 있습니다.
    // 또한 iOS/Android 권한 설정을 프로젝트 레벨에서 확인해야 합니다.
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  void _onDetect(Barcode barcode, MobileScannerArguments? args) async {
    if (isProcessing || isScanned) return;

    final String? code = barcode.rawValue;
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
            errorMessage: '결제에 실패하였습니다. (${e.toString()})',
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
              // autofocusEnabled: true, // 필요시 사용
              // fit: BoxFit.cover, // 카메라 화면 표시 방법
              // facing: CameraFacing.back, // 전면/후면 카메라 선택
              onDetect: (barcode, args) => _onDetect(barcode, args),
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
