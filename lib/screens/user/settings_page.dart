import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_api.dart';
import '../login/login_page.dart';
import 'nfc_register_page.dart';
import 'nfc_unregister_page.dart';
import '../login/terms_page.dart'; // TermsPage import

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String username = '';
  String nfcCardId = '';
  bool isSuspended = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      _logout();
      return;
    }

    try {
      final data = await UserApi.fetchUserData(userId);
      setState(() {
        username = data['username'];
        nfcCardId = data['nfcCardId'] ?? '';
        isSuspended = data['status'] == 'suspended';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
      _logout();
    }
  }

  Future<void> _updateUser({String? newUsername, String? newPassword}) async {
    if (isSuspended) {
      _showSuspendedMessage();
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    try {
      await UserApi.updateUser(userId!,
        username: newUsername,
        password: newPassword,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User updated successfully')),
      );
      _fetchUserData();
      _usernameController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user: $e')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    if (isSuspended) {
      _showSuspendedMessage();
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    try {
      await UserApi.deleteUser(userId!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account deleted successfully')),
      );
      await prefs.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account: $e')),
      );
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _showSuspendedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('계정이 정지되어 이 작업을 수행할 수 없습니다.')),
    );
  }

  void _showUpdateUsernameDialog() {
    _usernameController.text = username;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Username'),
          content: TextField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: 'New Username'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateUser(newUsername: _usernameController.text);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdatePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_passwordController.text == _confirmPasswordController.text) {
                  _updateUser(newPassword: _passwordController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Passwords do not match')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _logout();
                Navigator.of(context).pop();
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteAccount();
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 상단 이름 섹션
            Text(
              '$username님',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Divider(thickness: 1, color: Colors.grey),
            // NFC 카드 등록 / 해지
            ElevatedButton(
              onPressed: isSuspended
                  ? _showSuspendedMessage
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => nfcCardId.isEmpty
                        ? NfcRegisterPage()
                        : NfcUnregisterPage(),
                  ),
                );
              },
              child: Text(nfcCardId.isEmpty ? '카드 연동' : '카드 연동 해지'),
            ),
            Divider(thickness: 1, color: Colors.grey),
            // 계정 관리 섹션
            ElevatedButton(
              onPressed: isSuspended ? _showSuspendedMessage : _showUpdateUsernameDialog,
              child: Text('아이디 변경'),
            ),
            ElevatedButton(
              onPressed: isSuspended ? _showSuspendedMessage : _showUpdatePasswordDialog,
              child: Text('비밀번호 변경'),
            ),
            Divider(thickness: 1, color: Colors.grey),
            // 개인정보 처리 방침
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TermsPage()),
                );
              },
              child: Text('개인정보 처리 방침'),
            ),
            // 기타 설정 섹션
            ElevatedButton(
              onPressed: _showLogoutConfirmationDialog,
              child: Text('로그아웃'),
            ),
            ElevatedButton(
              onPressed: isSuspended ? _showSuspendedMessage : _showDeleteAccountConfirmationDialog,
              child: Text('탈퇴하기'),
            ),
          ],
        ),
      ),
    );
  }
}
