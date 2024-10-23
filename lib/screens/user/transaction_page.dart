import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import '../no_negative_number_formatter.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  Future<void> _sendMoney() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final senderId = prefs.getInt('userId');
    final receiverUsername = _receiverController.text;
    final amount = int.parse(_amountController.text);

    try {
      // Fetch sender information
      final senderResponse = await http.get(
        Uri.parse('http://114.204.195.233/user/$senderId'),
      );

      if (senderResponse.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sender not found')),
        );
        return;
      }

      final senderData = jsonDecode(senderResponse.body);
      if (senderData['status'] == 'suspended') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Your account is suspended')),
        );
        return;
      }

      // Fetch receiver information
      final receiverResponse = await http.get(
        Uri.parse('http://114.204.195.233/user/by-username/$receiverUsername'),
      );

      if (receiverResponse.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receiver not found')),
        );
        return;
      }

      final receiverData = jsonDecode(receiverResponse.body);
      final receiverId = receiverData['id'];

      // Perform the transaction
      final response = await http.post(
        Uri.parse('http://114.204.195.233/transaction'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'senderId': senderId,
          'receiverId': receiverId,
          'amount': amount.toDouble(),
        }),
      );

      print('Server response: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction successful')),
        );
        _receiverController.clear();
        _amountController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction failed')),
        );
      }
    } catch (e) {
      print('An error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _receiverController,
              decoration: InputDecoration(labelText: 'Receiver Username'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                NoNegativeNumberFormatter(),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendMoney,
              child: Text('Send Money'),
            ),
          ],
        ),
      ),
    );
  }
}
