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
      final raw = await ApiService.get('/appointments', token: auth.token);
      final list = raw is List ? raw : <dynamic>[];

      final doctorAppointments = list.where((item) {
        if (item is! Map) return false;
        final doctorData = item['doctorId'];
        if (doctorData == null) return false;

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

  Future<void> updateStatus(String id, String newStatus) async {
    try {
      final token = context.read<AuthProvider>().token;
      await ApiService.patch('/appointments/$id/status', {
        'status': newStatus,
      }, token: token);
      await load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'CONFIRMED'
                  ? 'Đã xác nhận lịch hẹn.'
                  : 'Đã hoàn thành ca khám.',
            ),
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

  Future<void> cancel(String id) async {
    try {
      final token = context.read<AuthProvider>().token;
      await ApiService.patch('/appointments/$id/cancel', {}, token: token);
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

  // Dialog Tạo Bệnh Án kê được NHIỀU THUỐC
  void _showCreateMedicalRecordDialog(
    String patientId,
    String doctorId,
    String appointmentId,
    String patientName,
  ) {
    final diagnosisController = TextEditingController();
    final notesController = TextEditingController();

    // Danh sách các dòng thuốc (mỗi dòng gồm 3 controller: drugName, quantity, dosage)
    List<Map<String, TextEditingController>> medicineRows = [
      {
        'name': TextEditingController(),
        'quantity': TextEditingController(text: '10'),
        'dosage': TextEditingController(),
      }
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Tạo bệnh án - $patientName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: diagnosisController,
                      decoration: InputDecoration(
                        labelText: 'Chẩn đoán *',
                        hintText: 'Nhập chẩn đoán bệnh...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Danh sách đơn thuốc',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xff0284C7),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setDialogState(() {
                              medicineRows.add({
                                'name': TextEditingController(),
                                'quantity': TextEditingController(text: '10'),
                                'dosage': TextEditingController(),
                              });
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text('+ Thêm thuốc'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Duyệt hiển thị danh sách các ô nhập thuốc
                    ...medicineRows.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var row = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xffF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xffE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: row['name'],
                                    decoration: InputDecoration(
                                      labelText: 'Thuốc ${idx + 1}',
                                      hintText: 'Tên thuốc (ví dụ: Paracetamol)',
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                if (medicineRows.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () {
                                      setDialogState(() {
                                        medicineRows.removeAt(idx);
                                      });
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: row['quantity'],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Số lượng',
                                      hintText: '10',
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: row['dosage'],
                                    decoration: InputDecoration(
                                      labelText: 'Liều dùng',
                                      hintText: 'Uống 1 viên/lần...',
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 10),
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: 'Ghi chú thêm',
                        hintText: 'Lời khuyên, dặn dò bác sĩ...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0284C7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (diagnosisController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập chẩn đoán!')),
                    );
                    return;
                  }

                  try {
                    final auth = context.read<AuthProvider>();
                    final token = auth.token;

                    // Gom toàn bộ danh sách thuốc vừa nhập
                    List<Map<String, dynamic>> prescriptionsList = [];
                    List<String> textSummaryList = [];

                    for (var row in medicineRows) {
                      final name = row['name']!.text.trim();
                      final quantity = int.tryParse(row['quantity']!.text.trim()) ?? 1;
                      final dosage = row['dosage']!.text.trim();

                      if (name.isNotEmpty) {
                        prescriptionsList.add({
                          'drugName': name,
                          'quantity': quantity,
                          'dosage': dosage.isNotEmpty ? dosage : 'Theo chỉ định của bác sĩ',
                        });
                        textSummaryList.add('$name (SL: $quantity)');
                      }
                    }

                    await ApiService.post(
                      '/medical-records',
                      {
                        'patientId': patientId,
                        'doctorId': doctorId,
                        'appointmentId': appointmentId,
                        'diagnosis': diagnosisController.text.trim(),
                        'prescriptions': prescriptionsList,
                        'prescription': textSummaryList.join(', '),
                        'notes': notesController.text.trim(),
                      },
                      token: token,
                    );

                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tạo hồ sơ bệnh án thành công!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Lỗi: ${e.toString().replaceFirst('Exception: ', '')}',
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Lưu bệnh án',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMedicalRecordsHistory(String patientId, String patientName) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final token = context.read<AuthProvider>().token;

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lịch sử bệnh án - $patientName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: FutureBuilder(
                  future: ApiService.get(
                    '/medical-records/patient/$patientId',
                    token: token,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Chưa có lịch sử bệnh án.'));
                    }

                    final data = snapshot.data;
                    List records = data is List
                        ? data
                        : (data is Map && data['data'] is List
                            ? data['data']
                            : []);

                    if (records.isEmpty) {
                      return const Center(
                        child: Text('Bệnh nhân chưa có hồ sơ bệnh án nào.'),
                      );
                    }

                    return ListView.separated(
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = records[i];

                        String prescriptionText = '';
                        if (item['prescriptions'] is List &&
                            (item['prescriptions'] as List).isNotEmpty) {
                          List pList = item['prescriptions'];
                          List<String> drugItems = [];
                          for (var p in pList) {
                            if (p is Map) {
                              final name = p['drugName'] ?? p['name'] ?? '';
                              final quantity = p['quantity'] != null
                                  ? ' (SL: ${p['quantity']})'
                                  : '';
                              final dosage = p['dosage'] != null &&
                                      p['dosage'].toString().isNotEmpty
                                  ? ' - ${p['dosage']}'
                                  : '';
                              drugItems.add('• $name$quantity$dosage');
                            } else if (p is String) {
                              drugItems.add('• $p');
                            }
                          }
                          prescriptionText = drugItems.join('\n');
                        } else if (item['prescription'] != null &&
                            item['prescription'].toString().isNotEmpty) {
                          prescriptionText = item['prescription'].toString();
                        }

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xffF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xffE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chẩn đoán: ${item['diagnosis'] ?? 'Không có'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              if (prescriptionText.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    'Đơn thuốc:\n$prescriptionText',
                                    style: const TextStyle(
                                      color: Color(0xff0369A1),
                                    ),
                                  ),
                                ),
                              if (item['notes'] != null &&
                                  item['notes'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Ghi chú: ${item['notes']}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
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
              
              final doctorData = a['doctorId'];
              String rawDoctorId = '';
              if (doctorData is Map) {
                rawDoctorId = doctorData['_id'] ?? doctorData['id'] ?? '';
              } else if (doctorData is String) {
                rawDoctorId = doctorData;
              }

              final patient = a['patientId'];
              String patientId = '';
              String patientName = 'Bệnh nhân';
              String phone = '';

              if (patient is Map) {
                patientId = patient['_id'] ?? patient['id'] ?? '';
                patientName = patient['fullName'] ?? 'Bệnh nhân';
                phone = patient['phoneNumber'] ?? patient['phone'] ?? '';
              } else if (patient is String) {
                patientId = patient;
              }

              final date = a['date'] ?? '';
              final timeSlot = a['timeSlot'] ?? a['time'] ?? 'Chưa xếp giờ';
              final reason = a['reason'] ?? '';
              final status = (a['status'] ?? 'PENDING')
                  .toString()
                  .toUpperCase();

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
                          style: const TextStyle(color: Color(0xff64748B)),
                        ),
                      ),

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
                              icon: const Icon(
                                Icons.check_circle_outline,
                                size: 18,
                              ),
                              label: const Text('Xác nhận'),
                            ),
                          ],
                        ),
                      )
                    else if (status == 'CONFIRMED')
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            TextButton.icon(
                              onPressed: () => cancel(id),
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Color(0xffDC2626),
                              ),
                              label: const Text(
                                'Hủy',
                                style: TextStyle(color: Color(0xffDC2626)),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _showMedicalRecordsHistory(
                                patientId,
                                patientName,
                              ),
                              icon: const Icon(Icons.history_edu_rounded, size: 16),
                              label: const Text('Lịch sử BA'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showCreateMedicalRecordDialog(
                                patientId,
                                rawDoctorId,
                                id,
                                patientName,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff0284C7),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.note_add_rounded, size: 16),
                              label: const Text('Tạo BA'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => updateStatus(id, 'COMPLETED'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff7C3AED),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.task_alt_rounded,
                                size: 16,
                              ),
                              label: const Text('Hoàn thành'),
                            ),
                          ],
                        ),
                      )
                    else if (status == 'COMPLETED')
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _showMedicalRecordsHistory(
                                patientId,
                                patientName,
                              ),
                              icon: const Icon(Icons.history_edu_rounded, size: 16),
                              label: const Text('Lịch sử BA'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _showCreateMedicalRecordDialog(
                                patientId,
                                rawDoctorId,
                                id,
                                patientName,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff0284C7),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.note_add_rounded, size: 16),
                              label: const Text('Tạo BA'),
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