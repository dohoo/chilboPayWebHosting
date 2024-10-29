import 'package:flutter/material.dart';
import 'user_management_page.dart';
import 'card_payment_page.dart';
import 'statistics_page.dart';
import 'admin_settings_page.dart'; // 추가

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    UserManagementPage(),
    CardPaymentPage(),
    StatisticsPage(),
    AdminSettingsPage(), // 추가
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
        type: BottomNavigationBarType.fixed,  // 모든 아이템을 고정 크기로 표시
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle, size: 24), // 아이콘 크기 조정
            label: 'User Management',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment, size: 24), // 아이콘 크기 조정
            label: 'Card Payment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, size: 24), // 아이콘 크기 조정
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 24), // 아이콘 크기 조정
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
