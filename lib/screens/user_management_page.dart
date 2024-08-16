import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import 'no_negative_number_formatter.dart';

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
      final data = await ApiService.fetchUsers(context);
      setState(() {
        users = data;
      });
    } catch (e) {
      print('Error fetching users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
      await ApiService.logout(context);
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
                await ApiService.updateUser(context, user['id'], _nameController.text, int.parse(_moneyController.text));
                _fetchUsers();
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () async {
                await ApiService.deleteUser(context, user['id']);
                _fetchUsers();
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            if (user['status'] == 'active')
              TextButton(
                onPressed: () async {
                  await ApiService.suspendUser(context, user['id']);
                  _fetchUsers();
                  Navigator.of(context).pop();
                },
                child: Text('Suspend'),
              ),
            if (user['status'] == 'suspended')
              TextButton(
                onPressed: () async {
                  await ApiService.unsuspendUser(context, user['id']);
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
      await ApiService.logout(context);
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
