import 'package:http/http.dart' as http;
import 'dart:convert';

class FestivalApi {
  static const String baseUrl = 'https://api.chilbopay.com';

  static Future<List<dynamic>> fetchFestivalAccounts() async {
    final response = await http.get(Uri.parse('$baseUrl/festivalAccounts'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load festival accounts');
    }
  }

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

  static Future<List<dynamic>> fetchFestivalProducts(int festivalId) async {
    final response = await http.get(Uri.parse('$baseUrl/festivalProducts?festivalId=$festivalId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load festival products');
    }
  }

  static Future<Map<String, dynamic>> processQrPaymentWithToken(String token, int id, bool isActivity) async {
    return isActivity
        ? await _processFestivalActivityPurchaseByToken(token, id)
        : await _processFestivalPurchaseByToken(token, id);
  }

  static Future<Map<String, dynamic>> _processFestivalPurchaseByToken(String token, int productId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/festivalPurchaseWithToken'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'token': token, 'productId': productId, 'type': 'festival-purchase'}),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'message': '결제 성공'};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? '결제 실패'};
    }
  }

  static Future<Map<String, dynamic>> _processFestivalActivityPurchaseByToken(String token, int activityId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/festivalActivityPurchaseWithToken'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'token': token, 'activityId': activityId, 'type': 'festival-activity'}),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'message': '결제 성공'};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? '결제 실패'};
    }
  }

  static Future<Map<String, dynamic>> processNfcPayment(int userId, int id, int festivalId, bool isActivity) async {
    return isActivity
        ? await _processFestivalActivityPurchase(userId, id, festivalId)
        : await _processFestivalPurchase(userId, id, festivalId);
  }

  static Future<Map<String, dynamic>> _processFestivalPurchase(int userId, int productId, int festivalId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/festival-purchase'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'userId': userId, 'productId': productId, 'festivalId': festivalId, 'type': 'festival-purchase'}),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'message': '결제 성공'};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? '결제 실패'};
    }
  }

  static Future<Map<String, dynamic>> _processFestivalActivityPurchase(int userId, int activityId, int festivalId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/festivalActivityPurchase'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'userId': userId, 'activityId': activityId, 'festivalId': festivalId, 'type': 'festival-activity'}),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'message': '결제 성공'};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? '결제 실패'};
    }
  }

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

  static Future<List<dynamic>> fetchFestivalProductsByUsername(String username) async {
    final response = await http.get(Uri.parse('$baseUrl/festival-products/$username'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load festival products');
    }
  }

  // *** 수정된 부분 ***
  // 이제 서버에서 {activityCount: number, activities: [...] } 형태로 응답하므로
  // Map<String, dynamic> 형태를 반환하고, 호출하는 곳에서 activityCount와 activities를 분리한다.
  static Future<Map<String, dynamic>> fetchFestivalActivities(int festivalId) async {
    final response = await http.get(Uri.parse('$baseUrl/festivalActivities?festivalId=$festivalId'));

    if (response.statusCode == 200) {
      // 응답 예: { "activityCount": 50, "activities": [ {..}, {..} ] }
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load festival activities');
    }
  }

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
