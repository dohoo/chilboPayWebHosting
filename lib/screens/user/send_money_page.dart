import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_api.dart';
import 'package:flutter/services.dart';
import '../no_negative_number_formatter.dart';

class SendMoneyPage extends StatefulWidget {
  @override
  _SendMoneyPageState createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  int? _currentMoney;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserMoney();
  }

  Future<void> _fetchCurrentUserMoney() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final senderId = prefs.getInt('userId');
    if (senderId != null) {
      try {
        final senderData = await UserApi.fetchUserData(senderId);
        setState(() {
          _currentMoney = senderData['money'] ?? 0;
        });
      } catch (e) {
        setState(() {
          _message = '현재 잔액을 불러오는 데 실패했습니다.';
        });
      }
    }
  }

  Future<void> _sendMoney() async {
    setState(() {
      _message = '';
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final senderId = prefs.getInt('userId');
    final receiverUsername = _receiverController.text;

    if (_amountController.text.isEmpty) {
      setState(() {
        _message = '금액을 입력해주세요.';
      });
      return;
    }

    final amount = int.parse(_amountController.text);

    try {
      // 송신자 정보 가져오기
      final senderData = await UserApi.fetchUserData(senderId!);
      if (senderData['status'] == 'suspended') {
        setState(() {
          _message = '계정이 정지되었습니다.';
        });
        return;
      }

      // 수신자 정보 가져오기
      final receiverData = await UserApi.fetchUserDataByUsername(receiverUsername);
      if (receiverData == null) {
        setState(() {
          _message = '받는 사람을 찾을 수 없습니다.';
        });
        return;
      }
      final receiverId = receiverData['id'];

      // 트랜잭션 생성 with type "transfer"
      final transactionResponse = await UserApi.createTransaction(
        senderId,
        receiverId,
        amount.toDouble(),
        type: 'transfer',
      );

      if (transactionResponse) {
        setState(() {
          _message = '송금이 완료되었습니다.';
          _receiverController.clear();
          _amountController.clear();
        });
        // 성공 후 잔액 업데이트
        await _fetchCurrentUserMoney();
      } else {
        setState(() {
          _message = '송금에 실패했습니다.';
        });
      }
    } catch (e) {
      print('An error occurred: $e');
      setState(() {
        _message = '오류가 발생했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // 현재 잔액 표시
            if (_currentMoney != null)
              Text(
                '현재 잔액: $_currentMoney',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

            SizedBox(height: 100),
            TextField(
              controller: _receiverController,
              decoration: InputDecoration(labelText: '받는 사람'),
            ),
            SizedBox(height: 50),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: '금액'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                NoNegativeNumberFormatter(),
              ],
            ),
            SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _sendMoney,
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFB8EA92),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11.0),
                  ),
                ),
                child: Text(
                  '송금하기',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            // 메시지 표시 (빨간색)
            // 메시지 표시
            if (_message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _message,
                  style: TextStyle(
                    color: _message == '송금이 완료되었습니다.' ? Colors.black : Colors.red,
                    fontSize: 16.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
