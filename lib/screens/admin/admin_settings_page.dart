import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/admin_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login_page.dart';
import 'product_add_page.dart';

class AdminSettingsPage extends StatefulWidget {
  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> activities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _showCreateAccountDialog(context, 'user'),
              child: Text('학생 계정 만들기'),
            ),
            ElevatedButton(
              onPressed: () => _showCreateAccountDialog(context, 'festival'),
              child: Text('동아리 계정 만들기'),
            ),
            ElevatedButton(
              onPressed: () => _showChangePasswordDialog(context),
              child: Text('비밀번호 변경'),
            ),
            ElevatedButton(
              onPressed: () => _showLogoutConfirmationDialog(context),
              child: Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그아웃'),
          content: Text('로그아웃 하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _logout(context);
                Navigator.of(context).pop();
              },
              child: Text('로그아웃'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃에 실패하였습니다.')),
      );
    }
  }

  Future<void> _showCreateAccountDialog(BuildContext context, String accountType) async {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final moneyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${accountType == 'user' ? '학생' : '동아리'} 계정 만들기'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'ID'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: moneyController,
                  decoration: InputDecoration(labelText: '포인트'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                if (accountType == 'festival') ...[
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductAddPage(
                            existingProducts: products,
                            existingActivities: activities,
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          products = result['products'];
                          activities = result['activities'];
                        });
                      }
                    },
                    child: Text('상품/활동 추가하기'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('만들기'),
              onPressed: () {
                if (passwordController.text == confirmPasswordController.text) {
                  _createAccount(
                    accountType,
                    usernameController.text,
                    passwordController.text,
                    int.parse(moneyController.text),
                    products,
                    activities,
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _createAccount(
      String accountType,
      String username,
      String password,
      int money,
      List<Map<String, dynamic>> products,
      List<Map<String, dynamic>> activities,
      ) async {
    try {
      await AdminApi.createAccount(accountType, username, password, money, products, activities);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('계정이 생성되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('계정을 만드는 데 실패하였습니다.: $e')),
      );
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmNewPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('비밀번호 변경'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: InputDecoration(labelText: '기존 비밀번호'),
                obscureText: true,
              ),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: '새로운 비밀번호'),
                obscureText: true,
              ),
              TextField(
                controller: confirmNewPasswordController,
                decoration: InputDecoration(labelText: '비밀번호 확인'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('변경'),
              onPressed: () {
                if (newPasswordController.text == confirmNewPasswordController.text) {
                  _changePassword(oldPasswordController.text, newPasswordController.text);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('비밃번호가 일치하지 않습니다.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _changePassword(String oldPassword, String newPassword) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId'); // userId 가져오기

      if (userId == null) {
        throw Exception('ID를 찾을 수 없습니다.');
      }

      await AdminApi.changePassword(userId, oldPassword, newPassword); // userId 전달
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호 변경 완료')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호 변경 실패: ${e.toString()}')),
      );
    }
  }
}
