import 'package:flutter/material.dart';
import '../screens/admin/login/login_screen.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF1565C0),
      child: Column(
        children: [
          // ============================================================
          // LOGO
          // ============================================================
          Container(
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_hospital,
                  color: Colors.white,
                  size: 35,
                ),
                SizedBox(height: 5),
                Text(
                  'MEDICAL ADMIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            color: Colors.white24,
            height: 1,
          ),

          // ============================================================
          // DANH SÁCH MENU
          // ============================================================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ======================================================
                  // DASHBOARD
                  // ======================================================
                  _menuItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    index: 0,
                  ),

                  // ======================================================
                  // NGƯỜI DÙNG
                  // ======================================================
                  _menuItem(
                    icon: Icons.people,
                    title: 'Người dùng',
                    index: 1,
                  ),

                  // ======================================================
                  // BÁC SĨ
                  // ======================================================
                  _menuItem(
                    icon: Icons.medical_services,
                    title: 'Bác sĩ',
                    index: 2,
                  ),

                  // ======================================================
                  // CHUYÊN KHOA
                  // ======================================================
                  _menuItem(
                    icon: Icons.local_hospital,
                    title: 'Chuyên khoa',
                    index: 3,
                  ),

                  // ======================================================
                  // BỆNH NHÂN
                  // ======================================================
                  _menuItem(
                    icon: Icons.personal_injury,
                    title: 'Bệnh nhân',
                    index: 4,
                  ),

                  // ======================================================
                  // LỊCH HẸN
                  // ======================================================
                  _menuItem(
                    icon: Icons.calendar_month,
                    title: 'Lịch hẹn',
                    index: 5,
                  ),

                  // ======================================================
                  // HỒ SƠ BỆNH ÁN
                  // ======================================================
                  _menuItem(
                    icon: Icons.medical_information,
                    title: 'Hồ sơ bệnh án',
                    index: 6,
                  ),
                ],
              ),
            ),
          ),

          // ============================================================
          // ĐĂNG XUẤT
          // ============================================================
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
              ),
              child: _menuItem(
                icon: Icons.logout,
                title: 'Đăng xuất',
                index: 7,
                onLogout: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminLoginScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MENU ITEM
  // ============================================================
  Widget _menuItem({
    required IconData icon,
    required String title,
    required int index,
    VoidCallback? onLogout,
  }) {
    final bool selected = selectedIndex == index;

    return InkWell(
      onTap: () {
        // Nếu là nút đăng xuất
        if (onLogout != null) {
          onLogout();
          return;
        }

        // Các menu khác
        onItemSelected(index);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}