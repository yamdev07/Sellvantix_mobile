import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user    => _user;
  bool get loading       => _loading;
  String? get error      => _error;
  bool get isLoggedIn    => _user != null;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final userJson = prefs.getString(AppConstants.userKey);
    if (token == null || userJson == null) return;

    // Restaure depuis le cache d'abord (UX rapide)
    _user = UserModel.fromJson(jsonDecode(userJson));
    notifyListeners();

    // Puis rafraîchit depuis l'API
    try {
      final res = await ApiClient.get('/me');
      _user = UserModel.fromJson(res['user'] ?? res);
      await prefs.setString(AppConstants.userKey, jsonEncode(res['user'] ?? res));
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiClient.post('/login', {
        'email': email,
        'password': password,
      }, auth: false);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, res['token']);
      await prefs.setString(AppConstants.userKey, jsonEncode(res['user']));

      _user = UserModel.fromJson(res['user']);
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Impossible de contacter le serveur. Vérifiez votre connexion.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.post('/logout', {});
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    _user = null;
    notifyListeners();
  }
}
