import 'package:flutter/material.dart';
import '../../services/festival_api.dart';

class FestivalManagementPage extends StatefulWidget {
  final int id;

  FestivalManagementPage({required this.id});

  @override
  _FestivalManagementPageState createState() => _FestivalManagementPageState();
}

class _FestivalManagementPageState extends State<FestivalManagementPage> {
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final fetchedProducts = await FestivalApi.fetchFestivalProducts(widget.id);  // id 사용
      setState(() {
        products = List<Map<String, dynamic>>.from(fetchedProducts);
      });
    } catch (e) {
      print('Failed to fetch products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Festival Management'),
      ),
      body: products.isEmpty
          ? Center(child: Text('No products available.'))
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(products[index]['name']),
            subtitle: Text('Price: ${products[index]['price']}'),
          );
        },
      ),
    );
  }
}
