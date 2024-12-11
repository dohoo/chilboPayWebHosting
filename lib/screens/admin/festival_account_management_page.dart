import 'package:flutter/material.dart';
import '../../services/festival_api.dart'; // FestivalApi import

class FestivalAccountManagementPage extends StatefulWidget {
  @override
  _FestivalAccountManagementPageState createState() => _FestivalAccountManagementPageState();
}

class _FestivalAccountManagementPageState extends State<FestivalAccountManagementPage> {
  List<dynamic> festivalAccounts = [];

  @override
  void initState() {
    super.initState();
    fetchFestivalAccounts();
  }

  Future<void> fetchFestivalAccounts() async {
    try {
      final accounts = await FestivalApi.fetchFestivalAccounts(); // FestivalApi 사용
      setState(() {
        festivalAccounts = accounts;
      });
    } catch (e) {
      print('Error fetching festival accounts: $e');
    }
  }

  Future<void> createFestivalAccount(String username, String password) async {
    try {
      await FestivalApi.createFestivalAccount(username, password); // FestivalApi 사용
      fetchFestivalAccounts();
    } catch (e) {
      print('Error creating festival account: $e');
    }
  }

  Future<void> updateFestivalAccount(int id, String username, String password) async {
    try {
      await FestivalApi.updateFestivalAccount(id, username, password); // FestivalApi 사용
      fetchFestivalAccounts();
    } catch (e) {
      print('Error updating festival account: $e');
    }
  }

  Future<void> addFestivalProduct(int festivalId, String name, double price) async {
    try {
      await FestivalApi.addFestivalProduct(festivalId, name, price); // FestivalApi 사용
    } catch (e) {
      print('Error adding festival product: $e');
    }
  }

  Future<void> updateFestivalProduct(int id, String name, double price) async {
    try {
      await FestivalApi.updateFestivalProduct(id, name, price); // FestivalApi 사용
    } catch (e) {
      print('Error updating festival product: $e');
    }
  }

  Future<List<dynamic>> fetchFestivalProducts(int festivalId) async {
    try {
      return await FestivalApi.fetchFestivalProducts(festivalId); // FestivalApi 사용
    } catch (e) {
      print('Error fetching festival products: $e');
      return [];
    }
  }

  // Add missing _showEditFestivalAccountDialog method
  void _showEditFestivalAccountDialog(int id, String currentUsername, String currentPassword) {
    final usernameController = TextEditingController(text: currentUsername);
    final passwordController = TextEditingController(text: currentPassword);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('동아리 계정 관리'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Update'),
              onPressed: () {
                updateFestivalAccount(id, usernameController.text, passwordController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddFestivalAccountDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('동아리 계정 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'ID'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('추가'),
              onPressed: () {
                createFestivalAccount(usernameController.text, passwordController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showFestivalProductsDialog(int festivalId) async {
    try {
      List<dynamic> products = await fetchFestivalProducts(festivalId);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('동아리 상품'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      title: Text(product['name']),
                      subtitle: Text(product['price'].toString()),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditProductDialog(
                            product['id'],
                            product['name'],
                            product['price'],
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('닫기'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('상품 추가'),
                onPressed: () {
                  _showAddProductDialog(festivalId);
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  void _showAddProductDialog(int festivalId) {
    final productNameController = TextEditingController();
    final productPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('상품 추가하기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: productNameController,
                decoration: InputDecoration(labelText: '상품명'),
              ),
              TextField(
                controller: productPriceController,
                decoration: InputDecoration(labelText: '상품 가격'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('추가'),
              onPressed: () {
                addFestivalProduct(
                  festivalId,
                  productNameController.text,
                  double.parse(productPriceController.text),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(int productId, String currentName, double currentPrice) {
    final productNameController = TextEditingController(text: currentName);
    final productPriceController = TextEditingController(text: currentPrice.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('상품 편집'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: productNameController,
                decoration: InputDecoration(labelText: '상품명'),
              ),
              TextField(
                controller: productPriceController,
                decoration: InputDecoration(labelText: '상품 가격'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Update'),
              onPressed: () {
                updateFestivalProduct(
                  productId,
                  productNameController.text,
                  double.parse(productPriceController.text),
                );
                Navigator.of(context).pop();
              },
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
        title: Text('동아리 계정'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddFestivalAccountDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: festivalAccounts.length,
        itemBuilder: (context, index) {
          final account = festivalAccounts[index];
          return ListTile(
            title: Text(account['username']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    _showEditFestivalAccountDialog(
                      account['id'],
                      account['username'],
                      '', // Assuming password is not retrievable from the list
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.store),
                  onPressed: () {
                    _showFestivalProductsDialog(account['id']);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
