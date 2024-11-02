import 'package:flutter/material.dart';
import 'home_page.dart';
import 'transaction_page.dart';
import 'settings_page.dart';
import 'send_money_page.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 2;

  final GlobalKey<HomePageState> _homePageKey = GlobalKey<HomePageState>();

  late final List<Widget> _widgetOptions = [
    SendMoneyPage(),
    TransactionPage(),
    HomePage(key: _homePageKey),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      // HomePage로 이동할 때 활성화 상태 설정
      if (index == 2) {
        _homePageKey.currentState?.onReturnToHomePage();
      } else if (_selectedIndex == 2) {
        _homePageKey.currentState?.onLeaveHomePage();
      }
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
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            label: '송금',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: '거래내역',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '결제',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        onTap: _onItemTapped,
      ),
    );
  }
}
