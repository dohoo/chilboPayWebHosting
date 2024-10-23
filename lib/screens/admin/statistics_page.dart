import 'package:flutter/material.dart';
import 'transactions_page.dart';
import '../../services/admin_api.dart'; // AdminApi import

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
      final totalMoney = await AdminApi.fetchTotalUserMoney(); // AdminApi 사용
      setState(() {
        _totalUserMoney = totalMoney;
      });
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
