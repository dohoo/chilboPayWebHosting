import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FestivalNfcPaymentPage extends StatefulWidget {
  @override
  _FestivalNfcPaymentPageState createState() => _FestivalNfcPaymentPageState();
}

class _FestivalNfcPaymentPageState extends State<FestivalNfcPaymentPage> {
  String message = 'Please tap your NFC card';

  Future<void> _payNfcCard() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final productId = prefs.getInt('productId');
      final festivalId = prefs.getInt('festivalId'); // Ensure festivalId is stored in SharedPreferences

      if (productId == null || festivalId == null) {
        setState(() {
          message = 'Product ID or Festival ID is not set';
        });
        return;
      }

      // Start NFC session
      NFCTag tag = await FlutterNfcKit.poll();
      String cardId = tag.id;

      // Fetch userId using cardId
      final userResponse = await http.get(
        Uri.parse('http://114.204.195.233/user/by-card/$cardId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${await _getAccessToken()}',
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
      final response = await http.post(
        Uri.parse('http://114.204.195.233/festival-purchase'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: jsonEncode(<String, dynamic>{
          'userId': userId,
          'productId': productId,
          'festivalId': festivalId, // Include festivalId in the request
        }),
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
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  Future<String?> _getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
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
        title: Text('Festival NFC Payment'),
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