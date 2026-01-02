import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bpa_app/core/network/api_config.dart';
import 'models/user_profile_model.dart';

class ProfileService {
  Future<String?> _token() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString("token");
  }

  Future<UserProfileModel> getProfile() async {
    final token = await _token();
    if (token == null) throw Exception("Unauthorized. Please login again.");

    // ✅ Main endpoint
    final uri = Uri.parse("${ApiConfig.apiV1}/user/me");

    final res = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token"},
    );

    // Optional fallback if your server only has /user/profile
    if (res.statusCode == 404) {
      final fallback = await http.get(
        Uri.parse("${ApiConfig.apiV1}/user/profile"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (fallback.statusCode != 200) {
        throw Exception(_friendlyError(fallback));
      }
      final data = jsonDecode(fallback.body);
      return UserProfileModel.fromApi(data as Map<String, dynamic>);
    }

    if (res.statusCode != 200) {
      throw Exception(_friendlyError(res));
    }

    final data = jsonDecode(res.body);
    return UserProfileModel.fromApi(data as Map<String, dynamic>);
  }

  String _friendlyError(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      final msg = body["message"]?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    } catch (_) {}
    if (res.statusCode == 401) return "Unauthorized. Please login again.";
    if (res.statusCode == 404) return "Profile not found.";
    return "Failed to load profile. Please try again.";
  }


Future<UserProfileModel> updateProfile(Map<String, dynamic> payload) async {
  final token = await _token();
  if (token == null) throw Exception("Unauthorized. Please login again.");

  final uri = Uri.parse("${ApiConfig.apiV1}/user/profile");

  final res = await http.patch(
    uri,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode(payload),
  );

  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw Exception("Profile update failed: ${res.statusCode} ${res.body}");
  }

  final decoded = jsonDecode(res.body);
  final data = (decoded["data"] as Map?)?.cast<String, dynamic>();
  if (data == null) throw Exception("Invalid update response");

  // reuse same parser as getProfile()
    return UserProfileModel.fromApi(decoded);
}

}
