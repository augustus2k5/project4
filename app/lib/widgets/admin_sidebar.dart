import 'package:flutter/material.dart';

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

          // LOGO
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
          ),

          _menuItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            index: 0,
          ),

          _menuItem(
            icon: Icons.people,
            title: 'Người dùng',
            index: 1,
          ),

          _menuItem(
            icon: Icons.medical_services,
            title: 'Bác sĩ',
            index: 2,
          ),

          _menuItem(
            icon: Icons.personal_injury,
            title: 'Bệnh nhân',
            index: 3,
          ),

          _menuItem(
            icon: Icons.calendar_month,
            title: 'Lịch hẹn',
            index: 4,
          ),

          const Spacer(),

          _menuItem(
            icon: Icons.settings,
            title: 'Cài đặt',
            index: 5,
          ),

          _menuItem(
            icon: Icons.logout,
            title: 'Đăng xuất',
            index: 6,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool selected = selectedIndex == index;

    return InkWell(
      onTap: () {
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
              ? Colors.white.withOpacity(0.18)
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

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}