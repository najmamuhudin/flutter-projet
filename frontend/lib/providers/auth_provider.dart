import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;

  bool get isAuthenticated => _user != null;

  // Check if user is already logged in on app start
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user')) return;

    final userData =
        jsonDecode(prefs.getString('user')!) as Map<String, dynamic>;
    _user = userData;
    notifyListeners();
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String studentId,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _authService.register(
        name,
        email,
        password,
        studentId,
      );
      _user = data;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _authService.login(email, password);
      _user = data;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
