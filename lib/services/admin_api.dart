import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminApi {
  static const String baseUrl = 'http://114.204.195.233';

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

  // Process NFC payment
  static Future<Map<String, dynamic>> processPayment(int userId, int productId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/purchase'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'productId': productId,
      }),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'message': 'NFC card payment successful'};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message']};
    }
  }

  // Fetch total user money
  static Future<int> fetchTotalUserMoney() async {
    final response = await http.get(Uri.parse('$baseUrl/totalUserMoney'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return int.parse(jsonResponse['total']);
    } else {
      throw Exception('Failed to load total user money');
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

  // Update user
  static Future<http.Response> updateUser(int id, String username, int money) async {
    return await http.put(
      Uri.parse('$baseUrl/user/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'username': username,
        'money': money,
      }),
    );
  }

  // Delete user
  static Future<http.Response> deleteUser(int id) async {
    return await http.delete(
      Uri.parse('$baseUrl/user/$id'),
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
}
