import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AdminApi {
  static String token = '';
  static String get base => kIsWeb ? 'http://localhost:5000/api' : 'http://10.0.2.2:5000/api';

  Future<dynamic> req(String method, String path, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$base$path');
      final headers = {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      http.Response res;
      if (method == 'POST') {
        res = await http.post(uri, headers: headers, body: jsonEncode(body));
      } else if (method == 'PUT') {
        res = await http.put(uri, headers: headers, body: jsonEncode(body));
      } else {
        res = await http.get(uri, headers: headers);
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        // Lưu token tự động khi login thành công
        if (data is Map<String, dynamic> && data.containsKey('token')) {
          token = data['token'];
        }
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}