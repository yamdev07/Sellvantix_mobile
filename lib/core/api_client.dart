import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ApiClient {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  static Map<String, String> _headers({String? token}) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return _headers(token: token);
  }

  // ── GET ──────────────────────────────────────────────────────────────────

  static Future<dynamic> get(String path) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final res = await http.get(uri, headers: headers);
    return _parse(res);
  }

  // ── POST ─────────────────────────────────────────────────────────────────

  static Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final headers = auth ? await _authHeaders() : _headers();
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final res = await http.post(uri, headers: headers, body: jsonEncode(body));
    return _parse(res);
  }

  // ── parse ─────────────────────────────────────────────────────────────────

  static dynamic _parse(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    final msg = body['message'] ?? 'Erreur serveur (${res.statusCode})';
    throw ApiException(msg, res.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
