// frontend/lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // For Android Emulator, the host machine's localhost is 10.0.2.2
  // For iOS Simulator, it's localhost or 127.0.0.1
  final String _baseUrl = "http://192.168.31.107:3000/api/users";
  final _storage = const FlutterSecureStorage();

  // Register User
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  // Login User
  // in frontend/lib/services/auth_service.dart

  Future<Map<String, dynamic>> login(String loginId, String password, String role) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'loginId': loginId,
        'password': password,
        'role': role,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['token'] != null) {
      await _storage.write(key: 'jwt_token', value: data['token']);
    }

    return data;
  }

  // Logout User
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  // Get saved token
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
  
  // Register with additional details
  Future<Map<String, dynamic>> registerWithDetails(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }
}