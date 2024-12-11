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
        title: Text('상품/활동 추가'),
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
                    '상품 추가',
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
                    '활동 추가',
                    style: TextStyle(color: !isProduct ? Colors.blue : Colors.grey),
                  ),
                ),
              ],
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: isProduct ? '상품명' : '활동명'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            ElevatedButton(
              onPressed: _addItem,
              child: Text(isProduct ? '상품 추가' : '활동 추가'),
            ),
            Expanded(
              child: ListView(
                children: [
                  if (products.isNotEmpty) ...[
                    ListTile(title: Text('상품', style: TextStyle(fontWeight: FontWeight.bold))),
                    ...products.map((product) => ListTile(
                      title: Text(product['name']),
                      subtitle: Text('가격: ${product['price']}'),
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
                    ListTile(title: Text('활동', style: TextStyle(fontWeight: FontWeight.bold))),
                    ...activities.map((activity) => ListTile(
                      title: Text(activity['name']),
                      subtitle: Text('가격: ${activity['price']}'),
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
          Navigator.pop(context, {'상품': products, '활동': activities});
        },
        child: Icon(Icons.check),
        tooltip: '저장',
      ),
    );
  }
}
