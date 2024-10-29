import 'package:flutter/material.dart';
import 'festival_management_page.dart';
import 'festival_payment_page.dart';
import 'festival_settings_page.dart';

class FestivalPage extends StatefulWidget {
  @override
  _FestivalPageState createState() => _FestivalPageState();
}

class _FestivalPageState extends State<FestivalPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    FestivalManagementPage(),
    FestivalPaymentPage(),
    FestivalSettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '관리'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: '결제'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
