import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import '../models/appointment.dart';
import '../services/api_service.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  List<AppointmentItem> items = [];
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
      final raw = await ApiService.get(
        '/appointments/patient/${user.id}',
        token: auth.token,
      );
      final list = raw is List ? raw : <dynamic>[];
      final parsed = list
          .whereType<Map>()
          .map(
            (e) => AppointmentItem.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();

      if (mounted) {
        setState(() {
          items = parsed;
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

  Future<void> cancel(String id) async {
    try {
      final token = context.read<AuthProvider>().token;
      await ApiService.patch(
        '/patient/appointments/$id/cancel',
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
            'Lịch hẹn của tôi',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Theo dõi và quản lý các buổi khám đã đặt.',
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
                      'Bạn chưa có lịch hẹn nào.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Hãy chọn một bác sĩ để bắt đầu đặt lịch.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xff64748B)),
                    ),
                  ],
                ),
              ),
            )
          else
            ...items.map(
              (a) => Container(
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
                                a.doctorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                a.specialty,
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
                            color: statusColor(a.status).withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusLabel(a.status),
                            style: TextStyle(
                              color: statusColor(a.status),
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
                        Text(a.date),
                        const SizedBox(width: 18),
                        const Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: Color(0xff64748B),
                        ),
                        const SizedBox(width: 7),
                        Text(a.timeSlot),
                      ],
                    ),
                    if (a.reason.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'Lý do: ${a.reason}',
                          style: const TextStyle(
                            color: Color(0xff64748B),
                          ),
                        ),
                      ),
                    if (a.status == 'PENDING' || a.status == 'CONFIRMED')
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => cancel(a.id),
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: Color(0xffDC2626),
                          ),
                          label: const Text(
                            'Hủy lịch',
                            style: TextStyle(
                              color: Color(0xffDC2626),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
