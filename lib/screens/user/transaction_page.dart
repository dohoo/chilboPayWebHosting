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
  int itemsToShow = 10; // 초기 표시 개수

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  // 데이터를 새로 불러오는 메서드 추가
  Future<void> refreshData() async {
    await _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID를 찾을 수 없습니다.')),
      );
      return;
    }

    try {
      final data = await UserApi.fetchTransactions(userId);
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
      itemsToShow += 10; // 표시 개수를 10개씩 증가
    });
  }

  String _formatDate(String utcDate) {
    try {
      DateTime dateTime = DateTime.parse(utcDate).add(Duration(hours: -9)); // KST 시간대로 변환
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime); // 원하는 형식으로 날짜 포맷팅
    } catch (e) {
      return utcDate; // 변환 실패 시 원본 반환
    }
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
                onRefresh: _fetchTransactions, // 아래로 당길 때 거래 내역 새로고침
                child: transactions.isEmpty
                    ? Center(child: Text('거래 내역이 없습니다.'))
                    : ListView.builder(
                  itemCount: itemsToShow < transactions.length ? itemsToShow : transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final String sender = transaction['sender'] == null ? '알 수 없음' : transaction['sender'].toString();
                    final String receiver = transaction['receiver'] == null ? '알 수 없음' : transaction['receiver'].toString();
                    final String date = _formatDate(transaction['date']); // 한국 시간으로 포맷

                    // amount를 안전하게 double로 변환
                    double amount;
                    try {
                      amount = double.parse(transaction['amount'].toString());
                    } catch (e) {
                      amount = 0.0; // 변환 실패 시 기본값 사용
                    }

                    return ListTile(
                      title: Text('$sender → $receiver'),
                      subtitle: Text(date),
                      trailing: Text(
                        '${amount.toStringAsFixed(2)} P',
                        style: TextStyle(
                          color: amount < 0 ? Colors.red : Colors.green,
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
