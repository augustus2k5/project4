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
}
