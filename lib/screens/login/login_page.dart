import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_page.dart';
import '../admin/admin_page.dart';
import '../user/user_page.dart';
import '../festival/festival_page.dart'; // Import the festival page
import '../../services/login_api.dart'; // Import LoginApi

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();  // 앱 시작 시 로그인 상태 확인
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');  // 로컬에 저장된 역할 확인

    if (role != null) {
      _navigateToRolePage(role);  // 이미 로그인된 경우 해당 역할 페이지로 이동
    }
  }

  Future<void> _login() async {
    setState(() {
      _errorMessage = null; // 로그인 시도 전에 오류 메시지 초기화
    });

    try {
      final data = await LoginApi.login(  // LoginApi 사용
        _usernameController.text,
        _passwordController.text,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', data['role']);  // 로그인 후 역할 저장
      await prefs.setInt('userId', data['id']);  // 로그인 후 사용자 ID 저장
      if (data['role'] == 'festival') {
        await prefs.setInt('festivalId', data['id']);  // festivalId 저장
      }

      _navigateToRolePage(data['role']);
    } catch (e) {
      setState(() {
        _errorMessage = '로그인에 실패하였습니다. 다시 시도해주세요.'; // 오류 메시지 설정
      });
    }
  }

  void _navigateToRolePage(String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int festivalId = prefs.getInt('festivalId') ?? 0;

    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPage()),
      );
    } else if (role == 'festival') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FestivalPage(id: festivalId)),  // FestivalPage에 id 전달
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  // 배경 색상 변경
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'CHILBO ',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: 'SUIT-Regular',
                        fontSize: 30.0,
                        color: Color(0xFF3C3C3C),
                      ),
                    ),
                    TextSpan(
                      text: 'PAY',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'SUIT-ExtraBold',
                        fontSize: 30.0,
                        color: Color(0xFF3C3C3C),
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(flex: 1),
              Text(
                '반갑습니다.',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontFamily: 'SUIT-ExtraLight',
                  fontSize: 25.0,
                ),
              ),
              SizedBox(height: 40.0),
              Align(
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID',
                        style: TextStyle(
                          fontFamily: 'SUIT-ExtraLight',
                          fontSize: 18.0,
                        ),
                      ),
                      TextField(
                        cursorColor: Colors.black,
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: '',
                          hoverColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Spacer(flex: 2),
              Align(
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PASSWORD',
                        style: TextStyle(
                          fontFamily: 'SUIT-ExtraLight',
                          fontSize: 18.0,
                        ),
                      ),
                      TextField(
                        controller: _passwordController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          labelText: '',
                          hoverColor: Colors.black,
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      child: Text(
                        '처음이신가요?',
                        style: TextStyle(
                          fontFamily: 'SUIT-ExtraLight',
                          fontSize: 15.0,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
              Spacer(flex: 1),
              if (_errorMessage != null) // 오류 메시지가 있을 때만 표시
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: 'SUIT-Light',
                      fontSize: 14.0,
                    ),
                  ),
                ),
              Spacer(flex: 3),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _login,
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFFB8EA92), // 버튼 배경색
                      padding: EdgeInsets.symmetric(vertical: 16.0), // 버튼 높이 조정
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // 버튼 모서리 둥글게
                      ),
                    ),
                    child: Text(
                      '시작하기',
                      style: TextStyle(
                        fontFamily: 'SUIT-Light',
                        fontSize: 16.0, // 텍스트 크기 증가
                        color: Colors.black, // 텍스트 색상
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}