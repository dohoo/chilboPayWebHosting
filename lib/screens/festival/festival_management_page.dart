import 'package:flutter/material.dart';
import '../../services/festival_api.dart';

class FestivalManagementPage extends StatefulWidget {
  final int festivalId;

  FestivalManagementPage({required this.festivalId});

  @override
  _FestivalManagementPageState createState() => _FestivalManagementPageState();
}

class _FestivalManagementPageState extends State<FestivalManagementPage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> activities = [];
  bool showProducts = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchActivities();
  }

  Future<void> _fetchProducts() async {
    try {
      final fetchedProducts = await FestivalApi.fetchFestivalProducts(widget.festivalId);
      setState(() {
        products = List<Map<String, dynamic>>.from(fetchedProducts);
      });
    } catch (e) {
      print('Failed to fetch products: $e');
    }
  }

  Future<void> _fetchActivities() async {
    try {
      final fetchedActivities = await FestivalApi.fetchFestivalActivities(widget.festivalId);
      setState(() {
        activities = List<Map<String, dynamic>>.from(fetchedActivities);
      });
    } catch (e) {
      print('Failed to fetch activities: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Festival Management')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => showProducts = true),
                child: Text('Products'),
              ),
              TextButton(
                onPressed: () => setState(() => showProducts = false),
                child: Text('Activities'),
              ),
            ],
          ),
          Expanded(
            child: showProducts
                ? _buildProductList()
                : _buildActivityList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return products.isEmpty
        ? Center(child: Text('No products available.'))
        : ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(products[index]['name']),
          subtitle: Text('Price: ${products[index]['price']}'),
        );
      },
    );
  }

  Widget _buildActivityList() {
    return activities.isEmpty
        ? Center(child: Text('No activities available.'))
        : ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(activities[index]['name']),
          subtitle: Text('Reward: ${activities[index]['price']}'),
        );
      },
    );
  }
}
