import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '../../services/admin_api.dart'; // AdminApi import
import 'payment_complete_page.dart'; // 결제 완료 페이지 import

class NfcPaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedProducts;

  NfcPaymentPage({required this.selectedProducts});

  @override
  _NfcPaymentPageState createState() => _NfcPaymentPageState();
}

class _NfcPaymentPageState extends State<NfcPaymentPage> {
  String message = 'Please tap your NFC card';
  bool isLoading = false;

  Future<void> _payNfcCard() async {
    setState(() {
      isLoading = true; // 로딩 시작
      message = 'Processing payment...';
    });

    try {
      // NFC 태그 대기
      NFCTag tag = await FlutterNfcKit.poll();
      String cardId = tag.id;

      // 카드 ID로 사용자 확인
      final userData = await AdminApi.fetchUserByCard(cardId);
      final userId = userData['userId'];

      // 선택된 상품 개별 결제 처리
      for (var product in widget.selectedProducts) {
        final int productId = product['id'];
        final int count = product['count'];

        for (int i = 0; i < count; i++) {
          final result = await AdminApi.processPayment(userId, productId);
          if (!result['success']) {
            setState(() {
              message = result['message'];
              isLoading = false; // 결제 실패 시 로딩 종료
            });
            return; // 결제 실패 시 종료
          }
        }
      }

      setState(() {
        message = 'Payment completed successfully!';
      });

      // 모든 결제가 완료되면 결제 완료 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentCompletePage(),
        ),
      );
    } catch (e) {
      setState(() {
        message = 'Failed to pay with NFC card: $e';
      });
    } finally {
      await FlutterNfcKit.finish(); // NFC 모드 종료
      setState(() {
        isLoading = false; // 로딩 종료
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
        title: Text('Payment NFC Card'),
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
              Text('Processing payment...'),
            ],
          )
              : Text(message),
        ),
      ),
    );
  }
}
