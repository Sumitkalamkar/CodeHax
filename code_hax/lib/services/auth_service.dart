import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class AuthService {
  static const String _tokenKey = 'codehax_token';
  static const String _userKey = 'codehax_user';
  static const String _baseUrl = AppConstants.backendUrl;
  
  final _storage = const FlutterSecureStorage();
  
  // User signup
  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token
        await _storage.write(
          key: _tokenKey,
          value: data['access_token'],
        );
        
        // Save user
        await _storage.write(
          key: _userKey,
          value: jsonEncode(data['user']),
        );
        
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // User login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token
        await _storage.write(
          key: _tokenKey,
          value: data['access_token'],
        );
        
        // Save user
        await _storage.write(
          key: _userKey,
          value: jsonEncode(data['user']),
        );
        
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ✅ SEND OTP (ADDED)
  Future<void> sendOtp(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to send OTP");
    }
  }

  // ✅ VERIFY OTP (ADDED)
  Future<void> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Invalid OTP");
    }
  }

  // Get stored token
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  // Get stored user
  Future<Map<String, dynamic>?> getUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson != null) {
        return jsonDecode(userJson);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Verify token
  Future<bool> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/verify'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && (await verifyToken());
  }

  // Get authorization header
  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}

final authService = AuthService();