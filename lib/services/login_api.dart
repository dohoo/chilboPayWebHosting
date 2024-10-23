import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginApi {
  static const String baseUrl = 'http://114.204.195.233';

  // 로그인 요청을 처리하는 메서드
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed: Invalid credentials');
    }
  }

  // 회원가입 요청을 처리하는 메서드
  static Future<http.Response> signUp(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'role': 'user',
      }),
    );

    return response;
  }
}
