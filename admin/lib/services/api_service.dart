import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../models/specialty_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  // ============================================================
  // HÀM BỔ TRỢ: LẤY HEADER CÓ ĐẮM KÈM TOKEN XÁC THỰC
  // ============================================================
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // ĐĂNG NHẬP ADMIN & LƯU TOKEN
  // ============================================================
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Tự động lưu Token vào bộ nhớ máy sau khi đăng nhập thành công
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
        }

        return {
          'success': true,
          'message': data['message'],
          'token': data['token'],
          'user': data['user'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Đăng nhập thất bại',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối đến máy chủ',
      };
    }
  }

  // ============================================================
  // LẤY DANH SÁCH USER
  // ============================================================
  static Future<List<UserModel>> getUsers() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => UserModel.fromJson(json)).toList();
    }

    throw Exception('Không thể lấy danh sách người dùng');
  }

  // ============================================================
  // XÓA USER
  // ============================================================
  static Future<bool> deleteUser(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: headers,
    );

    return response.statusCode == 200;
  }

  // ============================================================
  // KHÓA USER
  // ============================================================
  static Future<bool> blockUser(String id) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id/block'),
      headers: headers,
    );

    return response.statusCode == 200;
  }

  // ============================================================
  // MỞ KHÓA USER
  // ============================================================
  static Future<bool> unblockUser(String id) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id/unblock'),
      headers: headers,
    );

    return response.statusCode == 200;
  }

  // ============================================================
  // LẤY DANH SÁCH CHUYÊN KHOA
  // ============================================================
  static Future<List<Specialty>> getSpecialties() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/specialties'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Specialty.fromJson(json)).toList();
    }

    throw Exception('Không thể lấy danh sách chuyên khoa');
  }

  // ============================================================
  // THÊM CHUYÊN KHOA
  // ============================================================
  static Future<bool> createSpecialty({
    required String name,
    required String description,
    required String status,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/specialties'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'description': description,
        'status': status,
      }),
    );

    return response.statusCode == 201;
  }

  // ============================================================
  // SỬA CHUYÊN KHOA
  // ============================================================
  static Future<bool> updateSpecialty({
    required String id,
    required String name,
    required String description,
    required String status,
  }) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/specialties/$id'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'description': description,
        'status': status,
      }),
    );

    return response.statusCode == 200;
  }

  // ============================================================
  // XÓA CHUYÊN KHOA
  // ============================================================
  static Future<bool> deleteSpecialty(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/specialties/$id'),
      headers: headers,
    );

    return response.statusCode == 200;
  }

  // ============================================================
  // ĐĂNG XUẤT (XÓA TOKEN)
  // ============================================================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}