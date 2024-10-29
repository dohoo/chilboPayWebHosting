import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/festival_api.dart';

class FestivalManagementPage extends StatefulWidget {
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? festivalId = prefs.getInt('festivalId');

    if (festivalId != null) {
      try {
        final fetchedProducts = await FestivalApi.fetchFestivalProducts(festivalId);

        // fetchedProducts를 List<Map<String, dynamic>>으로 변환
        setState(() {
          products = List<Map<String, dynamic>>.from(fetchedProducts);
        });
      } catch (e) {
        print('Failed to fetch products: $e');
      }
    } else {
      print('Festival ID is not set in SharedPreferences');
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
