import 'package:flutter/material.dart';
import '../../services/admin_api.dart';
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

  bool _selectAll = false;
  Set<int> _selectedUserIds = {};

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final data = await AdminApi.fetchUsers();
      if (!mounted) return;
      setState(() {
        users = data;
        _updateDisplayedUsers();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
    }
  }

  Future<void> _refreshUsers() async {
    setState(() {
      displayedCount = 10;
      _selectAll = false;
      _selectedUserIds.clear();
      users.clear();
      displayedUsers.clear();
    });
    await _fetchUsers();
  }

  void _updateDisplayedUsers() {
    final filteredUsers = users.where((user) => user['role'] == _selectedRole).toList();

    if (_selectAll) {
      displayedUsers = filteredUsers;
      _selectedUserIds = displayedUsers.map<int>((user) => user['id'] as int).toSet();
    } else {
      displayedUsers = filteredUsers.take(displayedCount).toList();
      _selectedUserIds.removeWhere((id) => !displayedUsers.any((user) => user['id'] == id));
    }

    setState(() {});
  }

  void _showUserOptionsDialog(Map<String, dynamic> user) {
    final TextEditingController _nameController = TextEditingController(text: user['username']);
    final TextEditingController _moneyController = TextEditingController(text: user['money'].toString());
    final TextEditingController _passwordController = TextEditingController();

    // festival인 경우 activityCount 필드를 관리하기 위한 컨트롤러
    final TextEditingController _activityCountController = TextEditingController(
      text: user['activityCount'] != null ? user['activityCount'].toString() : '0',
    );

    bool isSuspended = user['status'] == 'suspended';
    bool isFestival = user['role'] == 'festival';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Manage Account: ${user['username']}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildManagementField('Username', _nameController, 'Edit username', true),
                    _buildManagementField('Money', _moneyController, 'Edit point', true),
                    _buildManagementField('Password', _passwordController, 'Enter new password', true, obscureText: true),
                    if (isFestival)
                      _buildManagementField('Activity Count', _activityCountController, 'Edit activity count', true),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Account Status'),
                        Switch(
                          value: !isSuspended,
                          onChanged: (value) {
                            setStateDialog(() {
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
                    if (isFestival)
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
                    isFestival ? int.tryParse(_activityCountController.text) ?? 0 : null,
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
        title: Text('계정 삭제'),
        content: Text('정말 이 계정을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final response = await AdminApi.deleteUser(userId);
                if (response.statusCode == 200) {
                  await _fetchUsers();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('계정이 성공적으로 삭제되었습니다.')),
                  );
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('계정 삭제에 실패했습니다.')),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('오류가 발생했습니다: $e')),
                );
              }
            },
            child: Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSaveChanges(int userId, String username, int money, String password, bool isSuspended, int? activityCount) async {
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
                activityCount: activityCount, // activityCount를 추가로 업데이트
              );
              await _fetchUsers();
              if (!mounted) return;
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

  void _manageSelectedUsersMoney() async {
    TextEditingController _moneyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Selected Accounts Money Manage'),
        content: TextField(
          controller: _moneyController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'Enter new money amount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              int newMoney = int.tryParse(_moneyController.text) ?? 0;
              final selectedIds = List<int>.from(_selectedUserIds);
              for (var user in displayedUsers) {
                if (selectedIds.contains(user['id'])) {
                  await AdminApi.updateUser(
                    user['id'],
                    user['username'],
                    newMoney,
                    password: null,
                    status: user['status'],
                  );
                }
              }
              await _fetchUsers();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected users updated successfully.')),
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedUsers() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Selected Accounts'),
        content: Text('Are you sure you want to delete all selected accounts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final selectedIds = List<int>.from(_selectedUserIds);
              for (int userId in selectedIds) {
                try {
                  final response = await AdminApi.deleteUser(userId);
                  if (response.statusCode != 200) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete account with ID $userId')),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting account with ID $userId: $e')),
                  );
                }
              }
              await _fetchUsers();
              _selectedUserIds.clear();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected accounts have been deleted.')),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalUsersOfRole = users.where((user) => user['role'] == _selectedRole).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        actions: [
          Row(
            children: [
              Text('Select All'),
              Checkbox(
                value: _selectAll,
                onChanged: (value) {
                  setState(() {
                    _selectAll = value ?? false;
                    if (_selectAll) {
                      displayedCount = totalUsersOfRole;
                    } else {
                      displayedCount = 10;
                      _selectedUserIds.clear();
                    }
                    _updateDisplayedUsers();
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 역할 선택 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedRole = 'user';
                    displayedCount = _selectAll ? users.where((u) => u['role'] == 'user').length : 10;
                    _selectAll = false;
                    _selectedUserIds.clear();
                    _updateDisplayedUsers();
                  });
                },
                child: Text('Users', style: TextStyle(color: _selectedRole == 'user' ? Colors.blue : Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedRole = 'festival';
                    displayedCount = _selectAll ? users.where((u) => u['role'] == 'festival').length : 10;
                    _selectAll = false;
                    _selectedUserIds.clear();
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
                padding: EdgeInsets.only(bottom: _selectedUserIds.isNotEmpty ? 80.0 : 0.0),
                itemCount: displayedUsers.length + (_selectAll ? 0 : 1),
                itemBuilder: (context, index) {
                  if (!_selectAll && index == displayedUsers.length) {
                    return (displayedCount < totalUsersOfRole)
                        ? TextButton(
                      onPressed: _loadMoreUsers,
                      child: Text("Load More"),
                    )
                        : Container();
                  }

                  final user = displayedUsers[index];
                  return ListTile(
                    leading: Checkbox(
                      value: _selectedUserIds.contains(user['id']),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedUserIds.add(user['id']);
                          } else {
                            _selectedUserIds.remove(user['id']);
                            if (_selectAll) {
                              _selectAll = false;
                            }
                          }
                          if (!_selectAll && _selectedUserIds.length == displayedUsers.length && displayedUsers.isNotEmpty) {
                            _selectAll = true;
                          }
                        });
                      },
                    ),
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
          if (_selectedUserIds.isNotEmpty)
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _manageSelectedUsersMoney,
                    child: Text('Manage Money'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: _deleteSelectedUsers,
                    child: Text('Delete Accounts'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
