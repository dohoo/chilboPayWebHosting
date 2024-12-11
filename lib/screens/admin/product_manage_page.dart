import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductManagePage extends StatefulWidget {
  final List<Map<String, dynamic>> existingProducts;
  final List<Map<String, dynamic>> existingActivities;

  ProductManagePage({
    Key? key,
    required this.existingProducts,
    required this.existingActivities,
  }) : super(key: key);

  @override
  _ProductManagePageState createState() => _ProductManagePageState();
}

class _ProductManagePageState extends State<ProductManagePage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> activities = [];
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  bool isEditingProduct = true;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    // 기존 제품과 활동 목록을 로컬 변수로 복사하여 표시
    products = List<Map<String, dynamic>>.from(widget.existingProducts);
    activities = List<Map<String, dynamic>>.from(widget.existingActivities);
  }

  void _editItem(int index, bool isProduct) {
    setState(() {
      isEditingProduct = isProduct;
      editingIndex = index;
      final item = isProduct ? products[index] : activities[index];
      nameController.text = item['name'];
      priceController.text = item['price'].toString();
    });
  }

  void _addOrUpdateItem() {
    final name = nameController.text;
    final price = int.tryParse(priceController.text) ?? 0;

    if (name.isNotEmpty && price > 0) {
      setState(() {
        final newItem = {'name': name, 'price': price};

        if (editingIndex != null) {
          if (isEditingProduct) {
            products[editingIndex!] = newItem;
          } else {
            activities[editingIndex!] = newItem;
          }
          editingIndex = null;
        } else {
          if (isEditingProduct) {
            products.add(newItem);
          } else {
            activities.add(newItem);
          }
        }

        nameController.clear();
        priceController.clear();
      });
    }
  }

  void _deleteItem(int index, bool isProduct) {
    setState(() {
      if (isProduct) {
        products.removeAt(index);
      } else {
        activities.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상품/활동 관리'),
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
                      isEditingProduct = true;
                      editingIndex = null;
                      nameController.clear();
                      priceController.clear();
                    });
                  },
                  child: Text(
                    '상품 추가',
                    style: TextStyle(
                      color: isEditingProduct ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isEditingProduct = false;
                      editingIndex = null;
                      nameController.clear();
                      priceController.clear();
                    });
                  },
                  child: Text(
                    '활동 추가',
                    style: TextStyle(
                      color: !isEditingProduct ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: isEditingProduct ? '상품명' : '활동명'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            ElevatedButton(
              onPressed: _addOrUpdateItem,
              child: Text(editingIndex == null ? '추가' : '수정'),
            ),
            Expanded(
              child: ListView(
                children: [
                  if (products.isNotEmpty) ...[
                    ListTile(
                      title: Text(
                        '상품',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...products.asMap().entries.map((entry) {
                      final index = entry.key;
                      final product = entry.value;
                      return ListTile(
                        title: Text(product['name']),
                        subtitle: Text('가격: ${product['price']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editItem(index, true),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteItem(index, true),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  if (activities.isNotEmpty) ...[
                    ListTile(
                      title: Text(
                        '활동',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...activities.asMap().entries.map((entry) {
                      final index = entry.key;
                      final activity = entry.value;
                      return ListTile(
                        title: Text(activity['name']),
                        subtitle: Text('가격: ${activity['price']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editItem(index, false),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteItem(index, false),
                            ),
                          ],
                        ),
                      );
                    }),
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
