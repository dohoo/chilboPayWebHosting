import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../screens/login/login_page.dart';

class ApiService {
  static const String baseUrl = 'https://chilbopay.com';

  // Helper function to get token from SharedPreferences
  static Future<String?> _getToken(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // Helper function to save tokens to SharedPreferences
  static Future<void> _saveTokens(String accessToken, String refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  // Helper function to clear tokens from SharedPreferences
  static Future<void> _clearTokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // Helper function to refresh access token using refresh token
  static Future<void> _refreshAccessToken(BuildContext context) async {
    String? refreshToken = await _getToken('refresh_token');

    if (refreshToken == null) {
      throw Exception('No refresh token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/token'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'token': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveTokens(data['accessToken'], refreshToken);
    } else {
      throw Exception('Refresh token expired or invalid');
    }
  }

  // Public function to make authenticated requests
  static Future<http.Response> makeAuthenticatedRequest(
      BuildContext context, Future<http.Response> Function(String accessToken) requestFunction) async {
    String? accessToken = await _getToken('access_token');
    if (accessToken == null) {
      throw Exception('No access token found');
    }

    if (JwtDecoder.isExpired(accessToken)) {
      try {
        await _refreshAccessToken(context);
        accessToken = await _getToken('access_token');
        if (accessToken == null) {
          throw Exception('No access token found after refresh');
        }
      } catch (e) {
        await logout(context);
        throw Exception('Refresh token expired or invalid');
      }
    }

    http.Response response = await requestFunction(accessToken);

    if (response.statusCode == 401) {
      try {
        await _refreshAccessToken(context);
        accessToken = await _getToken('access_token');
        if (accessToken == null) {
          throw Exception('No access token found after refresh');
        }
        response = await requestFunction(accessToken);
      } catch (e) {
        await logout(context);
        throw Exception('Refresh token expired or invalid');
      }
    }

    return response;
  }

  // Public function to logout
  static Future<void> logout(BuildContext context) async {
    await _clearTokens();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Fetch all users
  static Future<List<dynamic>> fetchUsers(BuildContext context) async {
    final response = await makeAuthenticatedRequest(context, (accessToken) {
      return http.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Update user
  static Future<http.Response> updateUser(BuildContext context, int id, String username, int money) async {
    return await makeAuthenticatedRequest(context, (accessToken) {
      return http.put(
        Uri.parse('$baseUrl/user/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, dynamic>{
          'username': username,
          'money': money,
        }),
      );
    });
  }

  // Delete user
  static Future<http.Response> deleteUser(BuildContext context, int id) async {
    return await makeAuthenticatedRequest(context, (accessToken) {
      return http.delete(
        Uri.parse('$baseUrl/user/$id'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
    });
  }

  // Suspend user
  static Future<http.Response> suspendUser(BuildContext context, int id) async {
    return await makeAuthenticatedRequest(context, (accessToken) {
      return http.put(
        Uri.parse('$baseUrl/user/suspend/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );
    });
  }

  // Unsuspend user
  static Future<http.Response> unsuspendUser(BuildContext context, int id) async {
    return await makeAuthenticatedRequest(context, (accessToken) {
      return http.put(
        Uri.parse('$baseUrl/user/unsuspend/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );
    });
  }

  // Fetch all products
  static Future<List<dynamic>> fetchProducts(BuildContext context) async {
    final response = await makeAuthenticatedRequest(context, (accessToken) {
      return http.get(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Add product
  static Future<http.Response> addProduct(BuildContext context, String name, double price) async {
    return await makeAuthenticatedRequest(context, (accessToken) {
      return http.post(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'price': price,
        }),
      );
    });
  }

  // Update product
  static Future<http.Response> updateProduct(BuildContext context, int id, String name, double price) async {
    return await makeAuthenticatedRequest(context, (accessToken) {
      return http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'price': price,
        }),
      );
    });
  }

  // Delete product
  static Future<http.Response> deleteProduct(BuildContext context, int id) async {
    return await makeAuthenticatedRequest(context, (accessToken) {
      return http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
    });
  }
}
