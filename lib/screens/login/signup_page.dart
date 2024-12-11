import 'package:flutter/material.dart';
import '../../services/login_api.dart'; // LoginApi import
import 'terms_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;
  String? _message;
  Color _messageColor = Colors.red;

  Future<void> _signUp() async {
    setState(() {
      _message = null; // Reset the message on each attempt
    });

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _message = '비밀번호가 일치하지 않습니다.';
        _messageColor = Colors.red;
      });
      return;
    }

    if (!_termsAccepted) {
      setState(() {
        _message = '이용약관을 읽고 체크표시를 해주세요.';
        _messageColor = Colors.red;
      });
      return;
    }

    try {
      final response = await LoginApi.signUp(
        _usernameController.text,
        _passwordController.text,
      );

      if (response.statusCode == 201) {
        _showFadingMessage('회원가입 완료!');
        Navigator.pop(context);
      } else if (response.statusCode == 409) {
        setState(() {
          _message = 'ID가 이미 존재합니다.';
          _messageColor = Colors.red;
        });
      } else {
        setState(() {
          _message = '회원가입에 실패하였습니다.';
          _messageColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _message = '예기치 못한 문제가 발생하였습니다. 다시 시도해주세요: $e';
        _messageColor = Colors.red;
      });
    }
  }

  void _showFadingMessage(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50.0,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: 500),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              alignment: Alignment.center,
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
    overlay?.insert(overlayEntry);

    Future.delayed(Duration(seconds: 1), () {
      overlayEntry.markNeedsBuild();
      Future.delayed(Duration(milliseconds: 500), () {
        overlayEntry.remove();
      });
    });
  }

  void _navigateToTermsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TermsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'ID',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Checkbox(
                  value: _termsAccepted,
                  onChanged: (bool? value) {
                    setState(() {
                      _termsAccepted = value ?? false;
                    });
                  },
                ),
                GestureDetector(
                  onTap: _navigateToTermsPage,
                  child: Text(
                    '이용약관에 동의합니다.(필수)',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 11.0,
                      decoration: TextDecoration.underline, // 밑줄 추가
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              style: Theme.of(context).elevatedButtonTheme.style,
              child: Text('가입하기'),
            ),
            if (_message != null) ...[
              SizedBox(height: 10),
              Text(
                _message!,
                style: TextStyle(color: _messageColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}