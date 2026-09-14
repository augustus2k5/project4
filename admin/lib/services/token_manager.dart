import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'auth_token';

  // 1. LƯU TOKEN
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // 2. LẤY TOKEN
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 3. XÓA TOKEN
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // 4. KIỂM TRA ĐÃ ĐĂNG NHẬP CHƯA
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}