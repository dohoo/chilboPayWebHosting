import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_api.dart'; // ApiService 대신 UserApi import

class NfcRegisterPage extends StatefulWidget {
  @override
  _NfcRegisterPageState createState() => _NfcRegisterPageState();
}

class _NfcRegisterPageState extends State<NfcRegisterPage> {
  String message = 'Please tap your NFC card';

  Future<void> _registerNfcCard() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        setState(() {
          message = 'User ID not found. Please log in again.';
        });
        return;
      }

      // Start NFC session
      NFCTag tag = await FlutterNfcKit.poll();
      String cardId = tag.id;

      // UserApi를 통해 NFC 카드 등록
      final result = await UserApi.registerNfcCard(userId, cardId);

      setState(() {
        message = result['message'];
      });
    } catch (e) {
      setState(() {
        message = 'Failed to register NFC card: $e';
      });
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  @override
  void initState() {
    super.initState();
    _registerNfcCard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register NFC Card'),
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
