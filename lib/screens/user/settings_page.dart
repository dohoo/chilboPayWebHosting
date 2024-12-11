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
  final TextEditingController _currentPasswordController = TextEditingController(); // 현재 비밀번호 컨트롤러 추가
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
        SnackBar(content: Text('유저 정보를 불러오는 데 실패하였습니다.')),
      );
      _logout();
    }
  }

  Future<void> _updateUser({String? newUsername, String? newPassword, String? currentPassword}) async {
    if (isSuspended) {
      _showSuspendedMessage();
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    try {
      await UserApi.updateUser(
        userId!,
        username: newUsername,
        password: newPassword,
        currentPassword: currentPassword,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('완료되었습니다.')),
      );
      _fetchUserData();
      _usernameController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _currentPasswordController.clear(); // 현재 비밀번호 입력 필드 초기화
    } catch (e) {
      if (e.toString().contains('Current password is incorrect')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('현재 비밀번호가 일치하지 않습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('문제가 발생하였습니다.')),
        );
      }
    }
  }

  Future<void> _deleteAccount(String password) async {
    if (isSuspended) {
      _showSuspendedMessage();
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    try {
      final success = await UserApi.deleteUser(userId!, password); // 비밀번호 전달
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('계정이 삭제되었습니다.')),
        );
        await prefs.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('계정 삭제에 실패하였습니다.')),
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
          title: Text('아이디 변경'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: '새 아이디'),
              ),
              TextField(
                controller: _currentPasswordController,
                decoration: InputDecoration(labelText: '현재 비밀번호'),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (_currentPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('현재 비밀번호를 입력해야 합니다.')),
                  );
                  return;
                }
                _updateUser(
                  newUsername: _usernameController.text,
                  currentPassword: _currentPasswordController.text,
                );
                Navigator.of(context).pop();
              },
              child: Text('변경'),
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
          title: Text('비밀번호 변경'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _currentPasswordController,
                decoration: InputDecoration(labelText: '현재 비밀번호'),
                obscureText: true,
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: '새 비밀번호'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: '새 비밀번호 확인'),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (_passwordController.text == _confirmPasswordController.text) {
                  _updateUser(
                    newPassword: _passwordController.text,
                    currentPassword: _currentPasswordController.text,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('비밀번호가 일치하지 않습니다')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('변경'),
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
          title: Text('로그아웃'),
          content: Text('로그아웃 하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _logout();
                Navigator.of(context).pop();
              },
              child: Text('로그아웃'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountConfirmationDialog() {
    TextEditingController _passwordConfirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('계정 삭제'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('계정을 삭제하려면 비밀번호를 입력하십시오. 이 작업은 되돌릴 수 없습니다.'),
              SizedBox(height: 10),
              TextField(
                controller: _passwordConfirmController,
                decoration: InputDecoration(labelText: '비밀번호 입력'),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (_passwordConfirmController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('비밀번호를 입력해야 합니다.')),
                  );
                  return;
                }
                _deleteAccount(_passwordConfirmController.text); // 비밀번호 전달
                Navigator.of(context).pop();
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  // 버튼 스타일 지정
  final ButtonStyle commonButtonStyle = TextButton.styleFrom(
    textStyle: TextStyle(
      fontSize: 16,
      fontFamily: 'SUIT',
      fontWeight: FontWeight.w500,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$username님',
              style: TextStyle(
                fontFamily: 'SUIT',
                fontWeight: FontWeight.w800,
                fontSize: 35,
              ),
            ),
            SizedBox(height: 15.0,),
            Divider(thickness: 1, color: Colors.grey),
            TextButton(
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
                ).then((value) {
                  _fetchUserData();
                });
              },
              style: commonButtonStyle,
              child: Text(nfcCardId.isEmpty ? '카드 연동' : '카드 연동 해지'),
            ),
            Divider(thickness: 1, color: Colors.grey),
            TextButton(
              onPressed: isSuspended ? _showSuspendedMessage : _showUpdateUsernameDialog,
              style: commonButtonStyle,
              child: Text('아이디 변경'),
            ),
            TextButton(
              onPressed: isSuspended ? _showSuspendedMessage : _showUpdatePasswordDialog,
              style: commonButtonStyle,
              child: Text('비밀번호 변경'),
            ),
            Divider(thickness: 1, color: Colors.grey),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TermsPage()),
                );
              },
              style: commonButtonStyle,
              child: Text('이용약관'),
            ),
            TextButton(
              onPressed: _showLogoutConfirmationDialog,
              style: commonButtonStyle,
              child: Text('로그아웃'),
            ),
            TextButton(
              onPressed: isSuspended ? _showSuspendedMessage : _showDeleteAccountConfirmationDialog,
              style: commonButtonStyle,
              child: Text('탈퇴하기'),
            ),
          ],
        ),
      ),
    );
  }
}
