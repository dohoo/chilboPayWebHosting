import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/admin_api.dart'; // ApiService 대신 AdminApi import
import 'payment_selection_page.dart'; // PaymentSelectionPage import
import '../no_negative_number_formatter.dart'; // Import the formatter

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
      final data = await AdminApi.fetchProducts(); // AdminApi 사용
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
                    await AdminApi.addProduct(_nameController.text, price.toDouble()); // AdminApi 사용
                  } else {
                    await AdminApi.updateProduct(product['id'], _nameController.text, price.toDouble()); // AdminApi 사용
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
                    await AdminApi.deleteProduct(product['id']); // AdminApi 사용
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSelectionPage(productId: productId), // 선택 화면으로 이동
      ),
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
