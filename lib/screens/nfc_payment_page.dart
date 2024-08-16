import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';

class NfcPaymentPage extends StatefulWidget {
  @override
  _NfcPaymentPageState createState() => _NfcPaymentPageState();
}

class _NfcPaymentPageState extends State<NfcPaymentPage> {
  String message = 'Please tap your NFC card';

  Future<void> _payNfcCard() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final productId = prefs.getInt('productId');

      if (productId == null) {
        setState(() {
          message = 'Product ID is not set';
        });
        return;
      }

      // Start NFC session
      NFCTag tag = await FlutterNfcKit.poll();
      String cardId = tag.id;

      // Fetch userId using cardId
      final userResponse = await ApiService.makeAuthenticatedRequest(
        context,
            (accessToken) {
          return http.get(
            Uri.parse('https://chilbopay.com/user/by-card/$cardId'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $accessToken',
            },
          );
        },
      );

      if (userResponse.statusCode != 200) {
        setState(() {
          message = 'Failed to fetch user information';
        });
        await FlutterNfcKit.finish();
        return;
      }

      final userData = jsonDecode(userResponse.body);
      final userId = userData['userId'];

      // Proceed with payment
      final response = await ApiService.makeAuthenticatedRequest(
        context,
            (accessToken) {
          return http.post(
            Uri.parse('https://chilbopay.com/purchase'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(<String, dynamic>{
              'userId': userId,
              'productId': productId,
            }),
          );
        },
      );

      if (response.statusCode == 201) {
        setState(() {
          message = 'NFC card payment successful';
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          message = 'Failed to pay with NFC card: ${data['message']}';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Failed to pay with NFC card: $e';
      });
      // Do not logout immediately on error, as it might be a temporary issue
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  @override
  void initState() {
    super.initState();
    _payNfcCard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment NFC Card'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(message),
        ),
      ),
    );
  }
}
