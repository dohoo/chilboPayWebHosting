import 'package:flutter/material.dart';
import 'package:chilbopay/screens/login/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChilboPay',
      theme: ThemeData(
        //primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
