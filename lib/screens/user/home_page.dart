import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../services/user_api.dart';
import '../login/login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';
  int money = 0;
  String qrData = '';
  Timer? _timer;
  int remainingTime = 60;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadQrData(); // QR 데이터를 SharedPreferences에서 로드
    _startQrTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      _logout();
      return;
    }

    try {
      final userData = await UserApi.fetchUserData(userId);
      setState(() {
        username = userData['username'];
        money = (userData['money'] as num).toInt();
      });
      await _checkQrCode(userId); // username이 로드된 후 QR 코드 체크
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    }
  }

  Future<void> _loadQrData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedQrData = prefs.getString('qrData') ?? '';
    final lastGeneratedTime = prefs.getInt('lastQrGeneratedTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (savedQrData.isNotEmpty && (currentTime - lastGeneratedTime) < 60000) {
      setState(() {
        qrData = savedQrData;
        remainingTime = 60 - ((currentTime - lastGeneratedTime) ~/ 1000);
      });
    }
  }

  Future<void> _checkQrCode(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastGeneratedTime = prefs.getInt('lastQrGeneratedTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if ((currentTime - lastGeneratedTime) >= 60000) {
      await _generateQrCode(userId); // 60초 이상 경과 시 새로 QR 생성
    } else {
      setState(() {
        remainingTime = 60 - ((currentTime - lastGeneratedTime) ~/ 1000);
      });
    }
  }

  Future<void> _generateQrCode(int userId) async {
    try {
      final token = await UserApi.generateQrToken(userId); // 서버에서 토큰 생성 요청
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      setState(() {
        qrData = token;
        remainingTime = 60;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('qrData', token); // QR 데이터를 저장
      await prefs.setInt('lastQrGeneratedTime', currentTime); // 생성 시간 기록
    } catch (e) {
      print('Error generating QR token: $e');
    }
  }

  void _startQrTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 1) {
          remainingTime -= 1;
        } else {
          _timer?.cancel(); // 기존 타이머 중지
          _refreshQrCode(); // QR 코드 갱신
        }
      });
    });
  }

  Future<void> _refreshQrCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      await _generateQrCode(userId); // 새 QR 코드 생성
      _startQrTimer(); // 타이머 초기화 후 재시작
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat("#,##0", "en_US");
    final formattedMoney = "${formatCurrency.format(money)}P";

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  SizedBox(height: 10),
                  Text('QR code refreshes in $remainingTime seconds'),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '내 계좌',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      username,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    formattedMoney,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
