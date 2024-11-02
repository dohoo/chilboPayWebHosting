import 'package:http/http.dart' as http;
import 'dart:convert';

class FestivalApi {
  static const String baseUrl = 'http://114.204.195.233';

  // 축제 계정 목록 가져오기
  static Future<List<dynamic>> fetchFestivalAccounts() async {
    final response = await http.get(Uri.parse('$baseUrl/festivalAccounts'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load festival accounts');
    }
  }

  // 축제 계정 생성
  static Future<void> createFestivalAccount(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'password': password, 'role': 'festival'}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create festival account');
    }
  }

  // 축제 계정 업데이트
  static Future<void> updateFestivalAccount(int id, String username, String password) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update festival account');
    }
  }

  // 축제 상품 추가
  static Future<void> addFestivalProduct(int festivalId, String name, double price) async {
    final response = await http.post(
      Uri.parse('$baseUrl/festivalProducts'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'festivalId': festivalId, 'name': name, 'price': price}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add festival product');
    }
  }

  // 축제 상품 업데이트
  static Future<void> updateFestivalProduct(int id, String name, double price) async {
    final response = await http.put(
      Uri.parse('$baseUrl/festivalProducts/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'name': name, 'price': price}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update festival product');
    }
  }

  // 축제 상품 목록 가져오기
  static Future<List<dynamic>> fetchFestivalProducts(int festivalId) async {
    final response = await http.get(Uri.parse('$baseUrl/festivalProducts?festivalId=$festivalId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load festival products');
    }
  }

  // QR 결제를 처리하는 메서드 (activity와 product 구분)
  static Future<Map<String, dynamic>> processQrPaymentWithToken(String token, int id, bool isActivity) async {
    return isActivity
        ? await _processFestivalActivityPurchaseByToken(token, id)
        : await _processFestivalPurchaseByToken(token, id);
  }

  // 공통 결제 로직 (QR용 - Product)
  static Future<Map<String, dynamic>> _processFestivalPurchaseByToken(String token, int productId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/festivalPurchaseWithToken'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'token': token, 'productId': productId}),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'message': '결제 성공'};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? '결제 실패'};
    }
  }

  // 공통 결제 로직 (QR용 - Activity)
  static Future<Map<String, dynamic>> _processFestivalActivityPurchaseByToken(String token, int activityId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/festivalActivityPurchaseWithToken'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'token': token, 'activityId': activityId}),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'message': '결제 성공'};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? '결제 실패'};
    }
  }

  // NFC 결제를 처리하는 메서드 (activity와 product 구분)
  static Future<Map<String, dynamic>> processNfcPayment(int userId, int id, int festivalId, bool isActivity) async {
    return isActivity
        ? await _processFestivalActivityPurchase(userId, id, festivalId)
        : await _processFestivalPurchase(userId, id, festivalId);
  }

  // 공통 결제 로직 (NFC용 - Product)
  static Future<Map<String, dynamic>> _processFestivalPurchase(int userId, int productId, int festivalId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/festival-purchase'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'userId': userId, 'productId': productId, 'festivalId': festivalId}),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'message': '결제 성공'};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? '결제 실패'};
    }
  }

  // 공통 결제 로직 (NFC용 - Activity)
  static Future<Map<String, dynamic>> _processFestivalActivityPurchase(int userId, int activityId, int festivalId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/festivalActivityPurchase'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'userId': userId, 'activityId': activityId, 'festivalId': festivalId}),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'message': '결제 성공'};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? '결제 실패'};
    }
  }

  // 카드 ID로 사용자 정보 가져오기
  static Future<Map<String, dynamic>> fetchUserByCard(String cardId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/by-card/$cardId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
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
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user data. Status code: ${response.statusCode}');
    }
  }

  // 모든 축제 제품 목록 가져오기
  static Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/festivalProducts'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products. Status code: ${response.statusCode}');
    }
  }

  // 특정 username으로 축제 제품 목록 가져오기
  static Future<List<dynamic>> fetchFestivalProductsByUsername(String username) async {
    final response = await http.get(Uri.parse('$baseUrl/festival-products/$username'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load festival products');
    }
  }

  // 축제 활동 목록 가져오기
  static Future<List<dynamic>> fetchFestivalActivities(int festivalId) async {
    final response = await http.get(Uri.parse('$baseUrl/festivalActivities?festivalId=$festivalId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load festival activities');
    }
  }

  // 축제 활동 추가하기
  static Future<void> addFestivalActivity(int festivalId, String name, int price) async {
    final response = await http.post(
      Uri.parse('$baseUrl/festivalActivities'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'festivalId': festivalId, 'name': name, 'price': price}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add festival activity');
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
