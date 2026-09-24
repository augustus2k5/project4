import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import '../models/appointment.dart';
import '../services/api_service.dart';
import '../widgets/review_bottom_sheet.dart';

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
          .map((e) => AppointmentItem.fromJson(Map<String, dynamic>.from(e)))
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
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
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

  void _showMedicalRecordDialog(String appointmentId) async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    final token = auth.token;

    if (user == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.assignment_outlined, color: Color(0xff0284C7)),
            SizedBox(width: 8),
            Text(
              'Chi tiết bệnh án',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: FutureBuilder(
          future: ApiService.get(
            '/medical-records/patient/${user.id}',
            token: token,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Chưa có hồ sơ bệnh án cho lịch hẹn này.'),
              );
            }

            final rawData = snapshot.data;
            List records = [];
            if (rawData is List) {
              records = rawData;
            } else if (rawData is Map && rawData['data'] is List) {
              records = rawData['data'];
            }

            if (records.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Chưa có hồ sơ bệnh án cho lịch hẹn này.'),
              );
            }

            // Tìm bệnh án thuộc đúng appointmentId
            Map<String, dynamic>? record;
            for (var item in records) {
              if (item is! Map) continue;
              final appData = item['appointmentId'];
              String? appDataId;
              if (appData is Map) {
                appDataId = appData['_id'] ?? appData['id'];
              } else if (appData is String) {
                appDataId = appData;
              }

              if (appDataId == appointmentId) {
                record = Map<String, dynamic>.from(item);
                break;
              }
            }

            if (record == null) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Chưa có hồ sơ bệnh án cho lịch hẹn này.'),
              );
            }

            // Chẩn đoán
            final diagnosis = record['diagnosis'] ?? 'Chưa cập nhật';

            // Ghi chú
            final rawNotes = record['notes'] ?? record['note'] ?? record['description'];
            final notes = (rawNotes != null && rawNotes.toString().trim().isNotEmpty)
                ? rawNotes.toString()
                : 'Không có ghi chú';

            // Đơn thuốc (prescriptions)
            String prescriptionText = 'Không có đơn thuốc';
            if (record['prescriptions'] is List && (record['prescriptions'] as List).isNotEmpty) {
              List pList = record['prescriptions'];
              List<String> items = [];
              for (var p in pList) {
                if (p is Map) {
                  final name = p['drugName'] ?? p['name'] ?? '';
                  final quantity = p['quantity'] != null ? ' (SL: ${p['quantity']})' : '';
                  final dosage = p['dosage'] != null && p['dosage'].toString().isNotEmpty
                      ? '\n  Liều dùng: ${p['dosage']}'
                      : '';
                  items.add('• $name$quantity$dosage');
                } else if (p is String) {
                  items.add('• $p');
                }
              }
              if (items.isNotEmpty) {
                prescriptionText = items.join('\n');
              }
            } else if (record['prescription'] != null && record['prescription'].toString().trim().isNotEmpty) {
              prescriptionText = record['prescription'].toString();
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRecordItem(
                    'Chẩn đoán',
                    diagnosis,
                    Icons.medical_services_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildRecordItem(
                    'Đơn thuốc',
                    prescriptionText,
                    Icons.medication_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildRecordItem(
                    'Ghi chú bác sĩ',
                    notes,
                    Icons.note_alt_outlined,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Đóng',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xff0284C7)),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff64748B))),
            ],
          ),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
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
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
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
                  Text(error!, textAlign: TextAlign.center),
                  TextButton(onPressed: load, child: const Text('Thử lại')),
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
                          style: const TextStyle(color: Color(0xff64748B)),
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
                            style: TextStyle(color: Color(0xffDC2626)),
                          ),
                        ),
                      ),
                    // Nếu lịch hẹn đã hoàn thành (COMPLETED), hiển thị song song nút "Xem bệnh án" và "Đánh giá buổi khám"
                    if (a.status == 'COMPLETED') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showMedicalRecordDialog(a.id),
                              icon: const Icon(Icons.assignment_outlined, size: 18),
                              label: const Text(
                                'Xem bệnh án',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff0284C7),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ReviewBottomSheet.show(
                                  context,
                                  appointmentId: a.id,
                                  doctorName: a.doctorName,
                                  onSubmitted: () => load(),
                                );
                              },
                              icon: const Icon(
                                Icons.star_rate_rounded,
                                color: Color(0xffffb703),
                                size: 18,
                              ),
                              label: const Text(
                                'Đánh giá',
                                style: TextStyle(
                                  color: Color(0xff0284C7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xff0284C7)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}