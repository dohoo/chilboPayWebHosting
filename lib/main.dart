import 'package:flutter/material.dart';
import 'package:chilbopay/screens/login/login_page.dart';
import 'package:chilbopay/screens/shared/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChilboPay',
      theme: initThemeData(brightness: Brightness.light),
      darkTheme: initThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: LoginPage(),
    );
  }
}
