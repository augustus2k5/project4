import 'package:flutter/material.dart';

import '../../widgets/admin_sidebar.dart';
import '../../widgets/admin_stat_card.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

import 'admin_users.dart';
import 'admin_doctors.dart';
import 'admin_patients.dart';
import 'admin_appointments.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  List<UserModel> users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

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

      debugPrint(e.toString());
    }
  }

  int get totalUsers => users.length;

  int get totalDoctors {
    return users.where((user) => user.role == 'DOCTOR').length;
  }

  int get totalPatients {
    return users.where((user) => user.role == 'PATIENT').length;
  }

  int get blockedUsers {
    return users.where((user) => user.status == 'BLOCKED').length;
  }

  // ==============================
  // CHUYỂN TRANG
  // ==============================

  Widget getCurrentPage() {
    switch (selectedIndex) {
      case 0:
        return _buildDashboard();

      case 1:
        return const AdminUsers();

      case 2:
        return const AdminDoctors();

      case 3:
        return const AdminPatients();

      case 4:
        return const AdminAppointments();

      default:
        return _buildDashboard();
    }
  }

  String getPageTitle() {
    switch (selectedIndex) {
      case 0:
        return 'Dashboard';

      case 1:
        return 'Quản lý người dùng';

      case 2:
        return 'Quản lý bác sĩ';

      case 3:
        return 'Quản lý bệnh nhân';

      case 4:
        return 'Quản lý lịch hẹn';

      case 5:
        return 'Cài đặt';

      case 6:
        return 'Đăng xuất';

      default:
        return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [

          // ==============================
          // SIDEBAR
          // ==============================

          AdminSidebar(
            selectedIndex: selectedIndex,

            onItemSelected: (index) {

              // Nếu bấm đăng xuất
              if (index == 6) {
                _logout();
                return;
              }

              setState(() {
                selectedIndex = index;
              });
            },
          ),

          // ==============================
          // NỘI DUNG
          // ==============================

          Expanded(
            child: Column(
              children: [

                // HEADER
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
                      ),
                    ],
                  ),
                  child: Row(
                    children: [

                      Text(
                        getPageTitle(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      const Icon(
                        Icons.notifications_none,
                        size: 27,
                      ),

                      const SizedBox(width: 20),

                      const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Text(
                        'Admin',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // BODY
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

  // ==============================
  // DASHBOARD
  // ==============================

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            'Xin chào, Admin 👋',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            children: [

              AdminStatCard(
                title: 'Người dùng',
                value: totalUsers.toString(),
                icon: Icons.people,
              ),

              AdminStatCard(
                title: 'Bác sĩ',
                value: totalDoctors.toString(),
                icon: Icons.medical_services,
              ),

              AdminStatCard(
                title: 'Bệnh nhân',
                value: totalPatients.toString(),
                icon: Icons.personal_injury,
              ),

              AdminStatCard(
                title: 'Bị khóa',
                value: blockedUsers.toString(),
                icon: Icons.block,
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            'Người dùng gần đây',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(
                    label: Text('Họ tên'),
                  ),
                  DataColumn(
                    label: Text('Email'),
                  ),
                  DataColumn(
                    label: Text('Vai trò'),
                  ),
                  DataColumn(
                    label: Text('Trạng thái'),
                  ),
                ],

                rows: users.take(5).map((user) {

                  return DataRow(
                    cells: [

                      DataCell(
                        Text(user.fullName),
                      ),

                      DataCell(
                        Text(user.email),
                      ),

                      DataCell(
                        Text(user.role),
                      ),

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

  // ==============================
  // ĐĂNG XUẤT
  // ==============================

  void _logout() {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đăng xuất nhaq'),
      ),
    );
  }
}
