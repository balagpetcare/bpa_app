import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<Map<String, String>> _headers({required bool auth}) async {
    final headers = <String, String>{"Content-Type": "application/json"};
    if (auth) {
      final t = await _token();
      if (t == null || t.isEmpty) {
        throw Exception("Token not found. Please login again.");
      }
      headers["Authorization"] = "Bearer $t";
    }
    return headers;
  }

  dynamic _safeDecode(String body) {
    if (body.trim().isEmpty) return {};
    try {
      return jsonDecode(body);
    } catch (_) {
      return {"raw": body};
    }
  }

  dynamic _handle(http.Response res) {
    final decoded = _safeDecode(res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded;
    }

    final msg = (decoded is Map && decoded["message"] != null)
        ? decoded["message"].toString()
        : "API Error";

    throw Exception("$msg (${res.statusCode})");
  }

  Future<dynamic> get(String url, {bool auth = true}) async {
    final res = await http.get(
      Uri.parse(url),
      headers: await _headers(auth: auth),
    );
    return _handle(res);
  }

  Future<dynamic> post(
    String url,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final res = await http.post(
      Uri.parse(url),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<dynamic> patch(
    String url,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final res = await http.patch(
      Uri.parse(url),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<dynamic> multipartPost({
    required String url,
    required String fieldName,
    required String filePath,
    bool auth = true,
    Map<String, String>? fields,
  }) async {
    final req = http.MultipartRequest("POST", Uri.parse(url));

    if (auth) {
      final t = await _token();
      if (t == null || t.isEmpty) {
        throw Exception("Token not found. Please login again.");
      }
      req.headers["Authorization"] = "Bearer $t";
    }

    if (fields != null) req.fields.addAll(fields);
    req.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
      return _safeDecode(body);
    }

    final decoded = _safeDecode(body);
    final msg = (decoded is Map && decoded["message"] != null)
        ? decoded["message"].toString()
        : "Upload Error";

    throw Exception("$msg (${streamed.statusCode})");
  }
}
