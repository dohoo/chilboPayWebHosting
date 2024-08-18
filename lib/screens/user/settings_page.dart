import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../login/login_page.dart';
import 'nfc_register_page.dart';
import 'nfc_unregister_page.dart';
import '../../services/api_service.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String username = '';
  String nfcCardId = '';
  bool isSuspended = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

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
          nfcCardId = data['nfcCardId'] ?? '';
          isSuspended = data['status'] == 'suspended';
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data')),
      );
      await ApiService.logout(context); // Ensure logout is called on error
    }
  }

  Future<void> _updateUser({String? newUsername, String? newPassword}) async {
    if (isSuspended) {
      _showSuspendedMessage();
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    try {
      final response = await ApiService.makeAuthenticatedRequest(
        context,
            (accessToken) {
          return http.put(
            Uri.parse('https://chilbopay.com/user/$userId'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(<String, String>{
              if (newUsername != null) 'username': newUsername,
              if (newPassword != null) 'password': newPassword,
            }),
          );
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User updated successfully')),
        );
        _fetchUserData();
        _usernameController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user')),
        );
      }
    } catch (e) {
      print('Error updating user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user')),
      );
      // Do not logout immediately on error, as it might be a temporary issue
    }
  }

  Future<void> _deleteAccount() async {
    if (isSuspended) {
      _showSuspendedMessage();
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final refreshToken = prefs.getString('refresh_token') ?? '';

    try {
      final response = await ApiService.makeAuthenticatedRequest(
        context,
            (accessToken) {
          return http.delete(
            Uri.parse('https://chilbopay.com/user/$userId'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(<String, String>{
              'refreshToken': refreshToken,
            }),
          );
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account deleted successfully')),
        );
        await prefs.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account')),
        );
      }
    } catch (e) {
      print('Error deleting account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account')),
      );
      // Do not logout immediately on error, as it might be a temporary issue
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token') ?? '';

    try {
      final response = await ApiService.makeAuthenticatedRequest(
        context,
            (accessToken) {
          return http.post(
            Uri.parse('https://chilbopay.com/logout'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(<String, String>{
              'refreshToken': refreshToken,
            }),
          );
        },
      );

      if (response.statusCode == 200) {
        await prefs.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to logout')),
        );
      }
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout')),
      );
      // Do not logout immediately on error, as it might be a temporary issue
    }
  }

  void _showSuspendedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('계정이 정지되어 이 작업을 수행할 수 없습니다.')),
    );
  }

  void _showUpdateUsernameDialog() {
    _usernameController.text = username;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Username'),
          content: TextField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: 'New Username'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateUser(newUsername: _usernameController.text);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdatePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_passwordController.text == _confirmPasswordController.text) {
                  _updateUser(newPassword: _passwordController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Passwords do not match')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _logout();
                Navigator.of(context).pop();
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteAccount();
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings Page'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _showLogoutConfirmationDialog,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('Username'),
              subtitle: Text(username),
            ),
            ElevatedButton(
              onPressed: isSuspended ? _showSuspendedMessage : _showUpdateUsernameDialog,
              child: Text('Update Username'),
            ),
            ElevatedButton(
              onPressed: isSuspended ? _showSuspendedMessage : _showUpdatePasswordDialog,
              child: Text('Update Password'),
            ),
            ElevatedButton(
              onPressed: isSuspended
                  ? _showSuspendedMessage
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NfcRegisterPage()),
                );
              },
              child: Text('Register NFC Card'),
            ),
            ElevatedButton(
              onPressed: isSuspended
                  ? _showSuspendedMessage
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NfcUnregisterPage()),
                );
              },
              child: Text('Unregister NFC Card'),
            ),
            ElevatedButton(
              onPressed: _showLogoutConfirmationDialog,
              child: Text('Logout'),
            ),
            ElevatedButton(
              onPressed: isSuspended ? _showSuspendedMessage : _showDeleteAccountConfirmationDialog,
              child: Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}
