import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_api.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List transactions = [];
  String _errorMessage = '';
  int itemsToShow = 10; // 처음에는 10개만 보여줌

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final data = await AdminApi.fetchTransactions();
      setState(() {
        transactions = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  void _loadMore() {
    setState(() {
      itemsToShow += 10; // 더보기 버튼 클릭 시 10개씩 추가 로드
    });
  }

  // UTC 시간을 KST로 변환하는 함수
  DateTime _convertToKST(String utcDateString) {
    DateTime utcDateTime = DateTime.parse(utcDateString);
    return utcDateTime.add(Duration(hours: -9)); // UTC에 9시간 추가해 KST로 변환
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat("#,##0", "en_US");
    final formatDate = DateFormat("yyyy-MM-dd HH:mm:ss");

    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: Center(
        child: _errorMessage.isEmpty
            ? Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: itemsToShow < transactions.length ? itemsToShow : transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];

                  // 필드 누락 시 '알 수 없음'으로 표시
                  final String sender = transaction['sender']?.toString() ?? '알 수 없음';
                  final String receiver = transaction['receiver']?.toString() ?? '알 수 없음';

                  // 금액을 안전하게 변환
                  final int amount = (double.parse(transaction['amount'].toString())).toInt();

                  // UTC 날짜 문자열을 DateTime으로 변환 후 KST로 변환
                  final DateTime kstDate = _convertToKST(transaction['date']);

                  return ListTile(
                    title: Text('$sender -> $receiver'),
                    subtitle: Text(formatDate.format(kstDate)), // 한국 시간대로 변환된 시간 표시
                    trailing: Text(
                      formatCurrency.format(amount),
                      style: TextStyle(
                        color: amount < 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  );
                },
              ),
            ),
            if (itemsToShow < transactions.length) // 더보기 버튼 조건부 렌더링
              TextButton(
                onPressed: _loadMore,
                child: Text("더 보기"),
              ),
          ],
        )
            : Text(_errorMessage),
      ),
    );
  }
}
