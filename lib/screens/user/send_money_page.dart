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

  Future<void> _sendMoney() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final senderId = prefs.getInt('userId');
    final receiverUsername = _receiverController.text;
    final amount = int.parse(_amountController.text);

    try {
      // 송신자 정보 가져오기
      final senderData = await UserApi.fetchUserData(senderId!);
      if (senderData['status'] == 'suspended') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Your account is suspended')),
        );
        return;
      }

      // 수신자 정보 가져오기
      final receiverData = await UserApi.fetchUserDataByUsername(receiverUsername);
      if (receiverData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receiver not found')),
        );
        return;
      }
      final receiverId = receiverData['id'];

      // 트랜잭션 생성 with type "transfer"
      final transactionResponse = await UserApi.createTransaction(
          senderId,
          receiverId,
          amount.toDouble(),
          type: 'transfer' // Specify type as "transfer"
      );

      if (transactionResponse) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction successful')),
        );
        _receiverController.clear();
        _amountController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction failed')),
        );
      }
    } catch (e) {
      print('An error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Money'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
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
            SizedBox(height: 150),
            SizedBox(
              width: double.infinity, // 버튼 너비를 화면 전체로 설정
              child: TextButton(
                onPressed: _sendMoney,
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFB8EA92), // 버튼 배경색 설정
                  padding: EdgeInsets.symmetric(vertical: 16.0), // 버튼 높이 설정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11.0), // 버튼 모서리 둥글게 설정
                  ),
                ),
                child: Text(
                  '송금하기',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black, // 텍스트 색상 설정
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
