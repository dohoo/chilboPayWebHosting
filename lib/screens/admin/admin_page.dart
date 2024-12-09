import 'package:flutter/material.dart';
import 'user_management_page.dart';
import 'card_payment_page.dart';
import 'statistics_page.dart';
import 'admin_settings_page.dart'; // 추가
import '../../services/admin_api.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 1; // 기본 선택 페이지를 CardPaymentPage로 변경

  static List<Widget> _widgetOptions = <Widget>[
    UserManagementPage(),
    CardPaymentPage(),
    StatisticsPage(),
    AdminSettingsPage(),
  ];

  // 비밀번호 확인 팝업
  Future<bool> _showPasswordPopup(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();
    bool isPasswordCorrect = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Admin Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(hintText: 'Password'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // 서버에 비밀번호 검증 요청
                  isPasswordCorrect = await AdminApi.verifyAdminPassword(passwordController.text);
                  if (!isPasswordCorrect) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Incorrect password')),
                    );
                  }
                } catch (e) {
                  print('Error verifying password: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error verifying password')),
                  );
                } finally {
                  Navigator.of(context).pop();
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    return isPasswordCorrect;
  }

  // 탭 선택 처리
  void _onItemTapped(int index) async {
    if (index != 1) { // CardPaymentPage가 아닌 경우에만 비밀번호 팝업
      bool hasAccess = await _showPasswordPopup(context);
      if (!hasAccess) {
        // 비밀번호가 틀린 경우, 탭 전환을 막음
        return;
      }
    }

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
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle, size: 24),
            label: 'User Management',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment, size: 24),
            label: 'Card Payment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, size: 24),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 24),
            label: 'Settings',
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
