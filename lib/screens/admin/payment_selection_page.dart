import 'package:flutter/material.dart';
import 'nfc_payment_page.dart';
import 'qr_payment_page.dart';

class PaymentSelectionPage extends StatelessWidget {
  final int productId;

  PaymentSelectionPage({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Payment Method'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NfcPaymentPage(),
                  ),
                );
              },
              child: Text('NFC Card Payment'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QrPaymentPage(productId: productId),
                  ),
                );
              },
              child: Text('QR Code Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
