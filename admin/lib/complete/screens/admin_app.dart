import 'package:flutter/material.dart';
import '../services/admin_api.dart';

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  @override
  State<AdminApp> createState() => _S();
}

class _S extends State<AdminApp> {
  final api = AdminApi();
  Map<String, dynamic>? user;
  String page = 'Dashboard';

  Widget _login() => Scaffold(
        backgroundColor: const Color(0xffF1F5F9),
        body: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _Login(
              api: api,
              onLogin: (u) => setState(() => user = u),
            ),
          ),
        ),
      );

  Widget _dashboard() => Scaffold(
        backgroundColor: const Color(0xffF6F8FC),
        body: Row(
          children: [
            // Sidebar Navigation
            Container(
              width: 240,
              color: Colors.white,
              child: Column(
                children: [
                  const DrawerHeader(
                    child: Text(
                      'Admin Panel',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...['Dashboard', 'Người dùng', 'Bác sĩ', 'Chuyên khoa', 'Lịch hẹn'].map(
                    (t) => ListTile(
                      leading: Icon(_icon(t)),
                      title: Text(t),
                      selected: page == t,
                      onTap: () => setState(() => page = t),
                    ),
                  ),
                ],
              ),
            ),
            // Content Area
            Expanded(child: _content()),
          ],
        ),
      );

  IconData _icon(String x) => switch (x) {
        'Dashboard' => Icons.dashboard_rounded,
        'Người dùng' => Icons.people_alt_rounded,
        'Bác sĩ' => Icons.medical_services_rounded,
        'Chuyên khoa' => Icons.category_rounded,
        _ => Icons.calendar_today_rounded,
      };

  Widget _content() {
    switch (page) {
      case 'Người dùng':
        return _users();
      case 'Bác sĩ':
        return _simpleList('/admin/doctors', 'Bác sĩ');
      case 'Chuyên khoa':
        return _simpleList('/admin/specialties', 'Chuyên khoa');
      case 'Lịch hẹn':
        return _simpleList('/admin/appointments', 'Lịch hẹn');
      default:
        return _stats();
    }
  }

  Widget _stats() => FutureBuilder(
        future: api.req('GET', '/admin/stats'),
        builder: (c, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final data = s.data as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _stat('Người dùng', '${data['users'] ?? 0}', Icons.people),
                _stat('Bác sĩ', '${data['doctors'] ?? 0}', Icons.medical_services),
                _stat('Lịch hẹn', '${data['appointments'] ?? 0}', Icons.calendar_today),
              ],
            ),
          );
        },
      );

  Widget _stat(String t, String d, IconData i) => Container(
        width: 220,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(i, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: const TextStyle(color: Colors.grey)),
                Text(d, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      );

  Widget _users() => FutureBuilder(
        future: api.req('GET', '/admin/users'),
        builder: (c, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final list = s.data as List;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (c, i) => ListTile(
              title: Text(list[i]['fullName'] ?? ''),
              subtitle: Text(list[i]['email'] ?? ''),
            ),
          );
        },
      );

  Widget _simpleList(String path, String title) => FutureBuilder(
        future: api.req('GET', path),
        builder: (c, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final list = s.data as List;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (c, i) => ListTile(
              title: Text(list[i]['name'] ?? title),
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return user == null ? _login() : _dashboard();
  }
}

class _Login extends StatefulWidget {
  final AdminApi api;
  final ValueChanged<Map<String, dynamic>> onLogin;

  const _Login({required this.api, required this.onLogin});

  @override
  State<_Login> createState() => _L();
}

class _L extends State<_Login> {
  final e = TextEditingController();
  final p = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(controller: e, decoration: const InputDecoration(labelText: 'Email')),
        TextField(controller: p, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu')),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final res = await widget.api.req('POST', '/auth/login', body: {'email': e.text, 'password': p.text});
            if (res != null) widget.onLogin(res['user']);
          },
          child: const Text('Đăng nhập'),
        )
      ],
    );
  }
}