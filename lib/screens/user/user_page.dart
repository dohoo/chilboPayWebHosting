import 'package:flutter/material.dart';
import 'home_page.dart';
import 'transaction_page.dart';
import 'settings_page.dart';
import 'send_money_page.dart'; // 새로 추가된 페이지

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    SendMoneyPage(),
    TransactionPage(),
    HomePage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,  // 고정 크기 설정
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            label: 'Send Money',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transaction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey, // 비선택 상태의 색상 설정
        selectedFontSize: 12, // 선택된 아이템의 글꼴 크기
        unselectedFontSize: 10, // 선택되지 않은 아이템의 글꼴 크기
        onTap: _onItemTapped,
      ),
    );
  }
}
