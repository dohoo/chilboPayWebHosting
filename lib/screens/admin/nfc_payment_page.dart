import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '../../services/admin_api.dart'; // AdminApi import
import 'payment_complete_page.dart'; // 결제 완료 페이지 import
import 'payment_failed_page.dart';

class NfcPaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedProducts;

  NfcPaymentPage({required this.selectedProducts});

  @override
  _NfcPaymentPageState createState() => _NfcPaymentPageState();
}

class _NfcPaymentPageState extends State<NfcPaymentPage> {
  String message = '카드를 핸드폰 뒷면에 대주세요.';
  bool isLoading = false;

  Future<void> _payNfcCard() async {
    setState(() {
      isLoading = true; // Start loading
      message = '결제 진행중...';
    });

    try {
      // Wait for NFC tag
      NFCTag tag = await FlutterNfcKit.poll();
      String cardId = tag.id;

      // Verify user by card ID
      final userData = await AdminApi.fetchUserByCard(cardId);
      final userId = userData['userId'];

      // Process payment for each selected product
      for (var product in widget.selectedProducts) {
        final int productId = product['id'];
        final int count = product['count'];

        for (int i = 0; i < count; i++) {
          final result = await AdminApi.processPayment(userId, productId);
          if (!result['success']) {
            setState(() {
              isLoading = false; // Stop loading on failure
            });
            // Navigate to PaymentFailedPage with error message
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentFailedPage(
                  errorMessage: result['message'] ?? '오류가 발생하였습니다.',
                ),
              ),
            );
            return; // Exit on payment failure
          }
        }
      }

      // Payment completed successfully
      setState(() {
        message = '결제 완료!';
      });

      // Navigate to PaymentCompletePage on success
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentCompletePage(),
        ),
      );
    } catch (e) {
      // Handle NFC payment failure
      setState(() {
        isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentFailedPage(
            errorMessage: 'Failed to pay with NFC card: $e',
          ),
        ),
      );
    } finally {
      await FlutterNfcKit.finish(); // End NFC mode
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), _payNfcCard); // 페이지가 열리고 1초 후 NFC 결제 시작
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('카드 결제'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(), // 로딩 표시
              SizedBox(height: 16),
              Text('결제 진행중...'),
            ],
          )
              : Text(message),
        ),
      ),
    );
  }
}
