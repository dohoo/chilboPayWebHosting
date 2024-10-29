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

  Future<void> _startNfcPayment() async {
    try {
      NFCTag tag = await FlutterNfcKit.poll();
      final userData = await FestivalApi.getUserIdByCard(tag.id);

      // userId를 Map에서 추출하여 int로 할당
      final int userId = userData['userId'];

      final result = await FestivalApi.processNfcPayment(userId, widget.productId, widget.festivalId);

      setState(() => message = result['message']);
    } catch (e) {
      setState(() => message = 'Payment failed: $e');
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  @override
  void initState() {
    super.initState();
    _startNfcPayment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NFC Payment')),
      body: Center(child: Text(message)),
    );
  }
}
