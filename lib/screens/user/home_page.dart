import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../services/user_api.dart';
import '../login/login_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String username = '';
  int money = 0;
  String qrData = '';
  Timer? _timer;
  int remainingTime = 60;
  bool _needsQrRefresh = false; // HomePage로 돌아올 때 QR 갱신이 필요한지 추적
  bool isPageActive = true; // 페이지가 활성화된 상태인지 추적
  bool isSuspended = false; // 정지 상태 여부

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadQrData();
    _startQrTimer(); // 타이머 시작
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // HomePage로 돌아올 때 QR을 갱신하고 계좌 정보도 리로드
  void onReturnToHomePage() {
    isPageActive = true;
    if (_needsQrRefresh && !isSuspended) {
      _generateQrCode();
      _needsQrRefresh = false;
    }
    _fetchUserData(); // 계좌 정보 갱신
  }

  // HomePage에서 벗어날 때
  void onLeaveHomePage() {
    isPageActive = false;
  }

  Future<void> refreshData() async {
    await _fetchUserData();
    if (!isSuspended) {
      await _checkQrCode();
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
        isSuspended = userData['status'] == 'suspended';
      });

      if (!isSuspended) {
        await _loadQrData();
        _startQrTimer();
      } else {
        // 정지 상태일 경우 QR 타이머 및 생성 중지
        _timer?.cancel();
      }
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    }
  }

  Future<void> _loadQrData() async {
    if (isSuspended) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedQrData = prefs.getString('qrData') ?? '';
    final lastGeneratedTime = prefs.getInt('lastQrGeneratedTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (savedQrData.isNotEmpty && (currentTime - lastGeneratedTime) < 60000) {
      setState(() {
        qrData = savedQrData;
        remainingTime = 60 - ((currentTime - lastGeneratedTime) ~/ 1000);
      });
    } else {
      await _generateQrCode();
    }
  }

  Future<void> _checkQrCode() async {
    if (isSuspended) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastGeneratedTime = prefs.getInt('lastQrGeneratedTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if ((currentTime - lastGeneratedTime) >= 60000) {
      await _generateQrCode();
    }
  }

  Future<void> _generateQrCode() async {
    if (isSuspended) return;
    try {
      final userId = await SharedPreferences.getInstance().then((prefs) => prefs.getInt('userId'));
      if (userId == null) return;

      final token = await UserApi.generateQrToken(userId);
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      setState(() {
        qrData = token;
        remainingTime = 60;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('qrData', token);
      await prefs.setInt('lastQrGeneratedTime', currentTime);
    } catch (e) {
      print('Error generating QR token: $e');
    }
  }

  void _startQrTimer() {
    _timer?.cancel();
    if (isSuspended) return;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 1) {
          remainingTime -= 1;
        } else {
          remainingTime = 60;
          if (isPageActive && !isSuspended) {
            _generateQrCode(); // 페이지가 활성화 상태일 때 즉시 갱신
          } else {
            _needsQrRefresh = true; // 페이지 비활성 시 갱신 플래그
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat("#,##0", "en_US");
    final formattedMoney = "${formatCurrency.format(money)}P";

    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Center(
              child: isSuspended
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, size: 100, color: Colors.red),
                  SizedBox(height: 20),
                  Text(
                    '계정이 정지되었습니다.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.all(10),
                  ),
                  SizedBox(height: 10),
                  Text('$remainingTime초 뒤 재생성'),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFB8EA92),
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '내 계좌',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh, color: Colors.black),
                          onPressed: refreshData,
                          tooltip: 'Refresh Account Info',
                        ),
                      ],
                    ),
                    Text(
                      '$username님',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    formattedMoney,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
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
