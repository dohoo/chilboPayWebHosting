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
        _errorMessage = ''; // Clear any previous error
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
      body: RefreshIndicator(
        onRefresh: fetchTotalMoney, // Trigger data refresh on pull
        child: Center(
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              _errorMessage.isEmpty
                  ? Column(
                children: [
                  Text('Total money of users: $_totalUserMoney'),
                  SizedBox(height: 10),
                  Text('Total money of festivals: $_totalFestivalMoney'),
                ],
              )
                  : Center(
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
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
      ),
    );
  }
}
