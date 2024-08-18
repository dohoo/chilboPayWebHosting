import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'transactions_page.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _totalUserMoney = 0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchTotalUserMoney();
  }

  Future<void> fetchTotalUserMoney() async {
    try {
      final response = await http.get(Uri.parse('https://chilbopay.com/totalUserMoney'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _totalUserMoney = int.parse(jsonResponse['total']); // 문자열을 정수로 변환
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load statistics';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _errorMessage.isEmpty
                ? Text('Total money of users: $_totalUserMoney')
                : Text(_errorMessage),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransactionsPage()),
                );
              },
              child: Text('View Transactions'),
            ),
          ],
        ),
      ),
    );
  }
}
