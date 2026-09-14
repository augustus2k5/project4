import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import '../models/specialty_model.dart';
import 'token_manager.dart';
class ApiService {
  // =========================
  // BASE URL
  // =========================
  // Chạy Flutter trên Chrome cùng máy với Backend
  static const String baseUrl = 'http://localhost:5000/api';

  // Nếu chạy Android Emulator:
  // static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Nếu chạy điện thoại thật:
  // static const String baseUrl = 'http://IP_MAY_TINH:5000/api';

  // ============================================================
  // ĐĂNG NHẬP ADMIN
  // POST /api/auth/login
  // ============================================================
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
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
  // GET /api/users
  // ============================================================
  // ============================================================
  // LẤY DANH SÁCH USER
  // GET /api/users
  // ============================================================
  static Future<List<UserModel>> getUsers() async {
    final token = await TokenManager.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => UserModel.fromJson(json)).toList();
    }

    throw Exception('Không thể lấy danh sách người dùng');
  }

  // ============================================================
  // XÓA USER
  // DELETE /api/users/:id
  // ============================================================
  static Future<bool> deleteUser(String id) async {
    final token = await TokenManager.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  // ============================================================
  // KHÓA USER
  // PUT /api/users/:id/block
  // ============================================================
  static Future<bool> blockUser(String id) async {
    final token = await TokenManager.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id/block'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  // ============================================================
  // MỞ KHÓA USER
  // PUT /api/users/:id/unblock
  // ============================================================
  static Future<bool> unblockUser(String id) async {
    final token = await TokenManager.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id/unblock'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  // ============================================================
  // LẤY DANH SÁCH CHUYÊN KHOA
  // GET /api/specialties
  // ============================================================
  static Future<List<Specialty>> getSpecialties() async {
    final token = await TokenManager.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/specialties'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Specialty.fromJson(json)).toList();
    }

    throw Exception('Không thể lấy danh sách chuyên khoa');
  }

  // ============================================================
  // THÊM CHUYÊN KHOA
  // POST /api/specialties
  // ============================================================
  static Future<bool> createSpecialty({
    required String name,
    required String description,
    required String status,
  }) async {
    final token = await TokenManager.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/specialties'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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
  // PUT /api/specialties/:id
  // ============================================================
  static Future<bool> updateSpecialty({
    required String id,
    required String name,
    required String description,
    required String status,
  }) async {
    final token = await TokenManager.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/specialties/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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
  // DELETE /api/specialties/:id
  // ============================================================
  static Future<bool> deleteSpecialty(String id) async {
    final token = await TokenManager.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/specialties/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }
}