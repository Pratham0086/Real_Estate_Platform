// frontend/lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _token;
  Map<String, dynamic>? _user; // Store the full user object

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  Map<String, dynamic>? get user => _user; // Getter for user info

  String? get userId => _user?['id'];
  String? get userRole => _user?['role']; // Getter for the user's role

  AuthProvider() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final savedToken = await _authService.getToken();
    if (savedToken != null) {
      _token = savedToken;
      _user = _decodeToken(savedToken);
      notifyListeners();
    }
  }

  Map<String, dynamic>? _decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      return payload;
    } catch (e) {
      return null;
    }
  }

  // in frontend/lib/providers/auth_provider.dart

  Future<bool> login(String loginId, String password, String role) async {
    final result = await _authService.login(loginId, password, role);
    if (result.containsKey('token') && result.containsKey('user')) {
      _token = result['token'];
      _user = result['user'];
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _token = null;
    _user = null;
    _authService.logout();
    notifyListeners();
  }
}