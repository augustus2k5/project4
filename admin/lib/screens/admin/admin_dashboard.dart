import 'package:flutter/material.dart';

import '../../widgets/admin_sidebar.dart';
import '../../widgets/admin_stat_card.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

import 'admin_users.dart';
import 'admin_doctors.dart';
import 'admin_specialties.dart';
import 'admin_patients.dart';
import 'admin_appointments.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // ============================================================
  // MENU INDEX
  // ============================================================
  //
  // 0 = Dashboard
  // 1 = Người dùng
  // 2 = Bác sĩ
  // 3 = Chuyên khoa
  // 4 = Bệnh nhân
  // 5 = Lịch hẹn
  // 6 = Đăng xuất
  //

  int selectedIndex = 0;

  // ============================================================
  // DỮ LIỆU NGƯỜI DÙNG
  // ============================================================

  List<UserModel> users = [];

  bool loading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadUsers();
  }

  // ============================================================
  // LẤY DANH SÁCH USER
  // ============================================================

  Future<void> loadUsers() async {
    try {
      final data = await ApiService.getUsers();

      if (!mounted) return;

      setState(() {
        users = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      debugPrint('Lỗi lấy danh sách người dùng: $e');
    }
  }

  // ============================================================
  // THỐNG KÊ
  // ============================================================

  int get totalUsers {
    return users.length;
  }

  int get totalDoctors {
    return users
        .where((user) => user.role == 'DOCTOR')
        .length;
  }

  int get totalPatients {
    return users
        .where((user) => user.role == 'PATIENT')
        .length;
  }

  int get blockedUsers {
    return users
        .where((user) => user.status == 'BLOCKED')
        .length;
  }

  // ============================================================
  // CHUYỂN TRANG
  // ============================================================

  Widget getCurrentPage() {
    switch (selectedIndex) {
      // ----------------------------------------------------------
      // 0 - DASHBOARD
      // ----------------------------------------------------------

      case 0:
        return _buildDashboard();

      // ----------------------------------------------------------
      // 1 - NGƯỜI DÙNG
      // ----------------------------------------------------------

      case 1:
        return const AdminUsers();

      // ----------------------------------------------------------
      // 2 - BÁC SĨ
      // ----------------------------------------------------------

      case 2:
        return const AdminDoctors();

      // ----------------------------------------------------------
      // 3 - CHUYÊN KHOA
      // ----------------------------------------------------------

      case 3:
        return const AdminSpecialties();

      // ----------------------------------------------------------
      // 4 - BỆNH NHÂN
      // ----------------------------------------------------------

      case 4:
        return const AdminPatients();

      // ----------------------------------------------------------
      // 5 - LỊCH HẸN
      // ----------------------------------------------------------

      case 5:
        return const AdminAppointments();

      // ----------------------------------------------------------
      // MẶC ĐỊNH
      // ----------------------------------------------------------

      default:
        return _buildDashboard();
    }
  }

  // ============================================================
  // TIÊU ĐỀ TRANG
  // ============================================================

  String getPageTitle() {
    switch (selectedIndex) {
      case 0:
        return 'Dashboard';

      case 1:
        return 'Quản lý người dùng';

      case 2:
        return 'Quản lý bác sĩ';

      case 3:
        return 'Quản lý chuyên khoa';

      case 4:
        return 'Quản lý bệnh nhân';

      case 5:
        return 'Quản lý lịch hẹn';

      case 6:
        return 'Đăng xuất';

      default:
        return 'Dashboard';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ======================================================
          // SIDEBAR
          // ======================================================

          AdminSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              // --------------------------------------------------
              // ĐĂNG XUẤT
              // --------------------------------------------------

              if (index == 6) {
                _logout();
                return;
              }

              // --------------------------------------------------
              // CHUYỂN TRANG
              // --------------------------------------------------

              setState(() {
                selectedIndex = index;
              });
            },
          ),

          // ======================================================
          // KHU VỰC NỘI DUNG
          // ======================================================

          Expanded(
            child: Column(
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // ------------------------------------------------
                      // TIÊU ĐỀ
                      // ------------------------------------------------

                      Text(
                        getPageTitle(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      // ------------------------------------------------
                      // THÔNG BÁO
                      // ------------------------------------------------

                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_none,
                          size: 27,
                        ),
                      ),

                      const SizedBox(width: 10),

                      // ------------------------------------------------
                      // AVATAR
                      // ------------------------------------------------

                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 10),

                      // ------------------------------------------------
                      // TÊN ADMIN
                      // ------------------------------------------------

                      const Text(
                        'Admin',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(width: 10),
                    ],
                  ),
                ),

                // ==================================================
                // BODY
                // ==================================================

                Expanded(
                  child: Container(
                    color: const Color(0xFFF5F7FA),
                    child: loading && selectedIndex == 0
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : getCurrentPage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DASHBOARD
  // ============================================================

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================================================
          // LỜI CHÀO
          // ========================================================

          const Text(
            'Xin chào, Admin 👋',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Tổng quan hệ thống quản lý bệnh viện',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 25),

          // ========================================================
          // THẺ THỐNG KÊ
          // ========================================================

          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            children: [
              // ----------------------------------------------------
              // NGƯỜI DÙNG
              // ----------------------------------------------------

              AdminStatCard(
                title: 'Người dùng',
                value: totalUsers.toString(),
                icon: Icons.people,
              ),

              // ----------------------------------------------------
              // BÁC SĨ
              // ----------------------------------------------------

              AdminStatCard(
                title: 'Bác sĩ',
                value: totalDoctors.toString(),
                icon: Icons.medical_services,
              ),

              // ----------------------------------------------------
              // BỆNH NHÂN
              // ----------------------------------------------------

              AdminStatCard(
                title: 'Bệnh nhân',
                value: totalPatients.toString(),
                icon: Icons.personal_injury,
              ),

              // ----------------------------------------------------
              // TÀI KHOẢN BỊ KHÓA
              // ----------------------------------------------------

              AdminStatCard(
                title: 'Bị khóa',
                value: blockedUsers.toString(),
                icon: Icons.block,
              ),
            ],
          ),

          const SizedBox(height: 30),

          // ========================================================
          // NGƯỜI DÙNG GẦN ĐÂY
          // ========================================================

          const Text(
            'Người dùng gần đây',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          // ========================================================
          // BẢNG USER
          // ========================================================

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: users.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: Text(
                        'Chưa có người dùng',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        // ------------------------------------------------
                        // HỌ TÊN
                        // ------------------------------------------------

                        DataColumn(
                          label: Text(
                            'Họ tên',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // ------------------------------------------------
                        // EMAIL
                        // ------------------------------------------------

                        DataColumn(
                          label: Text(
                            'Email',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // ------------------------------------------------
                        // VAI TRÒ
                        // ------------------------------------------------

                        DataColumn(
                          label: Text(
                            'Vai trò',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // ------------------------------------------------
                        // TRẠNG THÁI
                        // ------------------------------------------------

                        DataColumn(
                          label: Text(
                            'Trạng thái',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      rows: users.take(5).map((user) {
                        return DataRow(
                          cells: [
                            // --------------------------------------------
                            // HỌ TÊN
                            // --------------------------------------------

                            DataCell(
                              Text(
                                user.fullName,
                              ),
                            ),

                            // --------------------------------------------
                            // EMAIL
                            // --------------------------------------------

                            DataCell(
                              Text(
                                user.email,
                              ),
                            ),

                            // --------------------------------------------
                            // VAI TRÒ
                            // --------------------------------------------

                            DataCell(
                              Text(
                                user.role,
                              ),
                            ),

                            // --------------------------------------------
                            // TRẠNG THÁI
                            // --------------------------------------------

                            DataCell(
                              Text(
                                user.status,
                                style: TextStyle(
                                  color: user.status == 'ACTIVE'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ĐĂNG XUẤT
  // ============================================================

  void _logout() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Đã đăng xuất',
      ),
    ),
  );
}
}