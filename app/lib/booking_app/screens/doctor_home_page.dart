import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import '../services/api_service.dart';
import 'doctor_home_screen.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  bool loading = true;
  String? error;
  int todayAppointmentsCount = 0;
  int pendingAppointmentsCount = 0;
  List<dynamic> upcomingAppointments = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final token = auth.token;
      final currentUserId =
          auth.currentUser?.id; // ID của Bác sĩ đang đăng nhập

      // 1. Gọi API lấy toàn bộ danh sách lịch hẹn (endpoint có sẵn)
      final response = await ApiService.get('/appointments', token: token);

      print('=== RAW RESPONSE ALL APPOINTMENTS: $response ===');

      List<dynamic> allAppointments = [];
      if (response is List) {
        allAppointments = response;
      } else if (response is Map && response['data'] is List) {
        allAppointments = response['data'];
      }

      // 2. Tự LỌC phía Flutter: Chỉ lấy các lịch hẹn của Bác sĩ hiện tại
      final doctorAppointments = allAppointments.where((item) {
        final doctorData = item['doctorId'];
        if (doctorData == null) return false;

        // Bắt ID dù doctorId lưu chuỗi ID hay Object bọc userId
        String? docUserId;
        if (doctorData is Map) {
          if (doctorData['userId'] is Map) {
            docUserId =
                doctorData['userId']['_id'] ?? doctorData['userId']['id'];
          } else {
            docUserId = doctorData['userId'] ?? doctorData['_id'];
          }
        } else if (doctorData is String) {
          docUserId = doctorData;
        }

        return docUserId == currentUserId;
      }).toList();

      final now = DateTime.now();
      final todayStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      int todayCount = 0;
      int pendingCount = 0;

      for (var item in doctorAppointments) {
        final status = (item['status'] ?? '').toString().toUpperCase();
        final rawDate = (item['date'] ?? '').toString();

        if (status == 'PENDING' || status == 'WAITING') {
          pendingCount++;
        }
        if (rawDate.contains(todayStr)) {
          todayCount++;
        }
      }

      if (mounted) {
        setState(() {
          upcomingAppointments = doctorAppointments;
          todayAppointmentsCount = todayCount;
          pendingAppointmentsCount = pendingCount;
          loading = false;
          error = null;
        });
      }
    } catch (e) {
      print('=== LỖI TẢI LỊCH KHÁM BÁC SĨ: $e ===');
      if (mounted) {
        setState(() {
          loading = false;
          error = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;

    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          // Header: Chào Bác sĩ
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xffE0F2FE),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  color: Color(0xff0284C7),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Xin chào, Bác sĩ 👨‍⚕️',
                      style: TextStyle(color: Color(0xff64748B)),
                    ),
                    Text(
                      user?.fullName ?? 'Bác sĩ',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),

          
          // Row(
          //   children: [
          //     // ==================== AVATAR ĐẠI DIỆN ====================
          //     Container(
          //       width: 48,
          //       height: 48,
          //       decoration: BoxDecoration(
          //         color: const Color(0xffE0F2FE),
          //         borderRadius: BorderRadius.circular(15),
          //         border: Border.all(
          //           color: const Color(0xffBAE6FD),
          //           width: 1.5,
          //         ),
          //       ),
          //       child: ClipRRect(
          //         borderRadius: BorderRadius.circular(13),
          //         child: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
          //             ? Image.network(
          //                 user.avatarUrl!,
          //                 fit: BoxFit.cover,
          //                 errorBuilder: (_, __, ___) => const Icon(
          //                   Icons.person_rounded,
          //                   color: Color(0xff0284C7),
          //                   size: 28,
          //                 ),
          //               )
          //             : const Icon(
          //                 Icons.person_rounded,
          //                 color: Color(0xff0284C7),
          //                 size: 28,
          //               ),
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           const Text(
          //             'Xin chào, Bác sĩ 👨‍⚕️',
          //             style: TextStyle(color: Color(0xff64748B)),
          //           ),
          //           Text(
          //             user?.fullName ?? 'Bác sĩ',
          //             style: const TextStyle(
          //               fontSize: 20,
          //               fontWeight: FontWeight.w800,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //     Container(
          //       width: 44,
          //       height: 44,
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.circular(14),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.black.withValues(alpha: .05),
          //             blurRadius: 12,
          //           ),
          //         ],
          //       ),
          //       child: const Icon(Icons.notifications_none_rounded),
          //     ),
          //   ],
          // ),


          const SizedBox(height: 20),

          // Banner chính dành cho Bác sĩ
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff0284C7), Color(0xff38BDF8)],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quản lý lịch khám\nhôm nay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Kiểm tra danh sách bệnh nhân và chuẩn bị cho ca khám.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context
                            .findAncestorStateOfType<DoctorHomeScreenState>()
                            ?.goTo(1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xff0369A1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Xem tất cả lịch khám'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.medical_information_rounded,
                  color: Colors.white,
                  size: 70,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Thống kê nhanh
          const Text(
            'Thống kê công việc',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Lịch hôm nay',
                  count: '$todayAppointmentsCount',
                  icon: Icons.today_rounded,
                  color: const Color(0xff0284C7),
                  bgColor: const Color(0xffE0F2FE),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Chờ xác nhận',
                  count: '$pendingAppointmentsCount',
                  icon: Icons.pending_actions_rounded,
                  color: const Color(0xffD97706),
                  bgColor: const Color(0xffFEF3C7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Danh sách bệnh nhân sắp khám
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Lịch khám sắp tới',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
              ),
              TextButton(
                onPressed: () => context
                    .findAncestorStateOfType<DoctorHomeScreenState>()
                    ?.goTo(1),
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (loading)
            ...List.generate(
              3,
              (i) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(
                  minHeight: 70,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            )
          else if (error != null)
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: Color(0xff94A3B8),
                  ),
                  const SizedBox(height: 8),
                  Text(error!),
                  TextButton(onPressed: load, child: const Text('Thử lại')),
                ],
              ),
            )
          else if (upcomingAppointments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Text(
                  'Hôm nay chưa có lịch khám nào.',
                  style: TextStyle(color: Color(0xff64748B)),
                ),
              ),
            )
          else
            ...upcomingAppointments.map((item) {
              // Lấy thông tin bệnh nhân từ patientId
              final patient = item['patientId'];
              String patientName = 'Bệnh nhân';
              String phone = '';

              if (patient is Map) {
                patientName = patient['fullName'] ?? 'Bệnh nhân';
                phone = patient['phoneNumber'] ?? patient['phone'] ?? '';
              }

              final timeSlot =
                  item['timeSlot'] ?? item['time'] ?? 'Chưa xếp giờ';
              final reason = item['reason'] ?? 'Khám định kỳ';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xffE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xffE0F2FE),
                      child: Icon(
                        Icons.person_rounded,
                        color: Color(0xff0284C7),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lý do: $reason ${phone.isNotEmpty ? "• $phone" : ""}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Color(0xff0284C7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeSlot,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff0369A1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xff64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
