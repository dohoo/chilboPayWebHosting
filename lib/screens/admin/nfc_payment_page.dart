import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/admin_api.dart'; // AdminApi import

class NfcPaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedProducts; // 선택된 상품 목록

  NfcPaymentPage({required this.selectedProducts});

  @override
  _NfcPaymentPageState createState() => _NfcPaymentPageState();
}

class _NfcPaymentPageState extends State<NfcPaymentPage> {
  String message = 'Please tap your NFC card';
  bool isLoading = false;

  Future<void> _payNfcCard() async {
    setState(() {
      isLoading = true;
      message = 'Processing payment for ${widget.selectedProducts.length} products...';
    });
    try {
      NFCTag tag = await FlutterNfcKit.poll();
      String cardId = tag.id;

      final userData = await AdminApi.fetchUserByCard(cardId);
      final userId = userData['userId'];

      for (var product in widget.selectedProducts) {
        final int productId = product['id'];
        final int count = product['count'];

        for (int i = 0; i < count; i++) {
          final result = await AdminApi.processPayment(userId, productId);
          if (!result['success']) {
            setState(() {
              message = result['message'];
            });
            break;
          }
        }
      }
      setState(() {
        message = 'Payment completed successfully!';
      });
    } catch (e) {
      setState(() {
        message = 'Failed to pay with NFC card: $e';
      });
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
    _payNfcCard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment NFC Card'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(message),
        ),
      ),
    );
  }
}
