import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bpa_app/core/network/api_endpoints.dart';

class AuthRemoteDataSource {
  bool _isEmail(String s) => s.contains('@');
  bool _isPhone(String s) => RegExp(r'^[0-9]+$').hasMatch(s);

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final id = identifier.trim();
    final body = <String, dynamic>{
      'password': password,
      // ✅ backend যেভাবেই handle করুক, আমরা safe ভাবে দুটোই পাঠাচ্ছি
      'email': _isEmail(id) ? id : '',
      'phone': _isPhone(id) ? id : '',
    };

    final uri = Uri.parse(ApiEndpoints.login());

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (data is Map<String, dynamic>) return data;
      throw Exception('Invalid response');
    }

    final message = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : 'Login failed';
    throw Exception(message);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String identifier,
    required String password,
  }) async {
    final id = identifier.trim();

    final body = <String, dynamic>{
      'name': name,
      'password': password,
      'email': _isEmail(id) ? id : '',
      'phone': _isPhone(id) ? id : '',
      'address': '',
    };

    final uri = Uri.parse(ApiEndpoints.register());
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (data is Map<String, dynamic>) return data;
      return {'success': true};
    }

    final message = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : 'Registration failed';
    throw Exception(message);
  }
}
