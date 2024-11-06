import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_api.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  TransactionPage({Key? key}) : super(key: key);

  @override
  TransactionPageState createState() => TransactionPageState();
}

class TransactionPageState extends State<TransactionPage> {
  List transactions = [];
  int itemsToShow = 10;
  int? userId; // userId를 클래스 변수로 선언

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> refreshData() async {
    await _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId'); // userId를 클래스 변수에 저장

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID를 찾을 수 없습니다.')),
      );
      return;
    }

    try {
      final data = await UserApi.fetchTransactions(userId!);
      setState(() {
        transactions = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('거래 내역을 불러올 수 없습니다: $e')),
      );
    }
  }

  void _loadMore() {
    setState(() {
      itemsToShow += 10;
    });
  }

  String _formatDate(String utcDate) {
    try {
      DateTime dateTime = DateTime.parse(utcDate).add(Duration(hours: -9));
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    } catch (e) {
      return utcDate;
    }
  }

  String _getAmountDisplay(double amount, String type, bool isFestivalSender, bool isAdminSender, bool isFestivalReceiver, bool isAdminReceiver) {
    String prefix = '';

    // Only add prefix if the type is not 'admin'
    if (type != 'admin') {
      if (isFestivalSender || isAdminSender) {
        prefix = '+';
      } else if (isFestivalReceiver || isAdminReceiver) {
        prefix = '-';
      }
    }

    return '[$type] $prefix${amount.toStringAsFixed(0)} P';  // Remove decimal places
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('거래 내역'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchTransactions,
                child: transactions.isEmpty
                    ? Center(child: Text('거래 내역이 없습니다.'))
                    : ListView.builder(
                  itemCount: itemsToShow < transactions.length ? itemsToShow : transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final String sender = transaction['sender'] ?? '알 수 없음';
                    final String receiver = transaction['receiver'] ?? '알 수 없음';
                    final String date = _formatDate(transaction['date']);

                    // amount 변환
                    double amount;
                    try {
                      amount = double.parse(transaction['amount'].toString());
                    } catch (e) {
                      amount = 0.0;
                    }

                    // festival 및 admin 역할 확인
                    bool isFestivalSender = transaction['senderRole'] == 'festival';
                    bool isAdminSender = transaction['senderRole'] == 'admin';
                    bool isFestivalReceiver = transaction['receiverRole'] == 'festival';
                    bool isAdminReceiver = transaction['receiverRole'] == 'admin';

                    // type 가져오기
                    String type = transaction['type'] ?? 'N/A';

                    // 역할 및 금액 방향에 따른 표시 설정
                    String amountDisplay = _getAmountDisplay(amount, type, isFestivalSender, isAdminSender, isFestivalReceiver, isAdminReceiver);

                    return ListTile(
                      title: Text('$sender → $receiver'),
                      subtitle: Text(date),
                      trailing: Text(
                        amountDisplay,
                        style: TextStyle(
                          color: amountDisplay.contains('-') ? Colors.red : Colors.green,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (itemsToShow < transactions.length)
              ElevatedButton(
                onPressed: _loadMore,
                child: Text('더 보기'),
              ),
          ],
        ),
      ),
    );
  }
}
