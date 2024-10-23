import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/admin_api.dart'; // AdminApi import

class NfcPaymentPage extends StatefulWidget {
  @override
  _NfcPaymentPageState createState() => _NfcPaymentPageState();
}

class _NfcPaymentPageState extends State<NfcPaymentPage> {
  String message = 'Please tap your NFC card';

  Future<void> _payNfcCard() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final productId = prefs.getInt('productId');

      if (productId == null) {
        setState(() {
          message = 'Product ID is not set';
        });
        return;
      }

      // Start NFC session
      NFCTag tag = await FlutterNfcKit.poll();
      String cardId = tag.id;

      // Fetch userId using cardId
      final userData = await AdminApi.fetchUserByCard(cardId);
      final userId = userData['userId'];

      // Proceed with payment
      final result = await AdminApi.processPayment(userId, productId);

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
        title: Text('Payment NFC Card'),
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
