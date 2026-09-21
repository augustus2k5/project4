import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import '../services/api_service.dart';

class DoctorAppointmentsPage extends StatefulWidget {
  const DoctorAppointmentsPage({super.key});

  @override
  State<DoctorAppointmentsPage> createState() => _DoctorAppointmentsPageState();
}

class _DoctorAppointmentsPageState extends State<DoctorAppointmentsPage> {
  List<dynamic> items = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null || auth.token == null) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'Vui lòng đăng nhập để xem lịch hẹn.';
        });
      }
      return;
    }

    setState(() => loading = true);
    try {
      // 1. Gọi API lấy toàn bộ danh sách lịch hẹn
      final raw = await ApiService.get(
        '/appointments',
        token: auth.token,
      );
      final list = raw is List ? raw : <dynamic>[];

      // 2. Lọc chỉ lấy các lịch hẹn của Bác sĩ đang đăng nhập
      final doctorAppointments = list.where((item) {
        if (item is! Map) return false;
        final doctorData = item['doctorId'];
        if (doctorData == null) return false;

        String? docUserId;
        if (doctorData is Map) {
          if (doctorData['userId'] is Map) {
            docUserId = doctorData['userId']['_id'] ?? doctorData['userId']['id'];
          } else {
            docUserId = doctorData['userId'] ?? doctorData['_id'];
          }
        } else if (doctorData is String) {
          docUserId = doctorData;
        }

        return docUserId == user.id;
      }).toList();

      if (mounted) {
        setState(() {
          items = doctorAppointments;
          loading = false;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  // Hàm cập nhật trạng thái lịch hẹn (Xác nhận/Hoàn thành)
  Future<void> updateStatus(String id, String newStatus) async {
    try {
      final token = context.read<AuthProvider>().token;
      await ApiService.patch(
        '/appointments/$id/status',
        {'status': newStatus},
        token: token,
      );
      await load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == 'CONFIRMED'
                ? 'Đã xác nhận lịch hẹn.'
                : 'Đã hoàn thành ca khám.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
          ),
        );
      }
    }
  }

  // Hàm hủy lịch hẹn phía Bác sĩ
  Future<void> cancel(String id) async {
    try {
      final token = context.read<AuthProvider>().token;
      await ApiService.patch(
        '/appointments/$id/cancel',
        {},
        token: token,
      );
      await load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy lịch hẹn.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
          ),
        );
      }
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return const Color(0xff16A34A);
      case 'CANCELLED':
        return const Color(0xffDC2626);
      case 'COMPLETED':
        return const Color(0xff7C3AED);
      default:
        return const Color(0xffF59E0B);
    }
  }

  String statusLabel(String status) {
    return {
          'PENDING': 'Chờ xác nhận',
          'CONFIRMED': 'Đã xác nhận',
          'CANCELLED': 'Đã hủy',
          'COMPLETED': 'Đã hoàn thành',
        }[status] ??
        status;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
        children: [
          const Text(
            'Lịch khám bệnh nhân',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Theo dõi và quản lý các ca khám được đăng ký.',
            style: TextStyle(color: Color(0xff64748B)),
          ),
          const SizedBox(height: 20),
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (error != null)
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 52,
                    color: Color(0xff94A3B8),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: load,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          else if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 58,
                      color: Color(0xff94A3B8),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Chưa có lịch hẹn nào.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Danh sách lịch khám của bệnh nhân sẽ xuất hiện tại đây.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xff64748B)),
                    ),
                  ],
                ),
              ),
            )
          else
            ...items.map((a) {
              final id = a['_id'] ?? a['id'] ?? '';
              final patient = a['patientId'];
              String patientName = 'Bệnh nhân';
              String phone = '';

              if (patient is Map) {
                patientName = patient['fullName'] ?? 'Bệnh nhân';
                phone = patient['phoneNumber'] ?? patient['phone'] ?? '';
              }

              final date = a['date'] ?? '';
              final timeSlot = a['timeSlot'] ?? a['time'] ?? 'Chưa xếp giờ';
              final reason = a['reason'] ?? '';
              final status = (a['status'] ?? 'PENDING').toString().toUpperCase();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .04),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xffE0F2FE),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xff0284C7),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patientName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (phone.isNotEmpty)
                                Text(
                                  phone,
                                  style: const TextStyle(
                                    color: Color(0xff0284C7),
                                  ),
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
                            color: statusColor(status).withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusLabel(status),
                            style: TextStyle(
                              color: statusColor(status),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 17,
                          color: Color(0xff64748B),
                        ),
                        const SizedBox(width: 7),
                        Text(date),
                        const SizedBox(width: 18),
                        const Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: Color(0xff64748B),
                        ),
                        const SizedBox(width: 7),
                        Text(timeSlot),
                      ],
                    ),
                    if (reason.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'Lý do: $reason',
                          style: const TextStyle(
                            color: Color(0xff64748B),
                          ),
                        ),
                      ),
                    
                    // Thao tác xử lý dành riêng cho Bác sĩ
                    if (status == 'PENDING')
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => cancel(id),
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Color(0xffDC2626),
                              ),
                              label: const Text(
                                'Từ chối',
                                style: TextStyle(color: Color(0xffDC2626)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => updateStatus(id, 'CONFIRMED'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff16A34A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: const Text('Xác nhận'),
                            ),
                          ],
                        ),
                      )
                    else if (status == 'CONFIRMED')
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => cancel(id),
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Color(0xffDC2626),
                              ),
                              label: const Text(
                                'Hủy lịch',
                                style: TextStyle(color: Color(0xffDC2626)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => updateStatus(id, 'COMPLETED'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff7C3AED),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.task_alt_rounded, size: 18),
                              label: const Text('Hoàn thành'),
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
}