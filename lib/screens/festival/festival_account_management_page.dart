import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final response = await http.get(Uri.parse('https://chilbopay.com/festivalAccounts'));
    if (response.statusCode == 200) {
      setState(() {
        festivalAccounts = json.decode(response.body);
      });
    } else {
      // Error handling
    }
  }

  Future<void> createFestivalAccount(String username, String password) async {
    final response = await http.post(
      Uri.parse('https://chilbopay.com/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'role': 'festival',
      }),
    );

    if (response.statusCode == 201) {
      fetchFestivalAccounts();
    } else {
      // Error handling
    }
  }

  Future<void> updateFestivalAccount(int id, String username, String password) async {
    final response = await http.put(
      Uri.parse('https://chilbopay.com/user/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      fetchFestivalAccounts();
    } else {
      // Error handling
    }
  }

  Future<void> addFestivalProduct(int festivalId, String name, double price) async {
    final response = await http.post(
      Uri.parse('https://chilbopay.com/festivalProducts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'festivalId': festivalId,
        'name': name,
        'price': price,
      }),
    );

    if (response.statusCode == 201) {
      // Successfully added the product
    } else {
      // Error handling
    }
  }

  Future<void> updateFestivalProduct(int id, String name, double price) async {
    final response = await http.put(
      Uri.parse('https://chilbopay.com/festivalProducts/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'price': price,
      }),
    );

    if (response.statusCode == 200) {
      // Successfully updated the product
    } else {
      // Error handling
    }
  }

  Future<List<dynamic>> fetchFestivalProducts(int festivalId) async {
    final response = await http.get(Uri.parse('https://chilbopay.com/festivalProducts?festivalId=$festivalId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Print the response body for debugging purposes
      print('Failed to load products: ${response.body}');
      // Error handling
      throw Exception('Failed to load products');
    }
  }

  void _showAddFestivalAccountDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Festival Account'),
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
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add'),
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

  void _showEditFestivalAccountDialog(int id, String currentUsername, String currentPassword) {
    final usernameController = TextEditingController(text: currentUsername);
    final passwordController = TextEditingController(text: currentPassword);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Festival Account'),
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
              child: Text('Cancel'),
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

  void _showAddProductDialog(int festivalId) {
    final productNameController = TextEditingController();
    final productPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: productNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: productPriceController,
                decoration: InputDecoration(labelText: 'Product Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add'),
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
          title: Text('Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: productNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: productPriceController,
                decoration: InputDecoration(labelText: 'Product Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
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

  void _showFestivalProductsDialog(int festivalId) async {
    try {
      List<dynamic> products = await fetchFestivalProducts(festivalId);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Festival Products'),
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
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('Add Product'),
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
      // Display an error dialog or message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Festival Accounts'),
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
