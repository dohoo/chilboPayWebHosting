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
    try {
      final data = await LoginApi.login(  // LoginApi 사용
        _usernameController.text,
        _passwordController.text,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', data['role']);  // 로그인 후 역할 저장
      await prefs.setInt('userId', data['id']);  // 로그인 후 사용자 ID 저장

      _navigateToRolePage(data['role']);
    } catch (e) {
      print('An error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  void _navigateToRolePage(String role) {
    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPage()),
      );
    } else if (role == 'festival') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FestivalPage()),  // Navigate to FestivalPage
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
    return Scaffold(
      backgroundColor: Color(0xFFF2F4F0),  // 배경 색상 변경
      body: Padding(
        padding: EdgeInsets.all(16.0),
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

            Spacer(
                flex: 1
            ),

            Text(
              '반갑습니다.',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontFamily: 'SUIT-ExtraLight',
                fontSize: 25.0,
              ),
            ),
            SizedBox(height: 40.0),  // 반갑습니다와 ID 사이 간격 추가
            Align(
              alignment: Alignment.center,  // ID와 입력란을 모두 중앙 정렬
              child: FractionallySizedBox(
                widthFactor: 0.8,  // 부모 너비의 80%로 설정
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,  // 텍스트를 입력란에 맞춰 왼쪽 정렬
                  children: [
                    Text(
                      'ID',
                      style: TextStyle(
                        fontFamily: 'SUIT-ExtraLight',
                        fontSize: 18.0,
                      ),
                    ),
                    TextField(
                      cursorColor: Colors.black, // 커서 색상 변경
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: '',
                        // 만약 hover 상태의 색을 변경하고 싶으면 아래처럼 설정
                        hoverColor: Colors.black,  // 마우스 hover 시 색상
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Spacer(flex: 2),

            Align(
              alignment: Alignment.center,  // PASSWORD와 입력란을 모두 중앙 정렬
              child: FractionallySizedBox(
                widthFactor: 0.8,  // 부모 너비의 80%로 설정
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,  // 텍스트를 입력란에 맞춰 왼쪽 정렬
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
                      cursorColor: Colors.black, // 커서 색상 변경
                      decoration: InputDecoration(
                        labelText: '',
                        hoverColor: Colors.black,  // 마우스 hover 시 색상
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),

// '처음이신가요?' 버튼을 입력란과 맞춰서 오른쪽 정렬
            Align(
              alignment: Alignment.center,  // 입력란과 같은 80% 너비로 정렬
              child: FractionallySizedBox(
                widthFactor: 0.8,  // 입력란과 동일한 부모 너비의 80%로 설정
                child: Align(
                  alignment: Alignment.centerRight,  // 오른쪽 정렬
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
                        color: Colors.black,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),

            Spacer(
              flex: 4,
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity, // 버튼을 화면 가로 길게 설정
                child: TextButton(
                  onPressed: _login,
                  child: Text(
                    '시작하기',
                    style: TextStyle(
                      fontFamily: 'SUIT-Light',
                      fontSize: 20.0,
                      color: Colors.black, // 글자 색 검정으로 변경
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFB8EA92), // 버튼 배경 색상 B8EA92로 설정
                    padding: EdgeInsets.symmetric(vertical: 16.0), // 버튼 높이 조정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.0), // 버튼 굴곡 설정
                    ),
                    elevation: 8.0, // 그림자 높이 설정
                    shadowColor: Colors.black.withOpacity(1), // 그림자 색상 및 투명도 설정
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
