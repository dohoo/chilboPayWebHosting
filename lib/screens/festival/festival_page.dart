import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'festival_nfc_payment_page.dart';
import '../login/login_page.dart';
import '../../services/festival_api.dart'; // FestivalApi import

class FestivalPage extends StatefulWidget {
  @override
  _FestivalPageState createState() => _FestivalPageState();
}

class _FestivalPageState extends State<FestivalPage> {
  String username = '';
  List products = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchProducts();
  }

  Future<void> _fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final role = prefs.getString('role');

      if (userId != null) {
        final data = await FestivalApi.fetchUserData(userId); // FestivalApi 사용
        setState(() {
          username = data['username'];
        });

        if (role == 'festival') {
          await prefs.setInt('festivalId', userId); // Store the festivalId
        }
      } else {
        print('User ID not found in shared preferences.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final data = await FestivalApi.fetchProducts(); // FestivalApi 사용
      setState(() {
        products = data;
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> _navigateToNfcPayment(int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('productId', productId);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FestivalNfcPaymentPage()),
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
        title: Text('Festival Page - $username'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _showLogoutConfirmationDialog,
          ),
        ],
      ),
      body: products.isEmpty
          ? Center(child: Text('No products available.'))
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(products[index]['name']),
            subtitle: Text('Price: ${products[index]['price']}'),
            onTap: () => _navigateToNfcPayment(products[index]['id']),
          );
        },
      ),
    );
  }
}
