import 'package:http/http.dart' as http;
import 'dart:convert';

class FestivalApi {
  static const String baseUrl = 'http://114.204.195.233';

  // Fetch festival accounts
  static Future<List<dynamic>> fetchFestivalAccounts() async {
    final response = await http.get(Uri.parse('$baseUrl/festivalAccounts'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load festival accounts');
    }
  }

  // Create a festival account
  static Future<void> createFestivalAccount(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'role': 'festival',
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create festival account');
    }
  }

  // Update a festival account
  static Future<void> updateFestivalAccount(int id, String username, String password) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update festival account');
    }
  }

  // Add a festival product
  static Future<void> addFestivalProduct(int festivalId, String name, double price) async {
    final response = await http.post(
      Uri.parse('$baseUrl/festivalProducts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'festivalId': festivalId,
        'name': name,
        'price': price,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add festival product');
    }
  }

  // Update a festival product
  static Future<void> updateFestivalProduct(int id, String name, double price) async {
    final response = await http.put(
      Uri.parse('$baseUrl/festivalProducts/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'price': price,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update festival product');
    }
  }

  // Fetch festival products
  static Future<List<dynamic>> fetchFestivalProducts(int festivalId) async {
    final response = await http.get(Uri.parse('$baseUrl/festivalProducts?festivalId=$festivalId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load festival products');
    }
  }

  // QR 결제를 처리하는 메서드
  static Future<Map<String, dynamic>> processQrPayment(int userId, int productId, int festivalId) async {
    return await _processFestivalPurchase(userId, productId, festivalId);
  }

  // NFC 결제를 처리하는 메서드
  static Future<Map<String, dynamic>> processNfcPayment(int userId, int productId, int festivalId) async {
    return await _processFestivalPurchase(userId, productId, festivalId);
  }

  // 공통 결제 로직
  static Future<Map<String, dynamic>> _processFestivalPurchase(int userId, int productId, int festivalId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/festival-purchase'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'productId': productId,
        'festivalId': festivalId,
      }),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'message': 'Payment successful'};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? 'Payment failed'};
    }
  }

  // Fetch user information by card ID
  static Future<Map<String, dynamic>> fetchUserByCard(String cardId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/by-card/$cardId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user information');
    }
  }

  // 사용자 정보 가져오기
  static Future<Map<String, dynamic>> fetchUserData(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user data. Status code: ${response.statusCode}');
    }
  }

  // 축제 제품 목록 가져오기
  static Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/festivalProducts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products. Status code: ${response.statusCode}');
    }
  }

  // Fetch user information by card ID
  static Future<Map<String, dynamic>> getUserIdByCard(String cardId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/by-card/$cardId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user information by card ID');
    }
  }


}
