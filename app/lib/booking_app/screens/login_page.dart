
import 'package:app/booking_app/screens/doctor_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'register_page.dart';
import 'home_shell.dart';

class BookingLoginPage extends StatefulWidget {
  const BookingLoginPage({super.key});

  @override State<BookingLoginPage> createState() => _BookingLoginPageState();
}

class _BookingLoginPageState extends State<BookingLoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;

  @override void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  // Future<void> login() async {
  //   if (email.text
  //       .trim()
  //       .isEmpty || password.text.isEmpty) {
  //     _msg('Vui lòng nhập email và mật khẩu');
  //     return;
  //   }
  //   final auth = context.read<AuthProvider>();
  //   final ok = await auth.login(
  //       email: email.text.trim(), password: password.text);
  //   if (!mounted) return;
  //   if (ok) {
  //     Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (_) => const HomeShell()));
  //   }
  //   else {
  //     _msg(auth.errorMessage ?? 'Đăng nhập thất bại');
  //   }
  // }

  Future<void> login() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      _msg('Vui lòng nhập email và mật khẩu');
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      email: email.text.trim(),
      password: password.text,
    );

    if (!mounted) return;

    if (ok) {
      print('================ DEBUG LOGIN ================');
      print('1. Current User Object: ${auth.currentUser}');
      print('2. Role lấy được: "${auth.currentUser?.role}"');
      print('=============================================');

      final String role = (auth.currentUser?.role ?? 'PATIENT').toString().toUpperCase();
      print(role);
      if (role.contains('DOCTOR')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorHomeScreen()), // Màn hình Bác sĩ
        );
      }  else if (role.contains('PATIENT')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeShell()),
        );
      }
    } else {
      _msg(auth.errorMessage ?? 'Đăng nhập thất bại');
    }
  }

  void _msg(String s) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s), behavior: SnackBarBehavior.floating));

  @override Widget build(BuildContext context) {
    final loading = context
        .watch<AuthProvider>()
        .isLoading;
    return Scaffold(backgroundColor: const Color(0xffF4FAFF),
        body: Center(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: .06),
                              blurRadius: 30,
                              offset: const Offset(0, 12))
                        ]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                  color: const Color(0xff0EA5E9).withValues(
                                      alpha: .12), shape: BoxShape.circle),
                              child: const Icon(Icons.local_hospital_rounded,
                                  color: Color(0xff0284C7), size: 32)),
                          const SizedBox(height: 22),
                          const Text('Chào mừng trở lại', style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xff0F172A))),
                          const SizedBox(height: 6),
                          const Text('Đăng nhập để quản lý lịch khám của bạn.',
                              style: TextStyle(color: Color(0xff64748B))),
                          const SizedBox(height: 28),
                          _field(email, 'Email', Icons.mail_outline_rounded),
                          const SizedBox(height: 16),
                          _field(
                              password, 'Mật khẩu', Icons.lock_outline_rounded,
                              obscure: obscure,
                              suffix: IconButton(onPressed: () =>
                                  setState(() => obscure = !obscure),
                                  icon: Icon(obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined))),
                          const SizedBox(height: 24),
                          SizedBox(width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                  onPressed: loading ? null : login,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff0284C7),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              16))),
                                  child: loading
                                      ? const SizedBox(width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                      : const Text('Đăng nhập',
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight
                                          .w700)))),
                          const SizedBox(height: 20),
                          Center(child: Wrap(alignment: WrapAlignment.center,
                              children: [
                                const Text(
                                    'Chưa có tài khoản? ', style: TextStyle(
                                    color: Color(0xff64748B))),
                                TextButton(onPressed: () => Navigator.push(
                                    context, MaterialPageRoute(builder: (
                                    _) => const BookingRegisterPage())),
                                    child: const Text('Đăng ký ngay'))
                              ]))
                        ]))))));
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {bool obscure = false, Widget? suffix}) =>
      TextField(controller: c,
          obscureText: obscure,
          decoration: InputDecoration(labelText: label,
              prefixIcon: Icon(icon),
              suffixIcon: suffix,
              filled: true,
              fillColor: const Color(0xffF8FAFC),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none)));
}
