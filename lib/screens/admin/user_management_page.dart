import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/admin_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login_page.dart';
import 'product_manage_page.dart';

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List users = [];
  List displayedUsers = [];
  int displayedCount = 10;
  String _selectedRole = 'user';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final data = await AdminApi.fetchUsers();
      setState(() {
        users = data;
        _updateDisplayedUsers();
      });
    } catch (e) {
      print('Error fetching users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
    }
  }

  Future<void> _refreshUsers() async {
    setState(() {
      displayedCount = 10;
      users.clear();
      displayedUsers.clear();
    });
    await _fetchUsers();
  }

  void _updateDisplayedUsers() {
    setState(() {
      displayedUsers = users.where((user) => user['role'] == _selectedRole).take(displayedCount).toList();
    });
  }

  void _showUserOptionsDialog(Map<String, dynamic> user) {
    final TextEditingController _nameController = TextEditingController(text: user['username']);
    final TextEditingController _moneyController = TextEditingController(text: user['money'].toString());
    final TextEditingController _passwordController = TextEditingController();
    bool isSuspended = user['status'] == 'suspended';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Manage Account: ${user['username']}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildManagementField('Username', _nameController, 'Edit username', true),
                  _buildManagementField('Money', _moneyController, 'Edit point', true),
                  _buildManagementField('Password', _passwordController, 'Enter new password', true, obscureText: true),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Account Status'),
                      Switch(
                        value: !isSuspended,
                        onChanged: (value) {
                          setState(() {
                            isSuspended = !value;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _confirmDeleteUser(user['id']),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Delete Account'),
                  ),
                  if (user['role'] == 'festival')
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final products = (await AdminApi.fetchFestivalProducts(user['id'])).cast<Map<String, dynamic>>();
                        final activities = (await AdminApi.fetchFestivalActivities(user['id'])).cast<Map<String, dynamic>>();

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductManagePage(
                              existingProducts: products,
                              existingActivities: activities,
                            ),
                          ),
                        );

                        if (result != null) {
                          await AdminApi.updateUserProductsAndActivities(
                            user['id'],
                            result['products'],
                            result['activities'],
                          );
                          _fetchUsers();
                        }
                      },
                      child: Text('Manage Products/Activities'),
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
                  onPressed: () => _confirmSaveChanges(
                    user['id'],
                    _nameController.text,
                    int.parse(_moneyController.text),
                    _passwordController.text,
                    isSuspended,
                  ),
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteUser(int userId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text('Are you sure you want to delete this account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await AdminApi.deleteUser(userId);
              _fetchUsers();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSaveChanges(
      int userId, String username, int money, String password, bool isSuspended) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save Changes'),
        content: Text('Are you sure you want to save the changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await AdminApi.updateUser(
                userId,
                username,
                money,
                password: password.isNotEmpty ? password : null,
                status: isSuspended ? 'suspended' : 'active',
              );
              _fetchUsers();
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementField(String label, TextEditingController controller, String hintText, bool isEditable,
      {bool obscureText = false}) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Expanded(
          flex: 2,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hintText),
            readOnly: !isEditable,
            obscureText: obscureText,
            keyboardType: TextInputType.text,
          ),
        ),
      ],
    );
  }

  void _loadMoreUsers() {
    setState(() {
      displayedCount += 10;
      _updateDisplayedUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedRole = 'user';
                    displayedCount = 10;
                    _updateDisplayedUsers();
                  });
                },
                child: Text('Users', style: TextStyle(color: _selectedRole == 'user' ? Colors.blue : Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedRole = 'festival';
                    displayedCount = 10;
                    _updateDisplayedUsers();
                  });
                },
                child: Text('Clubs', style: TextStyle(color: _selectedRole == 'festival' ? Colors.blue : Colors.grey)),
              ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshUsers,
              child: ListView.builder(
                itemCount: displayedUsers.length + 1,
                itemBuilder: (context, index) {
                  if (index == displayedUsers.length) {
                    return (displayedCount < users.where((user) => user['role'] == _selectedRole).length)
                        ? TextButton(
                      onPressed: _loadMoreUsers,
                      child: Text("Load More"),
                    )
                        : Container();
                  }

                  final user = displayedUsers[index];
                  return ListTile(
                    title: Text(user['username']),
                    subtitle: Row(
                      children: [
                        Text('${user['money']}p'),
                        SizedBox(width: 16),
                        if (user['status'] == 'suspended') Text('Suspended', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _showUserOptionsDialog(user),
                      child: Text('Manage'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
