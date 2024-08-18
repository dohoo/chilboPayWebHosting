import 'package:flutter/material.dart';
import '../festival/festival_account_management_page.dart'; // 추가

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Manage Festival Accounts'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FestivalAccountManagementPage()),
            );
          },
        ),
      ),
    );
  }
}
