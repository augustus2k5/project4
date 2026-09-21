import 'package:flutter/material.dart';

import '../../models/patient_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class AdminPatients extends StatefulWidget {
  const AdminPatients({super.key});

  @override
  State<AdminPatients> createState() => _AdminPatientsState();
}

class _AdminPatientsState extends State<AdminPatients> {
  List<PatientModel> patients = [];
  List<UserModel> users = [];

  Map<String, UserModel> usersById = {};

  bool loading = true;
  String? error;

  String search = '';

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
        error = null;
      });

      final results = await Future.wait([
        ApiService.getPatients(),
        ApiService.getUsers(),
      ]);

      final loadedPatients = results[0] as List<PatientModel>;
      final loadedUsers = results[1] as List<UserModel>;

      final userMap = <String, UserModel>{
        for (final user in loadedUsers) user.id.toString(): user,
      };

      if (!mounted) return;

      setState(() {
        patients = loadedPatients;
        users = loadedUsers;
        usersById = userMap;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  // ============================================================
  // DISPLAY INFORMATION
  // ============================================================

  String displayName(PatientModel patient) {
    if (patient.fullName.trim().isNotEmpty) {
      return patient.fullName;
    }

    final user = usersById[patient.userId.toString()];

    return user?.fullName ?? '';
  }

  String displayEmail(PatientModel patient) {
    if (patient.email.trim().isNotEmpty) {
      return patient.email;
    }

    final user = usersById[patient.userId.toString()];

    return user?.email ?? '';
  }

  String displayPhone(PatientModel patient) {
    if (patient.phoneNumber.trim().isNotEmpty) {
      return patient.phoneNumber;
    }

    final user = usersById[patient.userId.toString()];

    return user?.phoneNumber ?? '';
  }

  // ============================================================
  // SEARCH
  // ============================================================

  List<PatientModel> get filteredPatients {
    final keyword = search.trim().toLowerCase();

    if (keyword.isEmpty) {
      return patients;
    }

    return patients.where((patient) {
      final name = displayName(patient).toLowerCase();
      final email = displayEmail(patient).toLowerCase();
      final phone = displayPhone(patient).toLowerCase();
      final code = patient.patientCode.toLowerCase();
      final address = patient.address.toLowerCase();

      return name.contains(keyword) ||
          email.contains(keyword) ||
          phone.contains(keyword) ||
          code.contains(keyword) ||
          address.contains(keyword);
    }).toList();
  }

  // ============================================================
  // USER CHƯA CÓ HỒ SƠ BỆNH NHÂN
  // ============================================================

  List<UserModel> get patientUsers {
    final patientUserIds = patients
        .map((patient) => patient.userId.toString())
        .toSet();

    return users.where((user) {
      return user.role.toUpperCase() == 'PATIENT' &&
          !patientUserIds.contains(user.id.toString());
    }).toList();
  }

  // ============================================================
  // ADD PATIENT
  // ============================================================

  Future<void> addPatient() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AddPatientDialog(
        users: patientUsers,
      ),
    );

    if (result == true) {
      await loadData();
    }
  }

  // ============================================================
  // EDIT PATIENT
  // ============================================================

  Future<void> editPatient(PatientModel patient) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => EditPatientDialog(
        patient: patient,
      ),
    );

    if (result == true) {
      await loadData();
    }
  }

  // ============================================================
  // DELETE PATIENT
  // ============================================================

  Future<void> deletePatient(PatientModel patient) async {
    final name = displayName(patient).trim().isNotEmpty
        ? displayName(patient)
        : patient.patientCode;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
            'Bạn có chắc chắn muốn xóa bệnh nhân "$name" không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ApiService.deletePatient(patient.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa bệnh nhân thành công'),
          backgroundColor: Colors.green,
        ),
      );

      await loadData();
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

  void showPatientDetail(PatientModel patient) {
    final user = usersById[patient.userId.toString()];

    showDialog(
      context: context,
      builder: (_) => PatientDetailDialog(
        patient: patient,
        user: user,
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;

      case 'INACTIVE':
        return Colors.orange;

      case 'BLOCKED':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  String statusText(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Đang hoạt động';

      case 'INACTIVE':
        return 'Không hoạt động';

      case 'BLOCKED':
        return 'Đã khóa';

      default:
        return status;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final data = filteredPatients;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              children: [
                const Text(
                  'Quản lý bệnh nhân',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: addPatient,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm bệnh nhân'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SEARCH
            // ==================================================

            TextField(
              decoration: InputDecoration(
                hintText:
                    'Tìm theo mã bệnh nhân, họ tên, email, SĐT, địa chỉ...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // ==================================================
            // CONTENT
            // ==================================================

            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 50,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                error!,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: loadData,
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: data.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Không có bệnh nhân nào',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : Scrollbar(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      child: DataTable(
                                        // ==================================================
                                        // TABLE
                                        // ==================================================

                                        columnSpacing: 8,
                                        horizontalMargin: 10,
                                        headingRowHeight: 55,
                                        dataRowMinHeight: 65,
                                        dataRowMaxHeight: 75,

                                        // ==================================================
                                        // COLUMNS
                                        // ==================================================

                                        columns: const [
                                          // STT
                                          DataColumn(
                                            label: SizedBox(
                                              width: 35,
                                              child: Center(
                                                child: Text(
                                                  'STT',
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // MÃ BN
                                          DataColumn(
                                            label: SizedBox(
                                              width: 60,
                                              child: Center(
                                                child: Text(
                                                  'Mã BN',
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // HỌ TÊN
                                          DataColumn(
                                            label: SizedBox(
                                              width: 135,
                                              child: Text(
                                                'Họ tên',
                                                style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // NGÀY SINH
                                          DataColumn(
                                            label: SizedBox(
                                              width: 90,
                                              child: Center(
                                                child: Text(
                                                  'Ngày sinh',
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // GIỚI TÍNH
                                          DataColumn(
                                            label: SizedBox(
                                              width: 65,
                                              child: Center(
                                                child: Text(
                                                  'Giới tính',
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // SĐT
                                          DataColumn(
                                            label: SizedBox(
                                              width: 100,
                                              child: Center(
                                                child: Text(
                                                  'SĐT',
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // ĐỊA CHỈ
                                          DataColumn(
                                            label: SizedBox(
                                              width: 155,
                                              child: Text(
                                                'Địa chỉ',
                                                style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // TRẠNG THÁI
                                          DataColumn(
                                            label: SizedBox(
                                              width: 120,
                                              child: Center(
                                                child: Text(
                                                  'Trạng thái',
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // THAO TÁC
                                          DataColumn(
                                            label: SizedBox(
                                              width: 120,
                                              child: Center(
                                                child: Text(
                                                  'Thao tác',
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],

                                        // ==================================================
                                        // ROWS
                                        // ==================================================

                                        rows: List.generate(
                                          data.length,
                                          (index) {
                                            final patient = data[index];

                                            final name =
                                                displayName(patient);

                                            final phone =
                                                displayPhone(patient);

                                            return DataRow(
                                              cells: [
                                                // ==================================================
                                                // STT
                                                // ==================================================

                                                DataCell(
                                                  SizedBox(
                                                    width: 35,
                                                    child: Center(
                                                      child: Text(
                                                        '${index + 1}',
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // ==================================================
                                                // MÃ BN
                                                // ==================================================

                                                DataCell(
                                                  SizedBox(
                                                    width: 60,
                                                    child: Center(
                                                      child: Text(
                                                        patient.patientCode,
                                                        style:
                                                            const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // ==================================================
                                                // HỌ TÊN
                                                // ==================================================

                                                DataCell(
                                                  SizedBox(
                                                    width: 135,
                                                    child: Text(
                                                      name.isEmpty
                                                          ? 'Chưa có tên'
                                                          : name,
                                                      overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                    ),
                                                  ),
                                                ),

                                                // ==================================================
                                                // NGÀY SINH
                                                // ==================================================

                                                DataCell(
                                                  SizedBox(
                                                    width: 90,
                                                    child: Center(
                                                      child: Text(
                                                        patient.dateOfBirth ==
                                                                null
                                                            ? '---'
                                                            : '${patient.dateOfBirth!.day.toString().padLeft(2, '0')}/'
                                                                '${patient.dateOfBirth!.month.toString().padLeft(2, '0')}/'
                                                                '${patient.dateOfBirth!.year}',
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // ==================================================
                                                // GIỚI TÍNH
                                                // ==================================================

                                                DataCell(
                                                  SizedBox(
                                                    width: 65,
                                                    child: Center(
                                                      child: Text(
                                                        patient.gender ==
                                                                'MALE'
                                                            ? 'Nam'
                                                            : patient.gender ==
                                                                    'FEMALE'
                                                                ? 'Nữ'
                                                                : 'Khác',
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // ==================================================
                                                // SĐT
                                                // ==================================================

                                                DataCell(
                                                  SizedBox(
                                                    width: 100,
                                                    child: Center(
                                                      child: Text(
                                                        phone.isEmpty
                                                            ? '---'
                                                            : phone,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // ==================================================
                                                // ĐỊA CHỈ
                                                // ==================================================

                                                DataCell(
                                                  SizedBox(
                                                    width: 155,
                                                    child: Text(
                                                      patient.address.isEmpty
                                                          ? '---'
                                                          : patient.address,
                                                      overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                    ),
                                                  ),
                                                ),

                                                // ==================================================
                                                // TRẠNG THÁI
                                                // ==================================================

                                                DataCell(
                                                  SizedBox(
                                                    width: 120,
                                                    child: Center(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              statusColor(
                                                            patient.status,
                                                          ).withValues(
                                                            alpha: 0.12,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            20,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          statusText(
                                                            patient.status,
                                                          ),
                                                          style: TextStyle(
                                                            color:
                                                                statusColor(
                                                              patient.status,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // ==================================================
                                                // THAO TÁC
                                                // ==================================================

                                                DataCell(
                                                  SizedBox(
                                                    width: 120,
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          // XEM
                                                          

                                                          // SỬA
                                                          IconButton(
                                                            tooltip:
                                                                'Sửa bệnh nhân',
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                const BoxConstraints(
                                                              minWidth: 32,
                                                              maxWidth: 32,
                                                              minHeight: 40,
                                                              maxHeight: 40,
                                                            ),
                                                            icon:
                                                                const Icon(
                                                              Icons.edit,
                                                              color:
                                                                  Colors.orange,
                                                              size: 20,
                                                            ),
                                                            onPressed: () {
                                                              editPatient(
                                                                patient,
                                                              );
                                                            },
                                                          ),
IconButton(
                                                            tooltip:
                                                                'Xem chi tiết',
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                const BoxConstraints(
                                                              minWidth: 32,
                                                              maxWidth: 32,
                                                              minHeight: 40,
                                                              maxHeight: 40,
                                                            ),
                                                            icon:
                                                                const Icon(
                                                              Icons.visibility,
                                                              color:
                                                                  Colors.blue,
                                                              size: 20,
                                                            ),
                                                            onPressed: () {
                                                              showPatientDetail(
                                                                patient,
                                                              );
                                                            },
                                                          ),
                                                          // XÓA
                                                          IconButton(
                                                            tooltip:
                                                                'Xóa bệnh nhân',
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                const BoxConstraints(
                                                              minWidth: 32,
                                                              maxWidth: 32,
                                                              minHeight: 40,
                                                              maxHeight: 40,
                                                            ),
                                                            icon:
                                                                const Icon(
                                                              Icons.delete,
                                                              color:
                                                                  Colors.red,
                                                              size: 20,
                                                            ),
                                                            onPressed: () {
                                                              deletePatient(
                                                                patient,
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
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
}

// ============================================================================
// ADD PATIENT DIALOG
// ============================================================================

class AddPatientDialog extends StatefulWidget {
  final List<UserModel> users;

  const AddPatientDialog({
    super.key,
    required this.users,
  });

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  UserModel? selectedUser;

  final patientCodeController = TextEditingController();
  final identityCardController = TextEditingController();
  final addressController = TextEditingController();
  final medicalHistoryController = TextEditingController();
  final allergiesController = TextEditingController();

  DateTime? dateOfBirth;

  String gender = 'MALE';

  bool saving = false;

  @override
  void dispose() {
    patientCodeController.dispose();
    identityCardController.dispose();
    addressController.dispose();
    medicalHistoryController.dispose();
    allergiesController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (result != null) {
      setState(() {
        dateOfBirth = result;
      });
    }
  }

  Future<void> save() async {
    if (selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn tài khoản bệnh nhân'),
        ),
      );
      return;
    }

    if (patientCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mã bệnh nhân'),
        ),
      );
      return;
    }

    try {
      setState(() {
        saving = true;
      });

      await ApiService.createPatient(
        userId: selectedUser!.id,
        patientCode: patientCodeController.text.trim(),
        dateOfBirth: dateOfBirth?.toIso8601String(),
        gender: gender,
        identityCard: identityCardController.text.trim(),
        address: addressController.text.trim(),
        medicalHistory: medicalHistoryController.text.trim(),
        allergies: allergiesController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thêm bệnh nhân thất bại: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm bệnh nhân'),
      content: SizedBox(
        width: 650,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<UserModel>(
                decoration: const InputDecoration(
                  labelText: 'Tài khoản bệnh nhân *',
                  border: OutlineInputBorder(),
                ),
                initialValue: selectedUser,
                items: widget.users.map((user) {
                  return DropdownMenuItem<UserModel>(
                    value: user,
                    child: Text(
                      '${user.fullName} - ${user.email}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: saving
                    ? null
                    : (value) {
                        setState(() {
                          selectedUser = value;
                        });
                      },
              ),

              const SizedBox(height: 15),

              if (selectedUser != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Họ tên: ${selectedUser!.fullName}',
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Email: ${selectedUser!.email}',
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'SĐT: ${selectedUser!.phoneNumber}',
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 15),

              TextField(
                controller: patientCodeController,
                decoration: const InputDecoration(
                  labelText: 'Mã bệnh nhân *',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: saving ? null : pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ngày sinh',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          dateOfBirth == null
                              ? 'Chọn ngày sinh'
                              : '${dateOfBirth!.day.toString().padLeft(2, '0')}/'
                                  '${dateOfBirth!.month.toString().padLeft(2, '0')}/'
                                  '${dateOfBirth!.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Giới tính',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: gender,
                      items: const [
                        DropdownMenuItem(
                          value: 'MALE',
                          child: Text('Nam'),
                        ),
                        DropdownMenuItem(
                          value: 'FEMALE',
                          child: Text('Nữ'),
                        ),
                        DropdownMenuItem(
                          value: 'OTHER',
                          child: Text('Khác'),
                        ),
                      ],
                      onChanged: saving
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  gender = value;
                                });
                              }
                            },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              TextField(
                controller: identityCardController,
                decoration: const InputDecoration(
                  labelText: 'CCCD',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: medicalHistoryController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Tiền sử bệnh',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: allergiesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Dị ứng',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: saving ? null : save,
          child: saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Thêm'),
        ),
      ],
    );
  }
}

// ============================================================================
// EDIT PATIENT DIALOG
// ============================================================================

class EditPatientDialog extends StatefulWidget {
  final PatientModel patient;

  const EditPatientDialog({
    super.key,
    required this.patient,
  });

  @override
  State<EditPatientDialog> createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends State<EditPatientDialog> {
  late final TextEditingController patientCodeController;
  late final TextEditingController identityCardController;
  late final TextEditingController addressController;
  late final TextEditingController medicalHistoryController;
  late final TextEditingController allergiesController;

  DateTime? dateOfBirth;

  late String gender;
  late String status;

  bool saving = false;

  @override
  void initState() {
    super.initState();

    patientCodeController = TextEditingController(
      text: widget.patient.patientCode,
    );

    identityCardController = TextEditingController(
      text: widget.patient.identityCard,
    );

    addressController = TextEditingController(
      text: widget.patient.address,
    );

    medicalHistoryController = TextEditingController(
      text: widget.patient.medicalHistory,
    );

    allergiesController = TextEditingController(
      text: widget.patient.allergies,
    );

    dateOfBirth = widget.patient.dateOfBirth;

    gender = widget.patient.gender.isEmpty
        ? 'MALE'
        : widget.patient.gender.toUpperCase();

    if (!['MALE', 'FEMALE', 'OTHER'].contains(gender)) {
      gender = 'OTHER';
    }

    status = widget.patient.status.isEmpty
        ? 'ACTIVE'
        : widget.patient.status.toUpperCase();

    if (!['ACTIVE', 'INACTIVE', 'BLOCKED'].contains(status)) {
      status = 'ACTIVE';
    }
  }

  @override
  void dispose() {
    patientCodeController.dispose();
    identityCardController.dispose();
    addressController.dispose();
    medicalHistoryController.dispose();
    allergiesController.dispose();

    super.dispose();
  }

  Future<void> pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (result != null) {
      setState(() {
        dateOfBirth = result;
      });
    }
  }

  Future<void> save() async {
    try {
      setState(() {
        saving = true;
      });

      await ApiService.updatePatient(
        id: widget.patient.id,
        patientCode: patientCodeController.text.trim(),
        dateOfBirth: dateOfBirth?.toIso8601String(),
        gender: gender,
        identityCard: identityCardController.text.trim(),
        address: addressController.text.trim(),
        medicalHistory: medicalHistoryController.text.trim(),
        allergies: allergiesController.text.trim(),
        status: status,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật bệnh nhân thành công'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật thất bại: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget genderField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Giới tính',
        border: OutlineInputBorder(),
      ),
      initialValue: gender,
      items: const [
        DropdownMenuItem(
          value: 'MALE',
          child: Text('Nam'),
        ),
        DropdownMenuItem(
          value: 'FEMALE',
          child: Text('Nữ'),
        ),
        DropdownMenuItem(
          value: 'OTHER',
          child: Text('Khác'),
        ),
      ],
      onChanged: saving
          ? null
          : (value) {
              if (value != null) {
                setState(() {
                  gender = value;
                });
              }
            },
    );
  }

  Widget statusField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Trạng thái',
        border: OutlineInputBorder(),
      ),
      initialValue: status,
      items: const [
        DropdownMenuItem(
          value: 'ACTIVE',
          child: Text('Đang hoạt động'),
        ),
        DropdownMenuItem(
          value: 'INACTIVE',
          child: Text('Không hoạt động'),
        ),
        DropdownMenuItem(
          value: 'BLOCKED',
          child: Text('Đã khóa'),
        ),
      ],
      onChanged: saving
          ? null
          : (value) {
              if (value != null) {
                setState(() {
                  status = value;
                });
              }
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sửa thông tin bệnh nhân'),
      content: SizedBox(
        width: 650,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: patientCodeController,
                decoration: const InputDecoration(
                  labelText: 'Mã bệnh nhân',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: saving ? null : pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ngày sinh',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          dateOfBirth == null
                              ? 'Chọn ngày sinh'
                              : '${dateOfBirth!.day.toString().padLeft(2, '0')}/'
                                  '${dateOfBirth!.month.toString().padLeft(2, '0')}/'
                                  '${dateOfBirth!.year}',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: genderField(),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              statusField(),

              const SizedBox(height: 15),

              TextField(
                controller: identityCardController,
                decoration: const InputDecoration(
                  labelText: 'CCCD',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: medicalHistoryController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Tiền sử bệnh',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: allergiesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Dị ứng',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: saving ? null : save,
          child: saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Lưu thay đổi'),
        ),
      ],
    );
  }
}

// ============================================================================
// PATIENT DETAIL
// ============================================================================

class PatientDetailDialog extends StatelessWidget {
  final PatientModel patient;
  final UserModel? user;

  const PatientDetailDialog({
    super.key,
    required this.patient,
    this.user,
  });

  String statusText(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Đang hoạt động';

      case 'INACTIVE':
        return 'Không hoạt động';

      case 'BLOCKED':
        return 'Đã khóa';

      default:
        return status;
    }
  }

  Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;

      case 'INACTIVE':
        return Colors.orange;

      case 'BLOCKED':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  String genderText(String gender) {
    switch (gender.toUpperCase()) {
      case 'MALE':
        return 'Nam';

      case 'FEMALE':
        return 'Nữ';

      default:
        return 'Khác';
    }
  }

  Widget info(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '---' : value,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = patient.fullName.trim().isNotEmpty
        ? patient.fullName
        : user?.fullName ?? '';

    final email = patient.email.trim().isNotEmpty
        ? patient.email
        : user?.email ?? '';

    final phone = patient.phoneNumber.trim().isNotEmpty
        ? patient.phoneNumber
        : user?.phoneNumber ?? '';

    return AlertDialog(
      title: Row(
        children: [
          const Icon(
            Icons.person,
            color: Color(0xFF1565C0),
          ),
          const SizedBox(width: 10),
          const Text('Chi tiết bệnh nhân'),
        ],
      ),

      content: SizedBox(
        width: 650,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              info(
                'Mã bệnh nhân',
                patient.patientCode,
              ),

              info(
                'Họ tên',
                name,
              ),

              info(
                'Email',
                email,
              ),

              info(
                'Số điện thoại',
                phone,
              ),

              info(
                'Ngày sinh',
                patient.dateOfBirth == null
                    ? ''
                    : '${patient.dateOfBirth!.day.toString().padLeft(2, '0')}/'
                        '${patient.dateOfBirth!.month.toString().padLeft(2, '0')}/'
                        '${patient.dateOfBirth!.year}',
              ),

              info(
                'Giới tính',
                genderText(patient.gender),
              ),

              info(
                'CCCD',
                patient.identityCard,
              ),

              info(
                'Địa chỉ',
                patient.address,
              ),

              info(
                'Tiền sử bệnh',
                patient.medicalHistory,
              ),

              info(
                'Dị ứng',
                patient.allergies,
              ),

              const SizedBox(height: 5),

              Row(
                children: [
                  const SizedBox(
                    width: 150,
                    child: Text(
                      'Trạng thái',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor(
                        patient.status,
                      ).withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText(patient.status),
                      style: TextStyle(
                        color: statusColor(patient.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}