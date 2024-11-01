import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/festival_api.dart';
import 'festival_qr_payment_page.dart';
import 'festival_nfc_payment_page.dart';

class FestivalPaymentPage extends StatefulWidget {
  @override
  _FestivalPaymentPageState createState() => _FestivalPaymentPageState();
}

class _FestivalPaymentPageState extends State<FestivalPaymentPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> activities = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 탭 컨트롤러 초기화
    _fetchProducts();
    _fetchActivities();
  }

  Future<void> _fetchProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final festivalId = prefs.getInt('festivalId') ?? 1;

      final fetchedProducts = await FestivalApi.fetchFestivalProducts(festivalId);
      setState(() {
        products = List<Map<String, dynamic>>.from(fetchedProducts);
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> _fetchActivities() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final festivalId = prefs.getInt('festivalId') ?? 1;

      final fetchedActivities = await FestivalApi.fetchFestivalActivities(festivalId);
      setState(() {
        activities = List<Map<String, dynamic>>.from(fetchedActivities);
      });
    } catch (e) {
      print('Error fetching activities: $e');
    }
  }

  // 결제 방식을 선택하는 팝업 창
  void _showPaymentOptionDialog(int itemId, bool isActivity) {
    SharedPreferences.getInstance().then((prefs) {
      final festivalId = prefs.getInt('festivalId') ?? 1;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('결제 방식 선택'),
            content: Text(isActivity ? '선택한 활동에 대한 결제 방법을 선택하세요.' : '선택한 제품에 대한 결제 방법을 선택하세요.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FestivalQrPaymentPage(
                        productId: itemId,
                        festivalId: festivalId,
                      ),
                    ),
                  );
                },
                child: Text('QR 결제'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FestivalNfcPaymentPage(
                        productId: itemId,
                        festivalId: festivalId,
                      ),
                    ),
                  );
                },
                child: Text('NFC 결제'),
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
      appBar: AppBar(
        title: Text('Festival 결제'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Products'),
            Tab(text: 'Activities'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Products 탭
          products.isEmpty
              ? Center(child: Text('이용 가능한 제품이 없습니다.'))
              : ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(products[index]['name']),
                subtitle: Text('Price: ${products[index]['price']}'),
                onTap: () => _showPaymentOptionDialog(products[index]['id'], false),
              );
            },
          ),
          // Activities 탭
          activities.isEmpty
              ? Center(child: Text('이용 가능한 활동이 없습니다.'))
              : ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(activities[index]['name']),
                subtitle: Text('Reward: ${activities[index]['price']}'),
                onTap: () => _showPaymentOptionDialog(activities[index]['id'], true),
              );
            },
          ),
        ],
      ),
    );
  }
}
