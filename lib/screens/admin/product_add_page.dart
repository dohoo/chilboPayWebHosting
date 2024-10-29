import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductAddPage extends StatefulWidget {
  final List<Map<String, dynamic>> existingProducts;

  ProductAddPage({Key? key, required this.existingProducts}) : super(key: key);

  @override
  _ProductAddPageState createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final List<Map<String, dynamic>> products = [];
  final productNameController = TextEditingController();
  final productPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    products.addAll(widget.existingProducts);
  }

  void _addProduct() {
    final name = productNameController.text;
    final price = int.tryParse(productPriceController.text) ?? 0;
    if (name.isNotEmpty && price > 0) {
      setState(() {
        products.add({'name': name, 'price': price});
      });
      productNameController.clear();
      productPriceController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Festival Products'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: productNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: productPriceController,
              decoration: InputDecoration(labelText: 'Product Price'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly], // 숫자만 입력 가능
            ),
            ElevatedButton(
              onPressed: _addProduct,
              child: Text('Add Product'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    title: Text(product['name']),
                    subtitle: Text('Price: ${product['price']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, products); // 이전 페이지로 상품 리스트 반환
        },
        child: Icon(Icons.arrow_back),
        tooltip: 'Return to Account Creation',
      ),
    );
  }
}
