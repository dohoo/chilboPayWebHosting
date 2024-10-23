import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_api.dart'; // AdminApi import

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List transactions = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final data = await AdminApi.fetchTransactions(); // AdminApi 사용
      setState(() {
        transactions = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
      print('Exception: $e');
    }
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
            ? ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final int amount = (double.parse(transaction['amount'].toString())).toInt(); // Convert amount to int
            return ListTile(
              title: Text('${transaction['sender']} -> ${transaction['receiver']}'),
              subtitle: Text(formatDate.format(DateTime.parse(transaction['date']))),
              trailing: Text(
                formatCurrency.format(amount),
                style: TextStyle(
                  color: amount < 0 ? Colors.red : Colors.green,
                ),
              ),
            );
          },
        )
            : Text(_errorMessage),
      ),
    );
  }
}
