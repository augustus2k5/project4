import 'package:flutter/material.dart';
import '../../models/appointment_model.dart';
import '../../services/api_service.dart';

class AdminAppointments extends StatefulWidget {
  const AdminAppointments({super.key});

  @override
  State<AdminAppointments> createState() => _AdminAppointmentsState();
}

class _AdminAppointmentsState extends State<AdminAppointments> {
  List<AppointmentModel> allAppointments = [];
  List<DoctorAppointmentGroup> doctorGroups = [];
  DoctorAppointmentGroup? selectedDoctor;

  bool loading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadAppointments() async {
    setState(() => loading = true);
    try {
      final raw = await ApiService.getAppointments();
      final parsed = raw
          .map((e) => AppointmentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // Gom nhóm theo Bác sĩ (chỉ những bác sĩ có lịch hẹn)
      final Map<String, List<AppointmentModel>> grouped = {};
      final Map<String, String> docNames = {};
      final Map<String, String> docSpecialties = {};

      for (var a in parsed) {
        if (!grouped.containsKey(a.doctorId)) {
          grouped[a.doctorId] = [];
          docNames[a.doctorId] = a.doctorName;
          docSpecialties[a.doctorId] = a.specialtyName;
        }
        grouped[a.doctorId]!.add(a);
      }

      final List<DoctorAppointmentGroup> groups = [];
      grouped.forEach((docId, list) {
        groups.add(
          DoctorAppointmentGroup(
            doctorId: docId,
            doctorName: docNames[docId] ?? 'Bác sĩ',
            specialtyName: docSpecialties[docId] ?? 'Chuyên khoa',
            appointments: list,
          ),
        );
      });

      if (!mounted) return;
      setState(() {
        allAppointments = parsed;
        doctorGroups = groups;
        loading = false;
        // Cập nhật lại bác sĩ đang chọn nếu có
        if (selectedDoctor != null) {
          selectedDoctor = groups.firstWhere(
            (g) => g.doctorId == selectedDoctor!.doctorId,
            orElse: () => groups.isNotEmpty ? groups.first : groups.first,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải lịch hẹn: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> changeStatus(
    AppointmentModel appointment,
    String newStatus,
  ) async {
    try {
      final ok = await ApiService.updateAppointmentStatus(
        id: appointment.id,
        status: newStatus,
      );
      if (ok) {
        setState(() {
          appointment.status = newStatus;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật trạng thái thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi cập nhật: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'CANCELLED':
        return 'Đã hủy';
      case 'COMPLETED':
        return 'Hoàn thành';
      default:
        return 'Chờ xác nhận';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: selectedDoctor == null
            ? _buildDoctorListView()
            : _buildDoctorAppointmentsView(),
      ),
    );
  }

  // ==========================================
  // VIEW 1: DANH SÁCH BÁC SĨ CÓ LỊCH HẸN
  // ==========================================
  Widget _buildDoctorListView() {
    final filtered = doctorGroups.where((g) {
      final q = searchController.text.toLowerCase();
      return g.doctorName.toLowerCase().contains(q) ||
          g.specialtyName.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quản lý Lịch hẹn theo Bác sĩ',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        const Text(
          'Danh sách các bác sĩ hiện đang có lịch hẹn của bệnh nhân',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm bác sĩ hoặc chuyên khoa...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
              ? const Center(
                  child: Text(
                    'Không có bác sĩ nào có lịch hẹn.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.blue.withOpacity(0.12),
                          child: const Icon(
                            Icons.medical_services,
                            color: Colors.blue,
                          ),
                        ),
                        title: Text(
                          doc.doctorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        subtitle: Text('Chuyên khoa: ${doc.specialtyName}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (doc.pendingCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${doc.pendingCount} chờ duyệt',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Tổng: ${doc.totalAppointments}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            selectedDoctor = doc;
                          });
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // VIEW 2: CHI TIẾT LỊCH HẸN CỦA 1 BÁC SĨ
  // ==========================================
  Widget _buildDoctorAppointmentsView() {
    final doc = selectedDoctor!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  selectedDoctor = null;
                });
                loadAppointments();
              },
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lịch hẹn: ${doc.doctorName}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Chuyên khoa: ${doc.specialtyName}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 25,
                  headingRowHeight: 50,
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 75,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'STT',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Bệnh nhân',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'SĐT / Email',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Ngày khám',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Khung giờ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Lý do khám',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Trạng thái',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Thao tác đổi trạng thái',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: List.generate(doc.appointments.length, (index) {
                    final appt = doc.appointments[index];
                    final color = getStatusColor(appt.status);

                    return DataRow(
                      cells: [
                        DataCell(Text('${index + 1}')),
                        DataCell(
                          Text(
                            appt.patientName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${appt.patientPhone}\n${appt.patientEmail}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        DataCell(Text(appt.date)),
                        DataCell(Text(appt.timeSlot)),
                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(
                              appt.reason.isEmpty
                                  ? 'Không ghi lý do'
                                  : appt.reason,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              getStatusLabel(appt.status),
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          DropdownButton<String>(
                            value: appt.status,
                            underline: const SizedBox(),
                            icon: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.blue,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'PENDING',
                                child: Text('Chờ xác nhận'),
                              ),
                              DropdownMenuItem(
                                value: 'CONFIRMED',
                                child: Text('Xác nhận lịch'),
                              ),
                              DropdownMenuItem(
                                value: 'COMPLETED',
                                child: Text('Đã hoàn thành'),
                              ),
                              DropdownMenuItem(
                                value: 'CANCELLED',
                                child: Text('Hủy lịch'),
                              ),
                            ],
                            onChanged: (newStatus) {
                              if (newStatus != null &&
                                  newStatus != appt.status) {
                                changeStatus(appt, newStatus);
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
