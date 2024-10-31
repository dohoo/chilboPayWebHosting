import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '../../services/festival_api.dart';

class FestivalNfcPaymentPage extends StatefulWidget {
  final int productId;
  final int festivalId;

  FestivalNfcPaymentPage({required this.productId, required this.festivalId});

  @override
  _FestivalNfcPaymentPageState createState() => _FestivalNfcPaymentPageState();
}

class _FestivalNfcPaymentPageState extends State<FestivalNfcPaymentPage> {
  String message = 'Tap NFC Card';
  bool isLoading = false; // 로딩 상태 변수

  Future<void> _startNfcPayment() async {
    setState(() {
      isLoading = true; // 결제 시작 시 로딩 상태 설정
      message = 'Processing payment...';
    });
    try {
      NFCTag tag = await FlutterNfcKit.poll();
      final userData = await FestivalApi.getUserIdByCard(tag.id);
      final int userId = userData['userId'];

      final result = await FestivalApi.processNfcPayment(userId, widget.productId, widget.festivalId);

      setState(() {
        message = result['message'];
      });
    } catch (e) {
      setState(() {
        message = 'Payment failed: $e';
      });
    } finally {
      await FlutterNfcKit.finish(); // NFC 처리 종료
      setState(() {
        isLoading = false; // 결제 완료 후 로딩 상태 해제
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), _startNfcPayment); // 페이지가 열리고 1초 후 NFC 결제 시작
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NFC Payment')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(), // 로딩 표시
              SizedBox(height: 16),
              Text('Processing payment...'),
            ],
          )
              : Text(message),
        ),
      ),
    );
  }
}
