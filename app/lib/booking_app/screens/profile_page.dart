import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override Widget build(BuildContext context) {
    final a = context.watch<AuthProvider>();
    final u = a.currentUser;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          const Text('Hồ sơ',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          Container(padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(gradient: const LinearGradient(
                  colors: [Color(0xff0284C7), Color(0xff38BDF8)]),
                  borderRadius: BorderRadius.circular(25)),
              child: Row(children: [
                Container(width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),
                        shape: BoxShape.circle),
                    child: const Icon(
                        Icons.person_rounded, color: Colors.white, size: 40)),
                const SizedBox(width: 15),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u?.fullName ?? 'Người dùng', style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800)),
                      Text(u?.email ?? '',
                          style: const TextStyle(color: Colors.white70))
                    ]))
              ])),
          const SizedBox(height: 16),
          _row(Icons.person_outline, 'Họ và tên', u?.fullName ?? ''),
          _row(Icons.mail_outline, 'Email', u?.email ?? ''),
          _row(Icons.phone_outlined, 'Số điện thoại',
              u?.phoneNumber.isEmpty == true ? 'Chưa cập nhật' : u!
                  .phoneNumber),
          const SizedBox(height: 18),
          OutlinedButton.icon(onPressed: () {
            a.logout();
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const BookingLoginPage()), (
                    _) => false);
          },
              icon: const Icon(Icons.logout_rounded, color: Color(0xffDC2626)),
              label: const Text('Đăng xuất', style: TextStyle(
                  color: Color(0xffDC2626), fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: Color(0xffFECACA)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))))
        ]);
  }

  Widget _row(IconData i, String t, String v) =>
      Container(margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            Icon(i, color: const Color(0xff0284C7)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t, style: const TextStyle(
                      color: Color(0xff64748B), fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(v, style: const TextStyle(fontWeight: FontWeight.w700))
                ]))
          ]));
}
