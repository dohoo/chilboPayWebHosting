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
  int? activityCount;
  int festivalId = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initFetch();
  }

  Future<void> _initFetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    festivalId = prefs.getInt('festivalId') ?? 1;
    await _fetchActivityCount();
    await _fetchProducts();
    await _fetchActivities();
  }

  Future<void> _fetchActivityCount() async {
    try {
      final user = await FestivalApi.fetchUserData(festivalId);
      setState(() {
        activityCount = user['activityCount'];
      });
    } catch (e) {
      print('Failed to fetch activity count: $e');
    }
  }

  Future<void> _fetchProducts() async {
    try {
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
      final data = await FestivalApi.fetchFestivalActivities(festivalId);
      setState(() {
        if (data['activityCount'] != null) {
          activityCount = data['activityCount'];
        }
        activities = List<Map<String, dynamic>>.from(data['activities']);
      });
    } catch (e) {
      print('Error fetching activities: $e');
    }
  }

  Future<void> _showPaymentOptionDialog(int itemId, bool isActivity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final festivalId = prefs.getInt('festivalId') ?? 1;

    await showDialog(
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
                      isActivity: isActivity,
                    ),
                  ),
                ).then((_) {
                  // QR 결제 페이지에서 돌아오면 데이터 갱신
                  _refreshData();
                });
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
                      isActivity: isActivity,
                    ),
                  ),
                ).then((_) {
                  // NFC 결제 페이지에서 돌아오면 데이터 갱신
                  _refreshData();
                });
              },
              child: Text('NFC 결제'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshData() async {
    // 결제 완료/실패 화면에서 돌아왔을 때 다시 데이터 Fetch
    await _fetchActivityCount();
    await _fetchActivities();
    await _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Festival 결제'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  activityCount == null
                      ? 'Loading activity count...'
                      : '남은 활동 횟수: $activityCount 회',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Products'),
                  Tab(text: 'Activities'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
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
