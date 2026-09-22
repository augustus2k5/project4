import 'package:flutter/material.dart';

import '../../../services/api_service.dart';

class AdminMedicalRecords extends StatefulWidget {
  const AdminMedicalRecords({super.key});

  @override
  State<AdminMedicalRecords> createState() => _AdminMedicalRecordsState();
}

class _AdminMedicalRecordsState extends State<AdminMedicalRecords> {
  List<dynamic> records = [];
  List<dynamic> filteredRecords = [];
  List<dynamic> appointments = [];

  bool loading = true;
  String searchText = '';

  final Color primaryColor = const Color(0xFF1565C0);
  final Color backgroundColor = const Color(0xFFF5F7FB);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> loadData() async {
    try {
      setState(() {
        loading = true;
      });

      final results = await Future.wait([
        ApiService.getMedicalRecords(),
        ApiService.getAppointments(),
      ]);

      if (!mounted) return;

      setState(() {
        records = results[0];
        filteredRecords = results[0];
        appointments = results[1];
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải dữ liệu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void searchRecords(String value) {
    searchText = value.toLowerCase().trim();

    setState(() {
      filteredRecords = records.where((record) {
        final patientName = getPatientName(record).toLowerCase();
        final doctorName = getDoctorName(record).toLowerCase();

        final diagnosis =
            record['diagnosis']?.toString().toLowerCase() ?? '';

        final notes =
            record['notes']?.toString().toLowerCase() ?? '';

        return patientName.contains(searchText) ||
            doctorName.contains(searchText) ||
            diagnosis.contains(searchText) ||
            notes.contains(searchText);
      }).toList();
    });
  }

  // ============================================================
  // GET PATIENT
  // ============================================================

  String getPatientName(dynamic record) {
    final patient = record['patientId'];

    if (patient is Map) {
      return patient['fullName']?.toString() ?? 'Không xác định';
    }

    return 'Không xác định';
  }

  String getPatientPhone(dynamic record) {
    final patient = record['patientId'];

    if (patient is Map) {
      return patient['phoneNumber']?.toString() ?? '';
    }

    return '';
  }

  // ============================================================
  // GET DOCTOR
  // ============================================================

  String getDoctorName(dynamic record) {
    final doctor = record['doctorId'];

    if (doctor is Map) {
      final user = doctor['userId'];

      if (user is Map) {
        return user['fullName']?.toString() ?? 'Không xác định';
      }
    }

    return 'Không xác định';
  }

  // ============================================================
  // GET APPOINTMENT
  // ============================================================

  String getAppointmentDate(dynamic record) {
    final appointment = record['appointmentId'];

    if (appointment is Map) {
      return appointment['date']?.toString() ?? '';
    }

    // Nếu API chưa populate appointmentId
    final appointmentId = appointment?.toString();

    if (appointmentId != null && appointmentId.isNotEmpty) {
      for (final item in appointments) {
        final id = item['_id']?.toString();

        if (id == appointmentId) {
          return item['date']?.toString() ?? '';
        }
      }
    }

    return '';
  }

  String getAppointmentTime(dynamic record) {
    final appointment = record['appointmentId'];

    if (appointment is Map) {
      return appointment['timeSlot']?.toString() ?? '';
    }

    final appointmentId = appointment?.toString();

    if (appointmentId != null && appointmentId.isNotEmpty) {
      for (final item in appointments) {
        final id = item['_id']?.toString();

        if (id == appointmentId) {
          return item['timeSlot']?.toString() ?? '';
        }
      }
    }

    return '';
  }

  // ============================================================
  // GET APPOINTMENT BY ID
  // ============================================================

  dynamic getAppointmentById(String? id) {
    if (id == null || id.isEmpty) {
      return null;
    }

    for (final item in appointments) {
      final itemId = item['_id']?.toString();

      if (itemId == id) {
        return item;
      }
    }

    return null;
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteRecord(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 10),
              Text('Xóa hồ sơ'),
            ],
          ),
          content: const Text(
            'Bạn có chắc chắn muốn xóa hồ sơ bệnh án này?\n'
            'Dữ liệu sau khi xóa sẽ không thể khôi phục.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Xóa hồ sơ'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ApiService.deleteMedicalRecord(id);

      await loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa hồ sơ bệnh án thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xóa thất bại: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // DETAIL
  // ============================================================

  void showDetail(dynamic record) {
    final prescriptions = record['prescriptions'] is List
        ? record['prescriptions'] as List
        : [];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            width: 720,
            constraints: const BoxConstraints(
              maxHeight: 700,
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.medical_information_outlined,
                        color: primaryColor,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chi tiết hồ sơ bệnh án',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Thông tin khám và điều trị',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _infoCard(
                          icon: Icons.person_outline,
                          title: 'Thông tin bệnh nhân',
                          children: [
                            _detailRow(
                              'Họ tên',
                              getPatientName(record),
                            ),
                            _detailRow(
                              'Số điện thoại',
                              getPatientPhone(record),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        _infoCard(
                          icon: Icons.medical_services_outlined,
                          title: 'Thông tin khám',
                          children: [
                            _detailRow(
                              'Bác sĩ',
                              getDoctorName(record),
                            ),
                            _detailRow(
                              'Ngày khám',
                              getAppointmentDate(record),
                            ),
                            _detailRow(
                              'Khung giờ',
                              getAppointmentTime(record),
                            ),
                            _detailRow(
                              'Chẩn đoán',
                              record['diagnosis']?.toString() ?? '',
                            ),
                            _detailRow(
                              'Ghi chú',
                              record['notes']?.toString() ?? '',
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        _infoCard(
                          icon: Icons.medication_outlined,
                          title: 'Đơn thuốc',
                          children: [
                            if (prescriptions.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Không có đơn thuốc',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            else
                              ...prescriptions.map(
                                (item) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                      bottom: 8,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: Colors.blue
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.medication,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['drugName']
                                                        ?.toString() ??
                                                    'Thuốc',
                                                style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                'Số lượng: ${item['quantity'] ?? 0}  •  ${item['dosage'] ?? ''}',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD / EDIT RECORD
  // ============================================================

  void showRecordDialog({
    dynamic record,
  }) {
    final isEdit = record != null;
    final pageContext = context;

    final diagnosisController = TextEditingController(
      text: isEdit
          ? record['diagnosis']?.toString() ?? ''
          : '',
    );

    final notesController = TextEditingController(
      text: isEdit
          ? record['notes']?.toString() ?? ''
          : '',
    );

    String? selectedAppointmentId;

    if (isEdit) {
      final appointment = record['appointmentId'];

      if (appointment is Map) {
        selectedAppointmentId =
            appointment['_id']?.toString();
      } else {
        selectedAppointmentId =
            appointment?.toString();
      }
    }

    String? selectedPatientId;

    if (isEdit) {
      final patient = record['patientId'];

      if (patient is Map) {
        selectedPatientId =
            patient['_id']?.toString();
      } else {
        selectedPatientId =
            patient?.toString();
      }
    }

    String? selectedDoctorId;

    if (isEdit) {
      final doctor = record['doctorId'];

      if (doctor is Map) {
        selectedDoctorId =
            doctor['_id']?.toString();
      } else {
        selectedDoctorId =
            doctor?.toString();
      }
    }

    final prescriptionControllers =
        <Map<String, TextEditingController>>[];

    if (isEdit &&
        record['prescriptions'] is List) {
      for (final item
          in record['prescriptions']) {
        prescriptionControllers.add({
          'drugName': TextEditingController(
            text: item['drugName']?.toString() ?? '',
          ),
          'quantity': TextEditingController(
            text: item['quantity']?.toString() ?? '1',
          ),
          'dosage': TextEditingController(
            text: item['dosage']?.toString() ?? '',
          ),
        });
      }
    }

    void addPrescription() {
      prescriptionControllers.add({
        'drugName': TextEditingController(),
        'quantity': TextEditingController(text: '1'),
        'dosage': TextEditingController(),
      });
    }

    if (prescriptionControllers.isEmpty) {
      addPrescription();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            final selectedAppointment =
                getAppointmentById(
              selectedAppointmentId,
            );

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                width: 820,
                constraints: const BoxConstraints(
                  maxHeight: 760,
                ),
                child: Column(
                  children: [
                    // ======================================================
                    // HEADER
                    // ======================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isEdit
                                  ? Icons.edit_note
                                  : Icons.note_add_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEdit
                                      ? 'Chỉnh sửa hồ sơ bệnh án'
                                      : 'Thêm hồ sơ bệnh án',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isEdit
                                      ? 'Cập nhật thông tin khám và điều trị'
                                      : 'Tạo hồ sơ khám bệnh mới cho bệnh nhân',
                                  style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ======================================================
                    // BODY
                    // ======================================================

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // ==================================================
                            // SECTION 1
                            // ==================================================

                            _formSectionTitle(
                              icon: Icons.calendar_month_outlined,
                              title: 'Thông tin lịch khám',
                              subtitle:
                                  'Chọn lịch hẹn để liên kết với hồ sơ bệnh án',
                            ),

                            const SizedBox(height: 12),

                            DropdownButtonFormField<String>(
                              value: appointments.any(
                                (appointment) {
                                  final id =
                                      appointment['_id'] ??
                                          appointment['id'];

                                  return id?.toString() ==
                                      selectedAppointmentId;
                                },
                              )
                                  ? selectedAppointmentId
                                  : null,
                              isExpanded: true,
                              decoration:
                                  InputDecoration(
                                labelText:
                                    'Lịch hẹn *',
                                hintText:
                                    'Chọn lịch hẹn',
                                prefixIcon:
                                    const Icon(
                                  Icons.event_note,
                                ),
                                filled: true,
                                fillColor:
                                    const Color(
                                        0xFFF8FAFC),
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          12),
                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          12),
                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(0xFFE2E8F0),
                                  ),
                                ),
                              ),
                              items: appointments
                                  .where(
                                (item) {
                                  final id =
                                      item['_id'] ??
                                          item['id'];

                                  return id != null &&
                                      id.toString().isNotEmpty;
                                },
                              )
                                  .map<
                                      DropdownMenuItem<
                                          String>>(
                                (item) {
                                  final id =
                                      (item['_id'] ??
                                              item['id'])
                                          .toString();

                                  final patient =
                                      item['patientId'];

                                  final doctor =
                                      item['doctorId'];

                                  String patientName =
                                      'Bệnh nhân';

                                  if (patient is Map) {
                                    patientName =
                                        patient[
                                                    'fullName']
                                                ?.toString() ??
                                            'Bệnh nhân';
                                  }

                                  String doctorName =
                                      'Bác sĩ';

                                  if (doctor is Map) {
                                    final user =
                                        doctor['userId'];

                                    if (user is Map) {
                                      doctorName =
                                          user[
                                                      'fullName']
                                                  ?.toString() ??
                                              'Bác sĩ';
                                    }
                                  }

                                  final date =
                                      item['date']
                                              ?.toString() ??
                                          '';

                                  final time =
                                      item['timeSlot']
                                              ?.toString() ??
                                          '';

                                  return DropdownMenuItem<
                                      String>(
                                    value: id,
                                    child: Text(
                                      '$patientName  •  $doctorName  •  $date  $time',
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                    ),
                                  );
                                },
                              )
                                  .toList(),
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedAppointmentId =
                                      value;

                                  final appointment =
                                      getAppointmentById(
                                    value,
                                  );

                                  if (appointment !=
                                      null) {
                                    final patient =
                                        appointment[
                                            'patientId'];

                                    final doctor =
                                        appointment[
                                            'doctorId'];

                                    if (patient is Map) {
                                      selectedPatientId =
                                          patient['_id']
                                              ?.toString();
                                    } else {
                                      selectedPatientId =
                                          patient
                                              ?.toString();
                                    }

                                    if (doctor is Map) {
                                      selectedDoctorId =
                                          doctor['_id']
                                              ?.toString();
                                    } else {
                                      selectedDoctorId =
                                          doctor
                                              ?.toString();
                                    }
                                  }
                                });
                              },
                            ),

                            // ==================================================
                            // APPOINTMENT INFO
                            // ==================================================

                            if (selectedAppointment != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: primaryColor
                                      .withValues(
                                          alpha: 0.06),
                                  borderRadius:
                                      BorderRadius.circular(
                                          14),
                                  border: Border.all(
                                    color: primaryColor
                                        .withValues(
                                            alpha: 0.18),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .check_circle_outline,
                                          color:
                                              primaryColor,
                                          size: 20,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          'Thông tin lịch hẹn đã chọn',
                                          style:
                                              TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            color:
                                                primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                        height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child:
                                              _appointmentInfoItem(
                                            Icons.person_outline,
                                            'Bệnh nhân',
                                            selectedAppointment[
                                                        'patientId']
                                                    is Map
                                                ? selectedAppointment[
                                                            'patientId']
                                                        [
                                                        'fullName']
                                                    ?.toString() ??
                                                    'Bệnh nhân'
                                                : 'Bệnh nhân',
                                          ),
                                        ),
                                        Expanded(
                                          child:
                                              _appointmentInfoItem(
                                            Icons
                                                .medical_services_outlined,
                                            'Bác sĩ',
                                            selectedAppointment[
                                                        'doctorId']
                                                    is Map
                                                ? _getDoctorNameFromAppointment(
                                                    selectedAppointment,
                                                  )
                                                : 'Bác sĩ',
                                          ),
                                        ),
                                        Expanded(
                                          child:
                                              _appointmentInfoItem(
                                            Icons
                                                .calendar_today_outlined,
                                            'Ngày khám',
                                            selectedAppointment[
                                                        'date']
                                                    ?.toString() ??
                                                '',
                                          ),
                                        ),
                                        Expanded(
                                          child:
                                              _appointmentInfoItem(
                                            Icons
                                                .schedule_outlined,
                                            'Khung giờ',
                                            selectedAppointment[
                                                        'timeSlot']
                                                    ?.toString() ??
                                                '',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 28),

                            // ==================================================
                            // SECTION 2
                            // ==================================================

                            _formSectionTitle(
                              icon: Icons.medical_information_outlined,
                              title: 'Thông tin khám bệnh',
                              subtitle:
                                  'Nhập kết quả chẩn đoán và ghi chú của bác sĩ',
                            ),

                            const SizedBox(height: 12),

                            TextField(
                              controller:
                                  diagnosisController,
                              maxLines: 3,
                              decoration:
                                  InputDecoration(
                                labelText:
                                    'Chẩn đoán *',
                                hintText:
                                    'Nhập chẩn đoán của bác sĩ...',
                                prefixIcon:
                                    const Padding(
                                  padding:
                                      EdgeInsets.only(
                                    bottom: 45,
                                  ),
                                  child: Icon(
                                    Icons
                                        .health_and_safety_outlined,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    const Color(
                                        0xFFF8FAFC),
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          12),
                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(0xFFE2E8F0),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            TextField(
                              controller:
                                  notesController,
                              maxLines: 4,
                              decoration:
                                  InputDecoration(
                                labelText:
                                    'Ghi chú',
                                hintText:
                                    'Nhập ghi chú, hướng dẫn điều trị...',
                                prefixIcon:
                                    const Padding(
                                  padding:
                                      EdgeInsets.only(
                                    bottom: 65,
                                  ),
                                  child: Icon(
                                    Icons
                                        .notes_outlined,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    const Color(
                                        0xFFF8FAFC),
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          12),
                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(0xFFE2E8F0),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ==================================================
                            // SECTION 3 - PRESCRIPTIONS
                            // ==================================================

                            Row(
                              children: [
                                Expanded(
                                  child:
                                      _formSectionTitle(
                                    icon: Icons
                                        .medication_outlined,
                                    title:
                                        'Đơn thuốc',
                                    subtitle:
                                        'Danh sách thuốc được kê cho bệnh nhân',
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    setDialogState(
                                      () {
                                        addPrescription();
                                      },
                                    );
                                  },
                                  icon:
                                      const Icon(
                                    Icons.add,
                                    size: 19,
                                  ),
                                  label:
                                      const Text(
                                    'Thêm thuốc',
                                  ),
                                  style:
                                      OutlinedButton
                                          .styleFrom(
                                    foregroundColor:
                                        primaryColor,
                                    side:
                                        BorderSide(
                                      color:
                                          primaryColor,
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  10),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            if (prescriptionControllers
                                .isEmpty)
                              Container(
                                width:
                                    double.infinity,
                                padding:
                                    const EdgeInsets
                                        .all(24),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                          0xFFF8FAFC),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              14),
                                  border:
                                      Border.all(
                                    color:
                                        const Color(
                                            0xFFE2E8F0),
                                  ),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons
                                          .medication_outlined,
                                      size: 35,
                                      color:
                                          Colors.grey,
                                    ),
                                    SizedBox(
                                        height: 8),
                                    Text(
                                      'Chưa có thuốc',
                                      style:
                                          TextStyle(
                                        color:
                                            Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            ...prescriptionControllers
                                .asMap()
                                .entries
                                .map(
                              (entry) {
                                final index =
                                    entry.key;

                                final controllers =
                                    entry.value;

                                return Container(
                                  margin:
                                      const EdgeInsets
                                          .only(
                                    bottom: 12,
                                  ),
                                  padding:
                                      const EdgeInsets
                                          .all(16),
                                  decoration:
                                      BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                14),
                                    border:
                                        Border.all(
                                      color:
                                          const Color(
                                              0xFFE2E8F0),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors
                                            .black
                                            .withValues(
                                                alpha:
                                                    0.03),
                                        blurRadius: 8,
                                        offset:
                                            const Offset(
                                          0,
                                          3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            alignment:
                                                Alignment
                                                    .center,
                                            decoration:
                                                BoxDecoration(
                                              color:
                                                  primaryColor.withValues(
                                                alpha:
                                                    0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          8),
                                            ),
                                            child:
                                                Text(
                                              '${index + 1}',
                                              style:
                                                  TextStyle(
                                                color:
                                                    primaryColor,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          const Expanded(
                                            child:
                                                Text(
                                              'Thông tin thuốc',
                                              style:
                                                  TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            tooltip:
                                                'Xóa thuốc',
                                            onPressed:
                                                () {
                                              setDialogState(
                                                () {
                                                  prescriptionControllers
                                                      .removeAt(
                                                    index,
                                                  );
                                                },
                                              );
                                            },
                                            icon:
                                                const Icon(
                                              Icons
                                                  .delete_outline,
                                              color:
                                                  Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child:
                                                TextField(
                                              controller:
                                                  controllers[
                                                      'drugName'],
                                              decoration:
                                                  InputDecoration(
                                                labelText:
                                                    'Tên thuốc',
                                                hintText:
                                                    'Ví dụ: Paracetamol',
                                                prefixIcon:
                                                    const Icon(
                                                  Icons
                                                      .medication,
                                                ),
                                                filled:
                                                    true,
                                                fillColor:
                                                    const Color(
                                                        0xFFF8FAFC),
                                                border:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child:
                                                TextField(
                                              controller:
                                                  controllers[
                                                      'quantity'],
                                              keyboardType:
                                                  TextInputType
                                                      .number,
                                              decoration:
                                                  InputDecoration(
                                                labelText:
                                                    'SL',
                                                filled:
                                                    true,
                                                fillColor:
                                                    const Color(
                                                        0xFFF8FAFC),
                                                border:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child:
                                                TextField(
                                              controller:
                                                  controllers[
                                                      'dosage'],
                                              decoration:
                                                  InputDecoration(
                                                labelText:
                                                    'Liều dùng / Cách dùng',
                                                hintText:
                                                    'Ví dụ: Ngày 2 lần, mỗi lần 1 viên',
                                                prefixIcon:
                                                    const Icon(
                                                  Icons
                                                      .schedule,
                                                ),
                                                filled:
                                                    true,
                                                fillColor:
                                                    const Color(
                                                        0xFFF8FAFC),
                                                border:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ======================================================
                    // FOOTER
                    // ======================================================

                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        24,
                        16,
                        24,
                        20,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.only(
                          bottomLeft:
                              Radius.circular(24),
                          bottomRight:
                              Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(
                                dialogContext,
                              );
                            },
                            style:
                                OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 22,
                                vertical: 14,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        10),
                              ),
                            ),
                            child:
                                const Text('Hủy'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (selectedAppointmentId ==
                                      null ||
                                  selectedPatientId ==
                                      null ||
                                  selectedDoctorId ==
                                      null) {
                                ScaffoldMessenger.of(
                                  pageContext,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Vui lòng chọn lịch hẹn',
                                    ),
                                    backgroundColor:
                                        Colors.orange,
                                  ),
                                );
                                return;
                              }

                              if (diagnosisController
                                  .text
                                  .trim()
                                  .isEmpty) {
                                ScaffoldMessenger.of(
                                  pageContext,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Vui lòng nhập chẩn đoán',
                                    ),
                                    backgroundColor:
                                        Colors.orange,
                                  ),
                                );
                                return;
                              }

                              final prescriptions =
                                  prescriptionControllers
                                      .map(
                                (item) {
                                  return {
                                    'drugName':
                                        item['drugName']!
                                            .text
                                            .trim(),
                                    'quantity':
                                        int.tryParse(
                                              item[
                                                      'quantity']!
                                                  .text
                                                  .trim(),
                                            ) ??
                                            1,
                                    'dosage':
                                        item['dosage']!
                                            .text
                                            .trim(),
                                  };
                                },
                              )
                                      .where(
                                (item) =>
                                    item['drugName']
                                        .toString()
                                        .isNotEmpty,
                              )
                                      .toList();

                              try {
                                if (isEdit) {
                                  await ApiService
                                      .updateMedicalRecord(
                                    id: record['_id']
                                        .toString(),
                                    appointmentId:
                                        selectedAppointmentId!,
                                    patientId:
                                        selectedPatientId!,
                                    doctorId:
                                        selectedDoctorId!,
                                    diagnosis:
                                        diagnosisController
                                            .text
                                            .trim(),
                                    notes:
                                        notesController
                                            .text
                                            .trim(),
                                    prescriptions:
                                        prescriptions,
                                  );
                                } else {
                                  await ApiService
                                      .createMedicalRecord(
                                    appointmentId:
                                        selectedAppointmentId!,
                                    patientId:
                                        selectedPatientId!,
                                    doctorId:
                                        selectedDoctorId!,
                                    diagnosis:
                                        diagnosisController
                                            .text
                                            .trim(),
                                    notes:
                                        notesController
                                            .text
                                            .trim(),
                                    prescriptions:
                                        prescriptions,
                                  );
                                }

                                if (!mounted) return;

                                Navigator.pop(
                                  dialogContext,
                                );

                                await loadData();

                                if (!mounted) return;

                                ScaffoldMessenger.of(
                                  pageContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEdit
                                          ? 'Cập nhật hồ sơ thành công'
                                          : 'Thêm hồ sơ thành công',
                                    ),
                                    backgroundColor:
                                        Colors.green,
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;

                                ScaffoldMessenger.of(
                                  pageContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Thao tác thất bại: $e',
                                    ),
                                    backgroundColor:
                                        Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: Icon(
                              isEdit
                                  ? Icons.save_outlined
                                  : Icons.add,
                            ),
                            label: Text(
                              isEdit
                                  ? 'Lưu thay đổi'
                                  : 'Tạo hồ sơ',
                            ),
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  primaryColor,
                              foregroundColor:
                                  Colors.white,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 22,
                                vertical: 14,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // FORM SECTION TITLE
  // ============================================================

  Widget _formSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 21,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // APPOINTMENT INFO
  // ============================================================

  Widget _appointmentInfoItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: primaryColor,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '—' : value,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDoctorNameFromAppointment(
    dynamic appointment,
  ) {
    final doctor = appointment['doctorId'];

    if (doctor is Map) {
      final user = doctor['userId'];

      if (user is Map) {
        return user['fullName']?.toString() ??
            'Bác sĩ';
      }
    }

    return 'Bác sĩ';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor
                        .withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.medical_information_outlined,
                    color: primaryColor,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quản lý hồ sơ bệnh án',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Theo dõi thông tin khám và điều trị của bệnh nhân',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: loading
                      ? null
                      : loadData,
                  icon: const Icon(
                    Icons.refresh,
                    size: 19,
                  ),
                  label: const Text(
                    'Làm mới',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(
                      color: primaryColor
                          .withValues(alpha: 0.5),
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    showRecordDialog();
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 20,
                  ),
                  label: const Text(
                    'Thêm hồ sơ',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryColor,
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ==================================================
            // STATS
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon: Icons.folder_outlined,
                    title: 'Tổng hồ sơ',
                    value: '${records.length}',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _statCard(
                    icon:
                        Icons.medical_services_outlined,
                    title: 'Có đơn thuốc',
                    value:
                        '${records.where((r) => r['prescriptions'] is List && (r['prescriptions'] as List).isNotEmpty).length}',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _statCard(
                    icon: Icons.calendar_today_outlined,
                    title: 'Lịch hẹn',
                    value:
                        '${appointments.length}',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ==================================================
            // SEARCH
            // ==================================================

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: TextField(
                onChanged: searchRecords,
                decoration: const InputDecoration(
                  hintText:
                      'Tìm bệnh nhân, bác sĩ, chẩn đoán, ghi chú...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // TABLE
            // ==================================================

            Expanded(
              child: loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  : filteredRecords.isEmpty
                      ? _emptyState()
                      : Container(
                          width: double.infinity,
                          decoration:
                              BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                                    16),
                            border: Border.all(
                              color: const Color(
                                  0xFFE5E7EB),
                            ),
                          ),
                          child:
                              SingleChildScrollView(
                            child:
                                SingleChildScrollView(
                              scrollDirection:
                                  Axis.horizontal,
                              child: DataTable(
                                headingRowHeight:
                                    52,
                                dataRowMinHeight:
                                    65,
                                dataRowMaxHeight:
                                    72,
                                horizontalMargin:
                                    20,
                                columnSpacing: 30,
                                headingRowColor:
                                    WidgetStateProperty
                                        .all(
                                  const Color(
                                      0xFFF8FAFC),
                                ),
                                columns: const [
                                  DataColumn(
                                    label:
                                        Text('STT'),
                                  ),
                                  DataColumn(
                                    label: Text(
                                        'BỆNH NHÂN'),
                                  ),
                                  DataColumn(
                                    label: Text(
                                        'BÁC SĨ'),
                                  ),
                                  DataColumn(
                                    label: Text(
                                        'NGÀY KHÁM'),
                                  ),
                                  DataColumn(
                                    label: Text(
                                        'CHẨN ĐOÁN'),
                                  ),
                                  DataColumn(
                                    label: Text(
                                        'THAO TÁC'),
                                  ),
                                ],
                                rows: filteredRecords
                                    .asMap()
                                    .entries
                                    .map(
                                  (entry) {
                                    final index =
                                        entry.key;
                                    final record =
                                        entry.value;

                                    final patient =
                                        getPatientName(
                                            record);
                                    final doctor =
                                        getDoctorName(
                                            record);
                                    final date =
                                        getAppointmentDate(
                                            record);
                                    final time =
                                        getAppointmentTime(
                                            record);
                                    final diagnosis =
                                        record[
                                                    'diagnosis']
                                                ?.toString() ??
                                            '';

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            '${index + 1}',
                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .w600,
                                            ),
                                          ),
                                        ),

                                        DataCell(
                                          Row(
                                            mainAxisSize:
                                                MainAxisSize
                                                    .min,
                                            children: [
                                              _avatar(
                                                patient,
                                                Colors
                                                    .blue,
                                              ),
                                              const SizedBox(
                                                  width:
                                                      10),
                                              Text(
                                                patient,
                                                style:
                                                    const TextStyle(
                                                  fontWeight:
                                                      FontWeight
                                                          .w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        DataCell(
                                          Row(
                                            mainAxisSize:
                                                MainAxisSize
                                                    .min,
                                            children: [
                                              _avatar(
                                                doctor,
                                                Colors
                                                    .green,
                                              ),
                                              const SizedBox(
                                                  width:
                                                      10),
                                              Text(
                                                doctor,
                                              ),
                                            ],
                                          ),
                                        ),

                                        DataCell(
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                date.isEmpty
                                                    ? '—'
                                                    : date,
                                                style:
                                                    const TextStyle(
                                                  fontWeight:
                                                      FontWeight
                                                          .w600,
                                                ),
                                              ),
                                              if (time
                                                  .isNotEmpty)
                                                Text(
                                                  time,
                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        Colors.grey,
                                                    fontSize:
                                                        12,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                        DataCell(
                                          SizedBox(
                                            width: 260,
                                            child: Text(
                                              diagnosis
                                                      .isEmpty
                                                  ? '—'
                                                  : diagnosis,
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),

                                        DataCell(
                                          Row(
                                            mainAxisSize:
                                                MainAxisSize
                                                    .min,
                                            children: [
                                              _actionButton(
                                                tooltip:
                                                    'Xem chi tiết',
                                                icon: Icons
                                                    .visibility_outlined,
                                                color: Colors
                                                    .blue,
                                                onPressed:
                                                    () {
                                                  showDetail(
                                                      record);
                                                },
                                              ),
                                              _actionButton(
                                                tooltip:
                                                    'Chỉnh sửa',
                                                icon: Icons
                                                    .edit_outlined,
                                                color: Colors
                                                    .orange,
                                                onPressed:
                                                    () {
                                                  showRecordDialog(
                                                    record:
                                                        record,
                                                  );
                                                },
                                              ),
                                              _actionButton(
                                                tooltip:
                                                    'Xóa',
                                                icon: Icons
                                                    .delete_outline,
                                                color: Colors
                                                    .red,
                                                onPressed:
                                                    () {
                                                  deleteRecord(
                                                    record['_id']
                                                        .toString(),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 13),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _avatar(
    String name,
    Color color,
  ) {
    final letter = name.isNotEmpty
        ? name.trim().substring(0, 1).toUpperCase()
        : '?';

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _actionButton({
    required String tooltip,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 20,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color:
                  primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open_outlined,
              size: 40,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            searchText.isEmpty
                ? 'Chưa có hồ sơ bệnh án'
                : 'Không tìm thấy hồ sơ phù hợp',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            searchText.isEmpty
                ? 'Hãy tạo hồ sơ bệnh án đầu tiên.'
                : 'Thử tìm kiếm bằng từ khóa khác.',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          if (searchText.isEmpty) ...[
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                showRecordDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text(
                'Thêm hồ sơ bệnh án',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}