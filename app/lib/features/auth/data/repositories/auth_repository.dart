import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/core/constants/api_constants.dart';

class AuthRepository {
  /// Hàm gọi API Đăng ký tài khoản
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    String phoneNumber = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Đăng ký thành công
        return {
          'success': true,
          'message': data['message'] ?? 'Đăng ký thành công!',
        };
      } else {
        // Lỗi từ backend (ví dụ: Email đã tồn tại)
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng ký thất bại!',
        };
      }
    } catch (e) {
      // Lỗi kết nối mạng hoặc không gọi được server
      return {
        'success': false,
        'message': 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại!',
      };
    }
  }

  /// đăng nhập
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng nhập thất bại!',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại!',
      };
    }
  }

  /// Hàm cập nhật thông tin cá nhân
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String currentPassword,
    String? newPassword,
    String? avatar,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'currentPassword': currentPassword,
          if (newPassword != null && newPassword.isNotEmpty)
            'newPassword': newPassword,
          if (avatar != null) 'avatar': avatar,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Cập nhật thành công!',
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Cập nhật thất bại!',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối đến máy chủ. Vui lòng thử lại!',
      };
    }
  }
}
