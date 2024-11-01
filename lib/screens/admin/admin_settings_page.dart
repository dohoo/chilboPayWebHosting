import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/admin_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login_page.dart';
import 'product_add_page.dart';

class AdminSettingsPage extends StatefulWidget {
  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> activities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _showCreateAccountDialog(context, 'user'),
              child: Text('Create Student Account'),
            ),
            ElevatedButton(
              onPressed: () => _showCreateAccountDialog(context, 'festival'),
              child: Text('Create Club Account'),
            ),
            ElevatedButton(
              onPressed: () => _showChangePasswordDialog(context),
              child: Text('Change Password'),
            ),
            ElevatedButton(
              onPressed: () => _showLogoutConfirmationDialog(context),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _logout(context);
                Navigator.of(context).pop();
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout')),
      );
    }
  }

  Future<void> _showCreateAccountDialog(BuildContext context, String accountType) async {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final moneyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create ${accountType == 'user' ? 'Student' : 'Club'} Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: moneyController,
                  decoration: InputDecoration(labelText: 'Money'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                if (accountType == 'festival') ...[
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductAddPage(
                            existingProducts: products,
                            existingActivities: activities,
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          products = result['products'];
                          activities = result['activities'];
                        });
                      }
                    },
                    child: Text('Add Club Product/Activity'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Create'),
              onPressed: () {
                if (passwordController.text == confirmPasswordController.text) {
                  _createAccount(
                    accountType,
                    usernameController.text,
                    passwordController.text,
                    int.parse(moneyController.text),
                    products,
                    activities,
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Passwords do not match')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _createAccount(
      String accountType,
      String username,
      String password,
      int money,
      List<Map<String, dynamic>> products,
      List<Map<String, dynamic>> activities,
      ) async {
    try {
      await AdminApi.createAccount(accountType, username, password, money, products, activities);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating account: $e')),
      );
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmNewPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: InputDecoration(labelText: 'Old Password'),
                obscureText: true,
              ),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              TextField(
                controller: confirmNewPasswordController,
                decoration: InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Change'),
              onPressed: () {
                if (newPasswordController.text == confirmNewPasswordController.text) {
                  _changePassword(oldPasswordController.text, newPasswordController.text);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('New passwords do not match')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _changePassword(String oldPassword, String newPassword) async {
    try {
      await AdminApi.changePassword(oldPassword, newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password changed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error changing password: $e')),
      );
    }
  }
}
