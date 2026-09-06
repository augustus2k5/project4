import 'package:flutter/material.dart';
import 'package:app/features/auth/data/models/user_models.dart';
import 'package:app/features/auth/data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  UserModels? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModels? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;

  /// Xử lý Đăng ký tài khoản
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String phoneNumber = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Báo cho UI bật hiệu ứng loading

    final result = await _authRepository.register(
      fullName: fullName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );

    _isLoading = false;

    if (result['success'] == true) {
      notifyListeners();
      return true; // Đăng ký thành công
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false; // Đăng ký thất bại
    }
  }

  /// Xử lý Đăng nhập tài khoản (sẵn sàng cho bước tiếp theo)
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    final result = await _authRepository.login(
      email: email,
      password: password,
    );
    _isLoading = false;
    if (result['success'] == true) {
      _token = result['token'];
      _currentUser = UserModels.fromJson(result['user']);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  /// Đăng xuất
  void logout() {
    _currentUser = null;
    _token = null;
    notifyListeners();
  }
}
