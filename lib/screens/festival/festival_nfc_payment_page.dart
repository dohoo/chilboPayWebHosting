import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/festival_api.dart'; // FestivalApi import

class FestivalNfcPaymentPage extends StatefulWidget {
  @override
  _FestivalNfcPaymentPageState createState() => _FestivalNfcPaymentPageState();
}

class _FestivalNfcPaymentPageState extends State<FestivalNfcPaymentPage> {
  String message = 'Please tap your NFC card';

  Future<void> _payNfcCard() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final productId = prefs.getInt('productId');
      final festivalId = prefs.getInt('festivalId'); // Ensure festivalId is stored in SharedPreferences

      if (productId == null || festivalId == null) {
        setState(() {
          message = 'Product ID or Festival ID is not set';
        });
        return;
      }

      // Start NFC session
      NFCTag tag = await FlutterNfcKit.poll();
      String cardId = tag.id;

      // Fetch user information using cardId
      final userData = await FestivalApi.fetchUserByCard(cardId); // FestivalApi 사용
      final userId = userData['userId'];

      // Proceed with NFC payment
      final result = await FestivalApi.processNfcPayment(cardId, userId, productId, festivalId); // FestivalApi 사용

      setState(() {
        message = result['message'];
      });
    } catch (e) {
      setState(() {
        message = 'Failed to pay with NFC card: $e';
      });
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  @override
  void initState() {
    super.initState();
    _payNfcCard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Festival NFC Payment'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(message),
        ),
      ),
    );
  }
}
