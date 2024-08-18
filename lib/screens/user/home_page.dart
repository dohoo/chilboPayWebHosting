import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

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

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      await ApiService.logout(context);
      return;
    }

    try {
      final response = await ApiService.makeAuthenticatedRequest(
        context,
            (accessToken) {
          return http.get(
            Uri.parse('https://chilbopay.com/user/$userId'),
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          );
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          username = data['username'];
          money = (data['money'] as num).toInt(); // Convert to int
        });
      } else {
        print('Failed to load user data: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data')),
        );
      }
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
      await ApiService.logout(context);
      return;
    }

    try {
      final response = await ApiService.makeAuthenticatedRequest(
        context,
            (accessToken) {
          return http.get(
            Uri.parse('https://chilbopay.com/transactions/$userId'),
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
        print('Failed to load transactions: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load transactions')),
        );
      }
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
