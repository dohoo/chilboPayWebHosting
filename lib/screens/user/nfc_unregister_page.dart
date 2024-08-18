import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/api_service.dart';

class NfcUnregisterPage extends StatefulWidget {
  @override
  _NfcUnregisterPageState createState() => _NfcUnregisterPageState();
}

class _NfcUnregisterPageState extends State<NfcUnregisterPage> {
  String message = 'Please tap your NFC card';

  Future<void> _unregisterNfcCard() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      // Start NFC session
      NFCTag tag = await FlutterNfcKit.poll();
      String cardId = tag.id;

      final response = await ApiService.makeAuthenticatedRequest(
        context,
            (accessToken) {
          return http.post(
            Uri.parse('https://chilbopay.com/unregister-nfc'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(<String, dynamic>{
              'userId': userId,
              'cardId': cardId,
            }),
          );
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          message = 'NFC card unregistered successfully';
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          message = 'Failed to unregister NFC card: ${data['message']}';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Failed to unregister NFC card: $e';
      });
      // Do not logout immediately on error, as it might be a temporary issue
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  @override
  void initState() {
    super.initState();
    _unregisterNfcCard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unregister NFC Card'),
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
