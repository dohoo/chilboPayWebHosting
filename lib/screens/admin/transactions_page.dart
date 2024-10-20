import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

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
      final response = await ApiService.makeAuthenticatedRequest(
        context,
            (accessToken) {
          return http.get(
            Uri.parse('http://114.204.195.233/transactions'),
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          );
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          transactions = data;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load transactions: ${response.statusCode} - ${response.body}';
        });
        print('Error: ${response.statusCode} - ${response.body}');
      }
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