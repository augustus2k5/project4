import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../models/user_model.dart';
import '../../models/specialty_model.dart';

class AdminDoctors extends StatefulWidget {
  const AdminDoctors({super.key});

  @override
  State<AdminDoctors> createState() => _AdminDoctorsState();
}

class _AdminDoctorsState extends State<AdminDoctors> {
  List<dynamic> doctors = [];
  List<dynamic> filteredDoctors = [];

  bool loading = true;
  String? errorMessage;

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    loadDoctors();

    searchController.addListener(() {
      filterDoctors();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> loadDoctors() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      final data = await ApiService.getDoctors();

      if (!mounted) return;

      setState(() {
        doctors = data;
        filteredDoctors = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void filterDoctors() {
    final keyword = searchController.text.trim().toLowerCase();

    if (keyword.isEmpty) {
      if (!mounted) return;

      setState(() {
        filteredDoctors = doctors;
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      filteredDoctors = doctors.where((doctor) {
        final name = getUserValue(
          doctor,
          'fullName',
        ).toLowerCase();

        final email = getUserValue(
          doctor,
          'email',
        ).toLowerCase();

        final phone = getUserValue(
          doctor,
          'phoneNumber',
        ).toLowerCase();

        final specialty = getSpecialtyName(
          doctor,
        ).toLowerCase();

        return name.contains(keyword) ||
            email.contains(keyword) ||
            phone.contains(keyword) ||
            specialty.contains(keyword);
      }).toList();
    });
  }

  // ============================================================
  // USER VALUE
  // ============================================================

  String getUserValue(
    dynamic doctor,
    String field,
  ) {
    if (doctor is! Map) {
      return '';
    }

    final user = doctor['userId'];

    if (user is Map) {
      return user[field]?.toString() ?? '';
    }

    return '';
  }

  // ============================================================
  // SPECIALTY
  // ============================================================

  String getSpecialtyName(dynamic doctor) {
    if (doctor is! Map) {
      return 'Chưa có chuyên khoa';
    }

    final specialty = doctor['specialtyId'];

    if (specialty is Map) {
      return specialty['name']?.toString() ??
          'Chưa có chuyên khoa';
    }

    return 'Chưa có chuyên khoa';
  }

  // ============================================================
  // PRICE
  // ============================================================

  String formatPrice(dynamic price) {
    if (price == null) {
      return '0 VNĐ';
    }

    final number = double.tryParse(
      price.toString(),
    );

    if (number == null) {
      return '$price VNĐ';
    }

    return '${number.toStringAsFixed(0)} VNĐ';
  }

  // ============================================================
  // DETAIL
  // ============================================================

  Future<void> showDoctorDetail(
    dynamic doctor,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => DoctorDetailDialog(
        doctor: doctor,
      ),
    );
  }

  // ============================================================
  // ADD
  // ============================================================

  Future<void> showAddDoctorDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const AddDoctorDialog(),
    );

    if (result == true) {
      await loadDoctors();
    }
  }

  // ============================================================
  // EDIT
  // ============================================================

  Future<void> showEditDoctorDialog(
    dynamic doctor,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => EditDoctorDialog(
        doctor: doctor,
      ),
    );

    if (result == true) {
      await loadDoctors();
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> confirmDeleteDoctor(
    dynamic doctor,
  ) async {
    if (doctor is! Map) {
      showSnack(
        'Dữ liệu bác sĩ không hợp lệ',
        Colors.red,
      );
      return;
    }

    final doctorId = doctor['_id']?.toString();

    if (doctorId == null || doctorId.isEmpty) {
      showSnack(
        'Không tìm thấy ID bác sĩ',
        Colors.red,
      );
      return;
    }

    final fullName = getUserValue(
      doctor,
      'fullName',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text('Xác nhận xóa'),
            ],
          ),
          content: Text(
            'Bạn có chắc muốn xóa bác sĩ '
            '${fullName.isEmpty ? "này" : fullName}?\n\n'
            'Tài khoản DOCTOR vẫn được giữ lại.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              icon: const Icon(Icons.delete),
              label: const Text('Xóa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    try {
      await ApiService.deleteDoctor(
        doctorId,
      );

      if (!mounted) return;

      showSnack(
        'Xóa bác sĩ thành công',
        Colors.green,
      );

      await loadDoctors();
    } catch (e) {
      if (!mounted) return;

      showSnack(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        Colors.red,
      );
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void showSnack(
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Quản lý bác sĩ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: loading ? null : loadDoctors,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ====================================================
            // HEADER
            // ====================================================

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: Color(0xFF1565C0),
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quản lý bác sĩ',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Quản lý thông tin và hồ sơ bác sĩ',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: showAddDoctorDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm bác sĩ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
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

            // ====================================================
            // SEARCH
            // ====================================================

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Tìm theo tên, email, số điện thoại, chuyên khoa...',
                      prefixIcon:
                          const Icon(Icons.search),
                      suffixIcon:
                          searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    searchController
                                        .clear();
                                  },
                                  icon:
                                      const Icon(
                                    Icons.clear,
                                  ),
                                )
                              : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                OutlinedButton.icon(
                  onPressed: loadDoctors,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm mới'),
                  style:
                      OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ====================================================
            // COUNT
            // ====================================================

            Text(
              'Tổng số bác sĩ: ${filteredDoctors.length}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 12),

            // ====================================================
            // CONTENT
            // ====================================================

            Expanded(
              child: buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

    // ============================================================
  // CONTENT
  // ============================================================

  Widget buildContent() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: loadDoctors,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (filteredDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'Không tìm thấy bác sĩ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

   return Card(
  elevation: 1,
  clipBehavior: Clip.antiAlias,
  child: LayoutBuilder(
    builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        child: FittedBox(
          alignment: Alignment.topLeft,
          fit: BoxFit.scaleDown,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              Colors.blue.shade50,
            ),

            dataRowMinHeight: 65,
            dataRowMaxHeight: 72,

            // Giảm khoảng cách để toàn bộ bảng nằm trong màn hình
            columnSpacing: 8,
            horizontalMargin: 8,

            columns: const [
              DataColumn(
                label: SizedBox(
                  width: 40,
                  child: Text(
                    'STT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              DataColumn(
                label: SizedBox(
                  width: 180,
                  child: Text(
                    'Bác sĩ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              DataColumn(
                label: SizedBox(
                  width: 180,
                  child: Text(
                    'Email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              DataColumn(
                label: SizedBox(
                  width: 125,
                  child: Text(
                    'Số điện thoại',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              DataColumn(
                label: SizedBox(
                  width: 145,
                  child: Text(
                    'Chuyên khoa',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              DataColumn(
                label: SizedBox(
                  width: 90,
                  child: Text(
                    'Giá khám',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              DataColumn(
                label: SizedBox(
                  width: 100,
                  child: Text(
                    'Kinh nghiệm',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              DataColumn(
                label: SizedBox(
                  width: 140,
                  child: Center(
                    child: Text(
                      'Thao tác',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            rows: List.generate(
              filteredDoctors.length,
              (index) {
                final doctor = filteredDoctors[index];

                final name = getUserValue(
                  doctor,
                  'fullName',
                );

                final email = getUserValue(
                  doctor,
                  'email',
                );

                final phone = getUserValue(
                  doctor,
                  'phoneNumber',
                );

                final specialty = getSpecialtyName(
                  doctor,
                );

                final price = doctor is Map
                    ? doctor['price']
                    : null;

                final experience = doctor is Map
                    ? doctor['experienceYears']
                    : null;

                return DataRow(
                  cells: [
                    // STT
                    DataCell(
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${index + 1}',
                        ),
                      ),
                    ),

                    // BÁC SĨ
                    DataCell(
                      SizedBox(
                        width: 180,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  Colors.blue.shade50,
                              child: const Icon(
                                Icons.person,
                                color:
                                    Color(0xFF1565C0),
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                name.isEmpty
                                    ? 'Chưa có tên'
                                    : name,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // EMAIL
                    DataCell(
                      SizedBox(
                        width: 180,
                        child: Text(
                          email.isEmpty
                              ? '---'
                              : email,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // PHONE
                    DataCell(
                      SizedBox(
                        width: 125,
                        child: Text(
                          phone.isEmpty
                              ? '---'
                              : phone,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // SPECIALTY
                    DataCell(
                      SizedBox(
                        width: 145,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.blue.shade50,
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            specialty,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color:
                                  Color(0xFF1565C0),
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // PRICE
                    DataCell(
                      SizedBox(
                        width: 90,
                        child: Text(
                          formatPrice(price),
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // EXPERIENCE
                    DataCell(
                      SizedBox(
                        width: 100,
                        child: Text(
                          '${experience ?? 0} năm',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // ==================================================
                    // THAO TÁC
                    // ==================================================
                    DataCell(
                      SizedBox(
                        width: 140,
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            // XEM
                            IconButton(
                              tooltip:
                                  'Xem chi tiết',
                              padding:
                                  EdgeInsets.zero,
                              constraints:
                                  const BoxConstraints(
                                minWidth: 38,
                                minHeight: 38,
                              ),
                              onPressed: () {
                                showDoctorDetail(
                                  doctor,
                                );
                              },
                              icon: const Icon(
                                Icons
                                    .visibility_outlined,
                                color: Colors.blue,
                                size: 22,
                              ),
                            ),

                            // SỬA
                            IconButton(
                              tooltip:
                                  'Sửa bác sĩ',
                              padding:
                                  EdgeInsets.zero,
                              constraints:
                                  const BoxConstraints(
                                minWidth: 38,
                                minHeight: 38,
                              ),
                              onPressed: () {
                                showEditDoctorDialog(
                                  doctor,
                                );
                              },
                              icon: const Icon(
                                Icons.edit_outlined,
                                color:
                                    Colors.orange,
                                size: 22,
                              ),
                            ),

                            // XÓA
                            IconButton(
                              tooltip:
                                  'Xóa bác sĩ',
                              padding:
                                  EdgeInsets.zero,
                              constraints:
                                  const BoxConstraints(
                                minWidth: 38,
                                minHeight: 38,
                              ),
                              onPressed: () {
                                confirmDeleteDoctor(
                                  doctor,
                                );
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  ),
);
  }
}

// ==================================================================
// DOCTOR DETAIL
// ==================================================================

class DoctorDetailDialog extends StatelessWidget {
  final dynamic doctor;

  const DoctorDetailDialog({
    super.key,
    required this.doctor,
  });

  String getUserValue(
    String field,
  ) {
    if (doctor is! Map) {
      return '';
    }

    final user = doctor['userId'];

    if (user is Map) {
      return user[field]?.toString() ?? '';
    }

    return '';
  }

  String getSpecialtyName() {
    if (doctor is! Map) {
      return 'Chưa có chuyên khoa';
    }

    final specialty =
        doctor['specialtyId'];

    if (specialty is Map) {
      return specialty['name']?.toString() ??
          'Chưa có chuyên khoa';
    }

    return 'Chưa có chuyên khoa';
  }

  String formatPrice(dynamic price) {
    if (price == null) {
      return '0 VNĐ';
    }

    final number =
        double.tryParse(price.toString());

    if (number == null) {
      return '$price VNĐ';
    }

    return '${number.toStringAsFixed(0)} VNĐ';
  }

  String formatDate(dynamic value) {
    if (value == null) {
      return '---';
    }

    try {
      final date =
          DateTime.parse(value.toString());

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value.toString();
    }
  }

  Widget buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF1565C0),
            size: 22,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value.isEmpty
                      ? '---'
                      : value,
                  style:
                      const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorId =
        doctor is Map
            ? doctor['_id']?.toString() ??
                ''
            : '';

    final userId =
        doctor is Map &&
                doctor['userId'] is Map
            ? doctor['userId']['_id']
                    ?.toString() ??
                ''
            : '';

    final fullName =
        getUserValue('fullName');

    final email =
        getUserValue('email');

    final phone =
        getUserValue('phoneNumber');

    final specialty =
        getSpecialtyName();

    final price =
        doctor is Map
            ? doctor['price']
            : null;

    final experience =
        doctor is Map
            ? doctor['experienceYears']
            : null;

    final bio =
        doctor is Map
            ? doctor['bio']?.toString() ??
                ''
            : '';

    final createdAt =
        doctor is Map
            ? doctor['createdAt']
            : null;

    final updatedAt =
        doctor is Map
            ? doctor['updatedAt']
            : null;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),

      titlePadding:
          const EdgeInsets.fromLTRB(
        24,
        22,
        24,
        10,
      ),

      contentPadding:
          const EdgeInsets.fromLTRB(
        24,
        10,
        24,
        8,
      ),

      title: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor:
                Colors.blue.shade50,
            child: const Icon(
              Icons.medical_services,
              color:
                  Color(0xFF1565C0),
              size: 28,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'Chi tiết bác sĩ',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      content: SizedBox(
        width: 550,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // PROFILE HEADER
              // ==================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(18),
                margin:
                    const EdgeInsets.only(
                  bottom: 18,
                ),
                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    colors: [
                      Colors.blue.shade50,
                      Colors.white,
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor:
                          Colors.white,
                      child:
                          const Icon(
                        Icons.person,
                        size: 38,
                        color:
                            Color(
                          0xFF1565C0,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 14,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            fullName.isEmpty
                                ? 'Chưa có tên'
                                : fullName,
                            style:
                                const TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Colors
                                  .blue
                                  .shade100,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                            ),
                            child: Text(
                              specialty,
                              style:
                                  const TextStyle(
                                color:
                                    Color(
                                  0xFF1565C0,
                                ),
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // ACCOUNT
              // ==================================================

              const Text(
                'Thông tin tài khoản',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              buildInfoItem(
                icon:
                    Icons.email_outlined,
                label: 'Email',
                value: email,
              ),

              buildInfoItem(
                icon:
                    Icons.phone_outlined,
                label: 'Số điện thoại',
                value: phone,
              ),

              buildInfoItem(
                icon:
                    Icons.badge_outlined,
                label: 'ID tài khoản',
                value: userId,
              ),

              // ==================================================
              // DOCTOR
              // ==================================================

              const SizedBox(height: 8),

              const Text(
                'Thông tin chuyên môn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              buildInfoItem(
                icon:
                    Icons.medical_services_outlined,
                label: 'Chuyên khoa',
                value: specialty,
              ),

              buildInfoItem(
                icon:
                    Icons.payments_outlined,
                label: 'Giá khám',
                value:
                    formatPrice(price),
              ),

              buildInfoItem(
                icon:
                    Icons.work_history_outlined,
                label:
                    'Kinh nghiệm',
                value:
                    '${experience ?? 0} năm',
              ),

              // ==================================================
              // BIO
              // ==================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(14),
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.grey.shade50,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                  border: Border.all(
                    color:
                        Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons
                              .description_outlined,
                          color:
                              Color(
                            0xFF1565C0,
                          ),
                          size: 22,
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        const Text(
                          'Giới thiệu bác sĩ',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Colors.grey,
                            fontWeight:
                                FontWeight
                                    .w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      bio.isEmpty
                          ? 'Chưa có thông tin giới thiệu'
                          : bio,
                      style:
                          const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // SYSTEM INFO
              // ==================================================

              const SizedBox(height: 8),

              const Text(
                'Thông tin hệ thống',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              buildInfoItem(
                icon:
                    Icons.fingerprint,
                label: 'ID hồ sơ bác sĩ',
                value: doctorId,
              ),

              buildInfoItem(
                icon:
                    Icons.calendar_today_outlined,
                label: 'Ngày tạo',
                value:
                    formatDate(createdAt),
              ),

              buildInfoItem(
                icon:
                    Icons.update_outlined,
                label:
                    'Cập nhật lần cuối',
                value:
                    formatDate(updatedAt),
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close,
          ),
          label: const Text('Đóng'),
        ),
      ],
    );
  }
}

// ==================================================================
// ADD DOCTOR
// ==================================================================

class AddDoctorDialog extends StatefulWidget {
  const AddDoctorDialog({super.key});

  @override
  State<AddDoctorDialog> createState() =>
      _AddDoctorDialogState();
}

class _AddDoctorDialogState
    extends State<AddDoctorDialog> {
  List<UserModel> doctorUsers = [];
  List<Specialty> specialties = [];

  String? selectedUserId;
  String? selectedSpecialtyId;

  final priceController =
      TextEditingController();

  final experienceController =
      TextEditingController();

  final bioController =
      TextEditingController();

  bool loadingData = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadFormData();
  }

  Future<void> loadFormData() async {
    try {
      final users =
          await ApiService.getUsers();

      final specialtyData =
          await ApiService.getSpecialties();

      final doctors =
          users.where((user) {
        return user.role.toUpperCase() ==
            'DOCTOR';
      }).toList();

      if (!mounted) return;

      setState(() {
        doctorUsers = doctors;
        specialties = specialtyData;
        loadingData = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingData = false;
      });

      showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  Future<void> createDoctor() async {
    if (selectedUserId == null) {
      showMessage(
        'Vui lòng chọn tài khoản bác sĩ',
      );
      return;
    }

    if (selectedSpecialtyId == null) {
      showMessage(
        'Vui lòng chọn chuyên khoa',
      );
      return;
    }

    final price = double.tryParse(
      priceController.text.trim(),
    );

    final experienceYears =
        int.tryParse(
      experienceController.text.trim(),
    );

    if (price == null || price < 0) {
      showMessage(
        'Giá khám không hợp lệ',
      );
      return;
    }

    if (experienceYears == null ||
        experienceYears < 0) {
      showMessage(
        'Số năm kinh nghiệm không hợp lệ',
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await ApiService.createDoctor(
        userId: selectedUserId!,
        specialtyId:
            selectedSpecialtyId!,
        price: price,
        bio: bioController.text.trim(),
        experienceYears:
            experienceYears,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    priceController.dispose();
    experienceController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      title: const Row(
        children: [
          Icon(
            Icons.person_add,
            color:
                Color(0xFF1565C0),
          ),
          SizedBox(width: 10),
          Text('Thêm bác sĩ'),
        ],
      ),

      content: SizedBox(
        width: 500,
        child: loadingData
            ? const SizedBox(
                height: 150,
                child: Center(
                  child:
                      CircularProgressIndicator(),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    buildDropdown(
                      label:
                          'Tài khoản bác sĩ',
                      icon:
                          Icons.person,
                      value:
                          selectedUserId,
                      items: doctorUsers
                          .map(
                            (user) =>
                                DropdownMenuItem<
                                    String>(
                              value: user.id,
                              child: Text(
                                '${user.fullName} - ${user.email}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (saving) return;

                        setState(() {
                          selectedUserId =
                              value;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    buildDropdown(
                      label:
                          'Chuyên khoa',
                      icon:
                          Icons
                              .medical_services,
                      value:
                          selectedSpecialtyId,
                      items: specialties
                          .map(
                            (specialty) =>
                                DropdownMenuItem<
                                    String>(
                              value:
                                  specialty.id,
                              child: Text(
                                specialty.name,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (saving) return;

                        setState(() {
                          selectedSpecialtyId =
                              value;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    TextField(
                      controller:
                          priceController,
                      enabled: !saving,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Giá khám',
                        border:
                            OutlineInputBorder(),
                        prefixIcon:
                            Icon(
                          Icons
                              .payments_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    TextField(
                      controller:
                          experienceController,
                      enabled: !saving,
                      keyboardType:
                          TextInputType
                              .number,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Kinh nghiệm (năm)',
                        border:
                            OutlineInputBorder(),
                        prefixIcon:
                            Icon(
                          Icons
                              .work_history,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    TextField(
                      controller:
                          bioController,
                      enabled: !saving,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Giới thiệu',
                        border:
                            OutlineInputBorder(),
                        prefixIcon:
                            Icon(
                          Icons
                              .description_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),

      actions: [
        TextButton(
          onPressed: saving
              ? null
              : () =>
                  Navigator.pop(context),
          child:
              const Text('Hủy'),
        ),

        ElevatedButton.icon(
          onPressed:
              saving ? null : createDoctor,
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(
            saving
                ? 'Đang lưu...'
                : 'Thêm bác sĩ',
          ),
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF1565C0),
            foregroundColor:
                Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<
            DropdownMenuItem<String>>
        items,
    required ValueChanged<String?>
        onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration:
          InputDecoration(
        labelText: label,
        border:
            const OutlineInputBorder(),
        prefixIcon:
            Icon(icon),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

// ==================================================================
// EDIT DOCTOR
// ==================================================================

class EditDoctorDialog extends StatefulWidget {
  final dynamic doctor;

  const EditDoctorDialog({
    super.key,
    required this.doctor,
  });

  @override
  State<EditDoctorDialog> createState() =>
      _EditDoctorDialogState();
}

class _EditDoctorDialogState
    extends State<EditDoctorDialog> {
  List<Specialty> specialties = [];

  String? selectedSpecialtyId;

  final priceController =
      TextEditingController();

  final experienceController =
      TextEditingController();

  final bioController =
      TextEditingController();

  bool loadingData = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> loadData() async {
    try {
      final specialtyData =
          await ApiService.getSpecialties();

      final specialty =
          widget.doctor['specialtyId'];

      String? specialtyId;

      if (specialty is Map) {
        specialtyId =
            specialty['_id']?.toString() ??
                specialty['id']?.toString();
      } else if (specialty != null) {
        specialtyId =
            specialty.toString();
      }

      if (!mounted) return;

      setState(() {
        specialties = specialtyData;

        selectedSpecialtyId =
            specialtyId;

        priceController.text =
            widget.doctor['price']
                    ?.toString() ??
                '';

        experienceController.text =
            widget.doctor[
                        'experienceYears']
                    ?.toString() ??
                '0';

        bioController.text =
            widget.doctor['bio']
                    ?.toString() ??
                '';

        loadingData = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingData = false;
      });

      showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<void> updateDoctor() async {
    if (selectedSpecialtyId == null) {
      showMessage(
        'Vui lòng chọn chuyên khoa',
      );
      return;
    }

    final price = double.tryParse(
      priceController.text.trim(),
    );

    final experienceYears =
        int.tryParse(
      experienceController.text.trim(),
    );

    if (price == null || price < 0) {
      showMessage(
        'Giá khám không hợp lệ',
      );
      return;
    }

    if (experienceYears == null ||
        experienceYears < 0) {
      showMessage(
        'Số năm kinh nghiệm không hợp lệ',
      );
      return;
    }

    final doctorId =
        widget.doctor['_id']?.toString();

    if (doctorId == null ||
        doctorId.isEmpty) {
      showMessage(
        'Không tìm thấy ID bác sĩ',
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final success =
          await ApiService.updateDoctor(
        id: doctorId,
        specialtyId:
            selectedSpecialtyId!,
        price: price,
        bio: bioController.text.trim(),
        experienceYears:
            experienceYears,
      );

      if (!success) {
        throw Exception(
          'Backend không cập nhật bác sĩ',
        );
      }

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    priceController.dispose();
    experienceController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user =
        widget.doctor['userId'];

    String fullName = '';
    String email = '';
    String phone = '';

    if (user is Map) {
      fullName =
          user['fullName']?.toString() ??
              '';

      email =
          user['email']?.toString() ??
              '';

      phone =
          user['phoneNumber']
                  ?.toString() ??
              '';
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      title: const Row(
        children: [
          Icon(
            Icons.edit,
            color:
                Color(0xFF1565C0),
          ),
          SizedBox(width: 10),
          Text('Sửa bác sĩ'),
        ],
      ),

      content: SizedBox(
        width: 500,
        child: loadingData
            ? const SizedBox(
                height: 180,
                child: Center(
                  child:
                      CircularProgressIndicator(),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    // USER INFO

                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets
                              .all(16),
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .blue.shade50,
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor:
                                Colors.white,
                            child:
                                const Icon(
                              Icons.person,
                              color:
                                  Color(
                                0xFF1565C0,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  fullName
                                          .isEmpty
                                      ? 'Chưa có tên'
                                      : fullName,
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontSize:
                                        16,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  email.isEmpty
                                      ? '---'
                                      : email,
                                ),

                                Text(
                                  phone.isEmpty
                                      ? '---'
                                      : phone,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    DropdownButtonFormField<
                        String>(
                      initialValue:
                          specialties.any(
                        (specialty) =>
                            specialty.id ==
                            selectedSpecialtyId,
                      )
                          ? selectedSpecialtyId
                          : null,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Chuyên khoa',
                        border:
                            OutlineInputBorder(),
                        prefixIcon:
                            Icon(
                          Icons
                              .medical_services,
                        ),
                      ),
                      items: specialties
                          .map(
                            (specialty) =>
                                DropdownMenuItem<
                                    String>(
                              value:
                                  specialty.id,
                              child: Text(
                                specialty.name,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (saving) return;

                        setState(() {
                          selectedSpecialtyId =
                              value;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    TextField(
                      controller:
                          priceController,
                      enabled: !saving,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Giá khám',
                        hintText:
                            'Ví dụ: 200000',
                        border:
                            OutlineInputBorder(),
                        prefixIcon:
                            Icon(
                          Icons
                              .payments_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    TextField(
                      controller:
                          experienceController,
                      enabled: !saving,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Kinh nghiệm (năm)',
                        hintText:
                            'Ví dụ: 5',
                        border:
                            OutlineInputBorder(),
                        prefixIcon:
                            Icon(
                          Icons
                              .work_history,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    TextField(
                      controller:
                          bioController,
                      enabled: !saving,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Giới thiệu bác sĩ',
                        hintText:
                            'Nhập thông tin giới thiệu...',
                        border:
                            OutlineInputBorder(),
                        prefixIcon:
                            Icon(
                          Icons
                              .description_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),

      actions: [
        TextButton(
          onPressed: saving
              ? null
              : () =>
                  Navigator.pop(context),
          child:
              const Text('Hủy'),
        ),

        ElevatedButton.icon(
          onPressed:
              saving ? null : updateDoctor,
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(
            saving
                ? 'Đang lưu...'
                : 'Lưu thay đổi',
          ),
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF1565C0),
            foregroundColor:
                Colors.white,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}