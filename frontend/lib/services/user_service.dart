// frontend/lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String _baseUrl = "http://192.168.31.107:3000/api/users"; // Use your local IP

  Future<List<dynamic>> getCustomers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/customers'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }
  Future<List<dynamic>> getBrokers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/brokers'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }
}