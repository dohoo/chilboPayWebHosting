import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminApi {
  static const String baseUrl = 'https://api.chilbopay.com';

  // Fetch all products
  static Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Add product
  static Future<http.Response> addProduct(String name, double price) async {
    return await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'price': price,
      }),
    );
  }

  // Update product
  static Future<http.Response> updateProduct(int id, String name, double price) async {
    return await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'price': price,
      }),
    );
  }

  // Delete product
  static Future<http.Response> deleteProduct(int id) async {
    return await http.delete(
      Uri.parse('$baseUrl/products/$id'),
    );
  }

  // Fetch user by NFC card
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

  // Process NFC payment with type "purchase"
  static Future<Map<String, dynamic>> processPayment(int userId, int productId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/purchase'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'productId': productId,
        'type': 'purchase', // Specify transaction type as "purchase"
      }),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'message': 'NFC card payment successful'};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message']};
    }
  }

  // Fetch total money for users and festivals
  static Future<Map<String, dynamic>> fetchTotalMoney() async {
    final response = await http.get(Uri.parse('$baseUrl/totalMoney'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load total money');
    }
  }

  // Fetch all transactions
  static Future<List<dynamic>> fetchTransactions() async {
    final response = await http.get(Uri.parse('$baseUrl/transactions'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load transactions: ${response.statusCode}');
    }
  }

  // Fetch all users
  static Future<List<dynamic>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load users. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw e;
    }
  }

  // Update user (activityCount 추가)
  static Future<http.Response> updateUser(
      int id,
      String username,
      int money, {
        String? password,
        String? status,
        int? activityCount, // 추가
      }) async {
    final Map<String, dynamic> payload = {
      'username': username,
      'money': money,
    };

    if (password != null) {
      payload['password'] = password;
    }
    if (status != null) {
      payload['status'] = status;
    }
    if (activityCount != null) {
      payload['activityCount'] = activityCount; // activityCount 추가
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(payload),
      );
      return response;
    } catch (e) {
      print('Error in updateUser: $e');
      rethrow;
    }
  }

  // Delete user (Admin)
  static Future<http.Response> deleteUser(int id) async {
    return await http.post(
      Uri.parse('$baseUrl/admin/user/$id/delete'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_ADMIN_TOKEN', // include authorization if required
      },
    );
  }

  // Suspend user
  static Future<http.Response> suspendUser(int id) async {
    return await http.put(
      Uri.parse('$baseUrl/user/suspend/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }

  // Unsuspend user
  static Future<http.Response> unsuspendUser(int id) async {
    return await http.put(
      Uri.parse('$baseUrl/user/unsuspend/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }

  // Create an account
  static Future<void> createAccount(
      String role,
      String username,
      String password,
      int money,
      List<Map<String, dynamic>> products,
      List<Map<String, dynamic>> activities,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/createAccount'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'role': role,
        'username': username,
        'password': password,
        'points': money,
        'products': products,
        'activities': activities,  // activities 추가
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create account');
    }
  }

  // Change password
  static Future<void> changePassword(int userId, String oldPassword, String newPassword) async {
    final response = await http.put(
      Uri.parse('$baseUrl/changePassword'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'userId': userId,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to change password');
    }
  }

  // Process NFC payment with token and specify type "purchase"
  static Future<Map<String, dynamic>> processPaymentWithToken(String token, int productId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/purchaseWithToken'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'productId': productId,
        'type': 'purchase'
      }),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'message': 'Payment successful'};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'message': error['message']};
    }
  }

  // 사용자 제품 및 활동 업데이트
  static Future<void> updateUserProductsAndActivities(
      int userId, List<Map<String, dynamic>> products, List<Map<String, dynamic>> activities) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/$userId/products-activities'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'products': products,
        'activities': activities,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update products and activities');
    }
  }

  // 축제 제품 목록 가져오기
  static Future<List<dynamic>> fetchFestivalProducts(int festivalId) async {
    final response = await http.get(Uri.parse('$baseUrl/festivalProducts?festivalId=$festivalId'));

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
      final data = jsonDecode(response.body);
      // data는 { "activityCount": number, "activities": [ ... ] } 형태라고 가정
      return data['activities']; // 'activities' 키에 해당하는 리스트 반환
    } else {
      throw Exception('Failed to load festival activities');
    }
  }


  // Fetch admin password
  static Future<bool> verifyAdminPassword(String inputPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verifyAdminPassword'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'password': inputPassword}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isValid'];
    } else {
      throw Exception('Failed to verify password');
    }
  }
}
