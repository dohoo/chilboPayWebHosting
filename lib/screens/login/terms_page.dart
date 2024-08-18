import 'package:flutter/material.dart';
import 'signup_page.dart';

class TermsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''약관 동의

동의 안하면 사용 못함
''',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SignUpPage(),
  ));
}