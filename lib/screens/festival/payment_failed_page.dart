import 'package:flutter/material.dart';

class PaymentFailedPage extends StatelessWidget {
  final String errorMessage;

  PaymentFailedPage({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Return to the previous screen after 2 seconds
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('결제 실패'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              color: Colors.red,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              '결제에 실패하였습니다.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                errorMessage,
                style: TextStyle(fontSize: 16, color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
