import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 추가: FilteringTextInputFormatter 사용을 위한 import
import '../../services/admin_api.dart';

class ProductSettingsPage extends StatefulWidget {
  @override
  _ProductSettingsPageState createState() => _ProductSettingsPageState();
}

class _ProductSettingsPageState extends State<ProductSettingsPage> {
  List products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final data = await AdminApi.fetchProducts();
      setState(() {
        products = data;
      });
    } catch (e) {
      print('Error fetching products: $e');
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                final int price = int.parse(_priceController.text);
                try {
                  if (product == null) {
                    await AdminApi.addProduct(_nameController.text, price.toDouble());
                  } else {
                    await AdminApi.updateProduct(product['id'], _nameController.text, price.toDouble());
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
                  await AdminApi.deleteProduct(product['id']);
                  _fetchProducts();
                  Navigator.of(context).pop();
                },
                child: Text('Delete'),
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
        title: Text('Product Settings'),
        actions: [
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
          return ListTile(
            title: Text(product['name']),
            subtitle: Text('Price: ${product['price']}'),
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
