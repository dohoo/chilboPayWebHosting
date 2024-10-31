import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/festival_api.dart';
import 'festival_qr_payment_page.dart';
import 'festival_nfc_payment_page.dart';

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

      setState(() {
        products = List<Map<String, dynamic>>.from(fetchedProducts);
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  // 결제 방식을 선택하는 팝업 창
  void _showPaymentOptionDialog(int productId) {
    SharedPreferences.getInstance().then((prefs) {
      final festivalId = prefs.getInt('festivalId') ?? 1;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Payment Method'),
            content: Text('Choose a payment method for the selected product.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FestivalQrPaymentPage(
                        productId: productId,
                        festivalId: festivalId,
                      ),
                    ),
                  );
                },
                child: Text('QR Payment'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FestivalNfcPaymentPage(
                        productId: productId,
                        festivalId: festivalId,
                      ),
                    ),
                  );
                },
                child: Text('NFC Payment'),
              ),
            ],
          );
        },
      );
    });
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
            onTap: () => _showPaymentOptionDialog(products[index]['id']),
          );
        },
      ),
    );
  }
}
