import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductAddPage extends StatefulWidget {
  final List<Map<String, dynamic>> existingProducts;
  final List<Map<String, dynamic>> existingActivities;

  ProductAddPage({
    Key? key,
    required this.existingProducts,
    required this.existingActivities,
  }) : super(key: key);

  @override
  _ProductAddPageState createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> activities = [];
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  bool isProduct = true;

  @override
  void initState() {
    super.initState();
    products = List<Map<String, dynamic>>.from(widget.existingProducts);
    activities = List<Map<String, dynamic>>.from(widget.existingActivities);
  }

  void _addItem() {
    final name = nameController.text;
    final price = int.tryParse(priceController.text) ?? 0;

    if (name.isNotEmpty && price > 0) {
      setState(() {
        if (isProduct) {
          products.add({'name': name, 'price': price});
        } else {
          activities.add({'name': name, 'price': price});
        }
      });
      nameController.clear();
      priceController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Products and Activities'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      isProduct = true;
                    });
                  },
                  child: Text(
                    'Add Product',
                    style: TextStyle(color: isProduct ? Colors.blue : Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isProduct = false;
                    });
                  },
                  child: Text(
                    'Add Activity',
                    style: TextStyle(color: !isProduct ? Colors.blue : Colors.grey),
                  ),
                ),
              ],
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: isProduct ? 'Product Name' : 'Activity Name'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            ElevatedButton(
              onPressed: _addItem,
              child: Text(isProduct ? 'Add Product' : 'Add Activity'),
            ),
            Expanded(
              child: ListView(
                children: [
                  if (products.isNotEmpty) ...[
                    ListTile(title: Text('Products', style: TextStyle(fontWeight: FontWeight.bold))),
                    ...products.map((product) => ListTile(
                      title: Text(product['name']),
                      subtitle: Text('Price: ${product['price']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            products.remove(product);
                          });
                        },
                      ),
                    )),
                  ],
                  if (activities.isNotEmpty) ...[
                    ListTile(title: Text('Activities', style: TextStyle(fontWeight: FontWeight.bold))),
                    ...activities.map((activity) => ListTile(
                      title: Text(activity['name']),
                      subtitle: Text('Reward: ${activity['price']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            activities.remove(activity);
                          });
                        },
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, {'products': products, 'activities': activities});
        },
        child: Icon(Icons.check),
        tooltip: 'Save and Return',
      ),
    );
  }
}
