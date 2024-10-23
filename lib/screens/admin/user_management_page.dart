import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/admin_api.dart'; // AdminApi import
import '../no_negative_number_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login_page.dart';

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final data = await AdminApi.fetchUsers(); // AdminApi 사용
      setState(() {
        users = data;
      });
    } catch (e) {
      print('Error fetching users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
      await _logout();
    }
  }

  void _showUserOptionsDialog(Map<String, dynamic> user) {
    final TextEditingController _nameController = TextEditingController(text: user['username']);
    final TextEditingController _moneyController = TextEditingController(text: user['money'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _moneyController,
                decoration: InputDecoration(labelText: 'Money'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  NoNegativeNumberFormatter(),
                ],
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
              onPressed: () async {
                await AdminApi.updateUser(user['id'], _nameController.text, int.parse(_moneyController.text)); // AdminApi 사용
                _fetchUsers();
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () async {
                await AdminApi.deleteUser(user['id']); // AdminApi 사용
                _fetchUsers();
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            if (user['status'] == 'active')
              TextButton(
                onPressed: () async {
                  await AdminApi.suspendUser(user['id']); // AdminApi 사용
                  _fetchUsers();
                  Navigator.of(context).pop();
                },
                child: Text('Suspend'),
              ),
            if (user['status'] == 'suspended')
              TextButton(
                onPressed: () async {
                  await AdminApi.unsuspendUser(user['id']); // AdminApi 사용
                  _fetchUsers();
                  Navigator.of(context).pop();
                },
                child: Text('Unsuspend'),
              ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _showLogoutConfirmationDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user['username']),
            subtitle: Text('Money: ${user['money']} - Status: ${user['status']}'),
            onTap: () => _showUserOptionsDialog(user),
          );
        },
      ),
    );
  }
}
