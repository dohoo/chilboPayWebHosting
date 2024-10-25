import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_api.dart'; // UserApi 클래스 import

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  List transactions = [];
  int itemsToShow = 10; // 초기 표시 개수

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID not found')),
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
        SnackBar(content: Text('Failed to load transactions: $e')),
      );
    }
  }

  void _loadMore() {
    setState(() {
      itemsToShow += 10; // 표시 개수를 10개씩 증가
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: transactions.isEmpty
                  ? Center(child: Text('No transaction history available'))
                  : ListView.builder(
                itemCount: itemsToShow < transactions.length ? itemsToShow : transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final String sender = transaction['sender'];
                  final String receiver = transaction['receiver'];
                  final double amount = transaction['amount'];
                  final String date = transaction['date'];

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
            if (itemsToShow < transactions.length)
              ElevatedButton(
                onPressed: _loadMore,
                child: Text('Load More'),
              ),
          ],
        ),
      ),
    );
  }
}
