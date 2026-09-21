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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
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
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
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

  // ============================================================
  // LẤY TẤT CẢ LỊCH HẸN
  // GET /api/appointments
  // ============================================================
  static Future<List<dynamic>> getAppointments() async {
    final token = await TokenManager.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/appointments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Không thể tải danh sách lịch hẹn');
  }

  // ============================================================
  // CẬP NHẬT TRẠNG THÁI LỊCH HẸN
  // PATCH /api/appointments/:id/status
  // ============================================================
  static Future<bool> updateAppointmentStatus({
    required String id,
    required String status,
  }) async {
    final token = await TokenManager.getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/appointments/$id/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );
    return response.statusCode == 200;
  }
  static Future<List<dynamic>> getDoctors() async {
    final token = await TokenManager.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/doctors'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      throw Exception(
        'Dữ liệu bác sĩ không hợp lệ',
      );
    }

    String message =
        'Không thể lấy danh sách bác sĩ';

    try {
      final data = jsonDecode(response.body);

      if (data is Map &&
          data['message'] != null) {
        message = data['message'].toString();
      }
    } catch (_) {}

    throw Exception(
      '$message (${response.statusCode})',
    );
  }

  // ------------------------------------------------------------
  // THÊM BÁC SĨ
  // POST /api/doctors
  // ------------------------------------------------------------

  static Future<bool> createDoctor({
    required String userId,
    required String specialtyId,
    required double price,
    required String bio,
    required int experienceYears,
  }) async {
    final token = await TokenManager.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/doctors'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'specialtyId': specialtyId,
        'price': price,
        'bio': bio,
        'experienceYears': experienceYears,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return true;
    }

    String message =
        'Không thể thêm bác sĩ';

    try {
      final data = jsonDecode(response.body);

      if (data is Map &&
          data['message'] != null) {
        message = data['message'].toString();
      }
    } catch (_) {}

    throw Exception(
      '$message (${response.statusCode})',
    );
  }

  // ------------------------------------------------------------
  // SỬA BÁC SĨ
  // PUT /api/doctors/:id
  // ------------------------------------------------------------

  static Future<bool> updateDoctor({
    required String id,
    required String specialtyId,
    required double price,
    required String bio,
    required int experienceYears,
  }) async {
    final token = await TokenManager.getToken();

    // Kiểm tra ID trước khi gọi API
    final doctorId = id.trim();

    if (doctorId.isEmpty) {
      throw Exception(
        'ID bác sĩ không hợp lệ',
      );
    }

    final url = '$baseUrl/doctors/$doctorId';

    // In thông tin để kiểm tra khi chạy Flutter
    print('========================================');
    print('UPDATE DOCTOR');
    print('URL: $url');
    print('METHOD: PUT');
    print('ID: $doctorId');
    print('SPECIALTY: $specialtyId');
    print('PRICE: $price');
    print('EXPERIENCE: $experienceYears');
    print('========================================');

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'specialtyId': specialtyId,
          'price': price,
          'bio': bio,
          'experienceYears': experienceYears,
        }),
      );

      // In response để kiểm tra lỗi
      print('========================================');
      print('UPDATE DOCTOR RESPONSE');
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');
      print('========================================');

      // HTTP 2xx = thành công
      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return true;
      }

      String message =
          'Cập nhật bác sĩ thất bại';

      // Cố gắng lấy message từ backend
      try {
        final data = jsonDecode(response.body);

        if (data is Map &&
            data['message'] != null) {
          message =
              data['message'].toString();
        } else if (data is Map &&
            data['error'] != null) {
          message =
              data['error'].toString();
        }
      } catch (_) {
        if (response.body.isNotEmpty) {
          message = response.body;
        }
      }

      // Trường hợp 404
      if (response.statusCode == 404) {
        throw Exception(
          'Không tìm thấy API cập nhật bác sĩ.\n'
          'URL: $url\n'
          'Backend trả về 404.',
        );
      }

      // Trường hợp 401
      if (response.statusCode == 401) {
        throw Exception(
          'Phiên đăng nhập đã hết hạn '
          'hoặc token không hợp lệ.',
        );
      }

      // Trường hợp 403
      if (response.statusCode == 403) {
        throw Exception(
          'Bạn không có quyền cập nhật bác sĩ.',
        );
      }

      // Trường hợp 400
      if (response.statusCode == 400) {
        throw Exception(
          '$message\nDữ liệu gửi lên không hợp lệ.',
        );
      }

      // Các lỗi khác
      throw Exception(
        '$message (${response.statusCode})',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Không thể kết nối đến máy chủ: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // XÓA BÁC SĨ
  // DELETE /api/doctors/:id
  // ------------------------------------------------------------
// ------------------------------------------------------------
// XEM CHI TIẾT BÁC SĨ
// GET /api/doctors/:id
// ------------------------------------------------------------

static Future<Map<String, dynamic>> getDoctorById(
  String id,
) async {
  final token = await TokenManager.getToken();

  final response = await http.get(
    Uri.parse('$baseUrl/doctors/$id'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null)
        'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      'Dữ liệu bác sĩ không hợp lệ',
    );
  }

  String message =
      'Không thể lấy thông tin bác sĩ';

  try {
    final data = jsonDecode(response.body);

    if (data is Map &&
        data['message'] != null) {
      message = data['message'].toString();
    }
  } catch (_) {}

  throw Exception(
    '$message (${response.statusCode})',
  );
}

  static Future<bool> deleteDoctor(
    String id,
  ) async {
    final token = await TokenManager.getToken();

    final doctorId = id.trim();

    if (doctorId.isEmpty) {
      throw Exception(
        'ID bác sĩ không hợp lệ',
      );
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/doctors/$doctorId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    }

    String message =
        'Không thể xóa bác sĩ';

    try {
      final data = jsonDecode(response.body);

      if (data is Map &&
          data['message'] != null) {
        message =
            data['message'].toString();
      }
    } catch (_) {}

    throw Exception(
      '$message (${response.statusCode})',
    );
  }
}
