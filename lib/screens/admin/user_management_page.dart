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
        SnackBar(content: Text('유저를 불러오는데 실패하였습니다.: $e')),
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
              title: Text('계정 관리: ${user['username']}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildManagementField('ID', _nameController, 'Edit username', true),
                    _buildManagementField('포인트', _moneyController, 'Edit point', true),
                    _buildManagementField('비밀번호', _passwordController, 'Enter new password', true, obscureText: true),
                    if (isFestival)
                      _buildManagementField('남은 활동 횟수', _activityCountController, 'Edit activity count', true),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('계정 상태'),
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
                      child: Text('계정 삭제'),
                    ),
                    if (isFestival)
                      ElevatedButton(
                        onPressed: () async {
                          debugPrint("Fetching products and activities for user ID: ${user['id']}");
                          Navigator.pop(context); // Close the dialog

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
                            try {
                              await AdminApi.updateUserProductsAndActivities(
                                user['id'],
                                result['상품'] ?? [],
                                result['활동'] ?? [],
                              );
                              _fetchUsers(); // Refresh users list
                            } catch (e) {
                              debugPrint("Failed to update products and activities: $e");
                            }
                          } else {
                            debugPrint("No changes returned from ProductManagePage.");
                          }
                        },
                        child: Text('상품/활동 관리'),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('취소'),
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
                  child: Text('저장'),
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
        title: Text('저장'),
        content: Text('저장하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소'),
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
            child: Text('저장'),
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
        title: Text('포인트 관리'),
        content: TextField(
          controller: _moneyController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: '포인트 양을 입력해주세요.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소'),
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
                SnackBar(content: Text('수정 완료되었습니다.')),
              );
            },
            child: Text('수정'),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedUsers() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('계정 삭제'),
        content: Text('계정들을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소'),
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
                SnackBar(content: Text('계정 삭제 완료')),
              );
            },
            child: Text('삭제'),
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
        title: Text('유저 관리'),
        actions: [
          Row(
            children: [
              Text('모두 선택'),
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
                child: Text('유저', style: TextStyle(color: _selectedRole == 'user' ? Colors.blue : Colors.grey)),
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
                child: Text('동아리', style: TextStyle(color: _selectedRole == 'festival' ? Colors.blue : Colors.grey)),
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
                      child: Text("더보기"),
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
                      child: Text('관리'),
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
                    child: Text('포인트 관리'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: _deleteSelectedUsers,
                    child: Text('계정 삭제'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
