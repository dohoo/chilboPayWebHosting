import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '../../services/festival_api.dart';
import 'payment_success_page.dart';
import 'payment_failed_page.dart';

class FestivalNfcPaymentPage extends StatefulWidget {
  final int productId;
  final int festivalId;
  final bool isActivity;

  FestivalNfcPaymentPage({
    required this.productId,
    required this.festivalId,
    required this.isActivity,
  });

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

      // Determine the type based on isActivity flag
      final result = await FestivalApi.processNfcPayment(
        userId,
        widget.productId,
        widget.festivalId,
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
              errorMessage: result['message'] ?? 'Payment failed for unknown reasons',
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentFailedPage(
            errorMessage: 'Payment failed: $e',
          ),
        ),
      );
    } finally {
      await FlutterNfcKit.finish();
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
