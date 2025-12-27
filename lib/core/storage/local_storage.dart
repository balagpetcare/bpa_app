import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _kToken = 'token';
  static const _kUserName = 'userName';
  static const _kUserEmail = 'userEmail';

  static Future<void> saveAuth({
    required String token,
    required String userName,
    required String userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setString(_kUserName, userName);
    await prefs.setString(_kUserEmail, userEmail);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUserName);
    await prefs.remove(_kUserEmail);
  }
}
