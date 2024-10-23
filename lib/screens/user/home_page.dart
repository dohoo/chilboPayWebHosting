import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../services/user_api.dart';
import '../login/login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';
  int money = 0;
  List transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchTransactions();
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      _logout();
      return;
    }

    try {
      final userData = await UserApi.fetchUserData(userId);
      setState(() {
        username = userData['username'];
        money = (userData['money'] as num).toInt(); // Convert to int
      });
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    }
  }

  Future<void> _fetchTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      _logout();
      return;
    }

    try {
      final transactionData = await UserApi.fetchTransactions(userId);
      setState(() {
        transactions = transactionData;
      });
    } catch (e) {
      print('Error fetching transactions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load transactions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat("#,##0", "en_US");
    final formatDate = DateFormat("yyyy-MM-dd HH:mm:ss");

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Username'),
            subtitle: Text(username),
          ),
          ListTile(
            title: Text('Money'),
            subtitle: Text(formatCurrency.format(money)),
          ),
          Expanded(
            child: ListView.builder(
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
            ),
          ),
        ],
      ),
    );
  }
}
