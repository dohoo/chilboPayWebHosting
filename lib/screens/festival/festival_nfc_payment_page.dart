import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '../../services/festival_api.dart';
import 'payment_success_page.dart'; // 결제 성공 페이지 import

class FestivalNfcPaymentPage extends StatefulWidget {
  final int productId;
  final int festivalId;

  FestivalNfcPaymentPage({required this.productId, required this.festivalId});

  @override
  _FestivalNfcPaymentPageState createState() => _FestivalNfcPaymentPageState();
}

class _FestivalNfcPaymentPageState extends State<FestivalNfcPaymentPage> {
  String message = 'Tap NFC Card';
  bool isLoading = false;

  Future<void> _startNfcPayment() async {
    setState(() {
      isLoading = true;
      message = 'Processing payment...';
    });

    try {
      NFCTag tag = await FlutterNfcKit.poll();
      final userData = await FestivalApi.getUserIdByCard(tag.id);
      final int userId = userData['userId'];

      final result = await FestivalApi.processNfcPayment(userId, widget.productId, widget.festivalId);

      if (result['success']) {
        // 결제가 성공하면 성공 페이지로 이동
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
        message = 'Payment failed: $e';
      });
    } finally {
      await FlutterNfcKit.finish(); // NFC 처리 종료
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), _startNfcPayment);
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
              CircularProgressIndicator(),
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
