import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl =>
      kIsWeb ? 'http://localhost:5000/api' : 'http://10.0.2.2:5000/api';

  static Map<String, String> headers([String? token]) =>
      {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  static Future<dynamic> get(String path, {String? token}) async {
    final r = await http.get(
        Uri.parse('$baseUrl$path'), headers: headers(token));
    return _decode(r);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body,
      {String? token}) async {
    final r = await http.post(
        Uri.parse('$baseUrl$path'), headers: headers(token),
        body: jsonEncode(body));
    return _decode(r);
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body,
      {String? token}) async {
    final r = await http.patch(
        Uri.parse('$baseUrl$path'), headers: headers(token),
        body: jsonEncode(body));
    return _decode(r);
  }

  static dynamic _decode(http.Response r) {
    dynamic data;
    try {
      data = jsonDecode(r.body);
    } catch (_) {
      data = {'message': r.body};
    }
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception(
          data is Map ? (data['message'] ?? 'Có lỗi xảy ra') : 'Có lỗi xảy ra');
    }
    return data;
  }
}
