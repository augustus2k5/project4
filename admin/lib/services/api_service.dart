import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import '../models/specialty_model.dart';
class ApiService {
  // Nếu chạy Android Emulator
 static const String baseUrl = 'http://localhost:5000/api';

  // Nếu chạy điện thoại thật thì đổi thành:
  // static const String baseUrl = 'http://IP_MAY_TINH:5000/api';

  // =========================
  // LẤY DANH SÁCH USER
  // =========================
  static Future<List<UserModel>> getUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((json) => UserModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Không thể lấy danh sách người dùng');
    }
  }

  // =========================
  // XÓA USER
  // =========================
  static Future<bool> deleteUser(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
    );

    return response.statusCode == 200;
  }

  // =========================
  // KHÓA USER
  // =========================
  static Future<bool> blockUser(String id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id/block'),
    );

    return response.statusCode == 200;
  }

  // =========================
  // MỞ KHÓA USER
  // =========================
  static Future<bool> unblockUser(String id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id/unblock'),
    );

    return response.statusCode == 200;
  }
  // ===============================
// CHUYÊN KHOA
// ===============================

static Future<List<Specialty>> getSpecialties() async {
  final response = await http.get(
    Uri.parse('$baseUrl/specialties'),
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);

    return data
        .map((json) => Specialty.fromJson(json))
        .toList();
  }

  throw Exception(
    'Không thể lấy danh sách chuyên khoa',
  );
}

static Future<bool> createSpecialty({
  required String name,
  required String description,
  required String status,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/specialties'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': name,
      'description': description,
      'status': status,
    }),
  );

  return response.statusCode == 201;
}

static Future<bool> updateSpecialty({
  required String id,
  required String name,
  required String description,
  required String status,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/specialties/$id'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': name,
      'description': description,
      'status': status,
    }),
  );

  return response.statusCode == 200;
}

static Future<bool> deleteSpecialty(String id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/specialties/$id'),
  );

  return response.statusCode == 200;
}
}