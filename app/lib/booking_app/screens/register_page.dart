import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';

class BookingRegisterPage extends StatefulWidget {
  const BookingRegisterPage({super.key});

  @override State<BookingRegisterPage> createState() => _S();
}

class _S extends State<BookingRegisterPage> {
  final name = TextEditingController(),
      email = TextEditingController(),
      phone = TextEditingController(),
      pass = TextEditingController();
  bool obscure = true;

  @override void dispose() {
    for (final c in [name, email, phone, pass]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
    if (name.text
        .trim()
        .isEmpty || email.text
        .trim()
        .isEmpty || pass.text.isEmpty) {
      _m('Vui lòng nhập đầy đủ thông tin');
      return;
    }
    final a = context.read<AuthProvider>();
    final ok = await a.register(fullName: name.text.trim(),
        email: email.text.trim(),
        password: pass.text,
        phoneNumber: phone.text.trim());
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công')));
      Navigator.pop(context);
    } else {
      _m(a.errorMessage ?? 'Đăng ký thất bại');
    }
  }

  void _m(String s) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s), behavior: SnackBarBehavior.floating));

  @override Widget build(BuildContext context) {
    final loading = context
        .watch<AuthProvider>()
        .isLoading;
    return Scaffold(backgroundColor: const Color(0xffF4FAFF),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: .06),
                              blurRadius: 30)
                        ]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tạo tài khoản', style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          const Text('Đăng ký để bắt đầu đặt lịch khám.',
                              style: TextStyle(color: Color(0xff64748B))),
                          const SizedBox(height: 24),
                          _f(name, 'Họ và tên', Icons.person_outline),
                          const SizedBox(height: 14),
                          _f(email, 'Email', Icons.mail_outline),
                          const SizedBox(height: 14),
                          _f(phone, 'Số điện thoại', Icons.phone_outlined),
                          const SizedBox(height: 14),
                          _f(pass, 'Mật khẩu', Icons.lock_outline,
                              obscure: obscure,
                              suffix: IconButton(onPressed: () =>
                                  setState(() => obscure = !obscure),
                                  icon: Icon(
                                      obscure ? Icons.visibility_off : Icons
                                          .visibility))),
                          const SizedBox(height: 22),
                          SizedBox(width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                  onPressed: loading ? null : submit,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff0284C7),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              16))),
                                  child: loading
                                      ? const CircularProgressIndicator(
                                      color: Colors.white)
                                      : const Text('Đăng ký',
                                      style: TextStyle(fontWeight: FontWeight
                                          .w700, fontSize: 16))))
                        ]))))));
  }

  Widget _f(TextEditingController c, String l, IconData i,
      {bool obscure = false, Widget? suffix}) =>
      TextField(controller: c,
          obscureText: obscure,
          decoration: InputDecoration(labelText: l,
              prefixIcon: Icon(i),
              suffixIcon: suffix,
              filled: true,
              fillColor: const Color(0xffF8FAFC),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none)));
}
