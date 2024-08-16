import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import 'nfc_payment_page.dart';
import 'no_negative_number_formatter.dart'; // Import the formatter

class CardPaymentPage extends StatefulWidget {
  @override
  _CardPaymentPageState createState() => _CardPaymentPageState();
}

class _CardPaymentPageState extends State<CardPaymentPage> {
  List products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final data = await ApiService.fetchProducts(context); // Pass context
      setState(() {
        products = data;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products')),
      );
    }
  }

  void _showProductDialog({Map<String, dynamic>? product}) {
    final TextEditingController _nameController = TextEditingController(text: product?['name'] ?? '');
    final TextEditingController _priceController = TextEditingController(text: product?['price']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  NoNegativeNumberFormatter(), // Add the custom formatter
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
                final int price = int.parse(_priceController.text); // Convert to int
                try {
                  if (product == null) {
                    await ApiService.addProduct(context, _nameController.text, price.toDouble()); // Pass context
                  } else {
                    await ApiService.updateProduct(context, product['id'], _nameController.text, price.toDouble()); // Pass context
                  }
                  _fetchProducts();
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error updating or adding product: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update or add product')),
                  );
                }
              },
              child: Text(product == null ? 'Add' : 'Update'),
            ),
            if (product != null)
              TextButton(
                onPressed: () async {
                  try {
                    await ApiService.deleteProduct(context, product['id']); // Pass context
                    _fetchProducts();
                    Navigator.of(context).pop();
                  } catch (e) {
                    print('Error deleting product: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete product')),
                    );
                  }
                },
                child: Text('Delete'),
              ),
          ],
        );
      },
    );
  }

  Future<void> _setProductAndNavigate(int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('productId', productId);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NfcPaymentPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Payment'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showProductDialog(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final int price = int.parse(product['price'].toString()); // Convert to int
          return ListTile(
            title: Text(product['name']),
            subtitle: Text('Price: $price'),
            onTap: () => _setProductAndNavigate(product['id']),
            trailing: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => _showProductDialog(product: product),
            ),
          );
        },
      ),
    );
  }
}
