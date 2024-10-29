import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/festival_api.dart';

class FestivalPaymentPage extends StatefulWidget {
  @override
  _FestivalPaymentPageState createState() => _FestivalPaymentPageState();
}

class _FestivalPaymentPageState extends State<FestivalPaymentPage> {
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final festivalId = prefs.getInt('festivalId') ?? 1; // 기본값 1 설정

      final fetchedProducts = await FestivalApi.fetchFestivalProducts(festivalId);

      // 리스트가 Map<String, dynamic>으로 되어 있는지 확인하고 변환
      setState(() {
        products = List<Map<String, dynamic>>.from(fetchedProducts);
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Festival Products')),
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
