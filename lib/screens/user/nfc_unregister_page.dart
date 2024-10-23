import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_api.dart'; // ApiService 대신 UserApi import

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

      if (userId == null) {
        setState(() {
          message = 'User ID not found. Please log in again.';
        });
        return;
      }

      // Start NFC session
      NFCTag tag = await FlutterNfcKit.poll();
      String cardId = tag.id;

      // UserApi를 통해 NFC 카드 해제
      final result = await UserApi.unregisterNfcCard(userId, cardId);

      setState(() {
        message = result['message'];
      });
    } catch (e) {
      setState(() {
        message = 'Failed to unregister NFC card: $e';
      });
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
