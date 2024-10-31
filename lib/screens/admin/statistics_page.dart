import 'package:flutter/material.dart';
import 'transactions_page.dart';
import '../../services/admin_api.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _totalUserMoney = 0;
  int _totalFestivalMoney = 0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchTotalMoney();
  }

  Future<void> fetchTotalMoney() async {
    try {
      final totals = await AdminApi.fetchTotalMoney();
      setState(() {
        _totalUserMoney = int.parse(totals['totalUserMoney'].toString());
        _totalFestivalMoney = int.parse(totals['totalFestivalMoney'].toString());
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
                ? Column(
              children: [
                Text('Total money of users: $_totalUserMoney'),
                Text('Total money of festivals: $_totalFestivalMoney'),
              ],
            )
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
