import 'package:flutter/material.dart';

import '../../models/specialty_model.dart';
import '../../services/api_service.dart';

class AdminSpecialties extends StatefulWidget {
  const AdminSpecialties({super.key});

  @override
  State<AdminSpecialties> createState() => _AdminSpecialtiesState();
}

class _AdminSpecialtiesState extends State<AdminSpecialties> {
  List<Specialty> specialties = [];

  bool loading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSpecialties();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD DANH SÁCH CHUYÊN KHOA
  // ============================================================

  Future<void> loadSpecialties() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    try {
      final data = await ApiService.getSpecialties();

      if (!mounted) return;

      setState(() {
        specialties = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage(
        'Không thể tải danh sách chuyên khoa',
        Colors.red,
      );
    }
  }

  // ============================================================
  // HIỂN THỊ THÔNG BÁO
  // ============================================================

  void showMessage(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // ============================================================
  // THÊM / SỬA CHUYÊN KHOA
  // ============================================================

  void showSpecialtyDialog({
    Specialty? specialty,
  }) {
    final nameController = TextEditingController(
      text: specialty?.name ?? '',
    );

    final descriptionController = TextEditingController(
      text: specialty?.description ?? '',
    );

    String status = specialty?.status ?? 'ACTIVE';

    final bool isEdit = specialty != null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEdit ? 'Sửa chuyên khoa' : 'Thêm chuyên khoa',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TÊN
                      TextField(
                        controller: nameController,
                        enabled: !saving,
                        decoration: const InputDecoration(
                          labelText: 'Tên chuyên khoa',
                          hintText: 'Ví dụ: Tim mạch',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.local_hospital,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // MÔ TẢ
                      TextField(
                        controller: descriptionController,
                        enabled: !saving,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          hintText: 'Nhập mô tả chuyên khoa',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.description,
                          ),
                          alignLabelWithHint: true,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // TRẠNG THÁI
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.toggle_on,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'ACTIVE',
                            child: Text('Hoạt động'),
                          ),
                          DropdownMenuItem(
                            value: 'INACTIVE',
                            child: Text('Không hoạt động'),
                          ),
                        ],
                        onChanged: saving
                            ? null
                            : (value) {
                                if (value != null) {
                                  setDialogState(() {
                                    status = value;
                                  });
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // HỦY
                TextButton(
                  onPressed: saving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Hủy'),
                ),

                // THÊM / LƯU
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final description =
                              descriptionController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Vui lòng nhập tên chuyên khoa',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          try {
                            bool success;

                            if (isEdit) {
                              success =
                                  await ApiService.updateSpecialty(
                                id: specialty.id,
                                name: name,
                                description: description,
                                status: status,
                              );
                            } else {
                              success =
                                  await ApiService.createSpecialty(
                                name: name,
                                description: description,
                                status: status,
                              );
                            }

                            if (!mounted) return;

                            if (success) {
                              Navigator.pop(dialogContext);

                              showMessage(
                                isEdit
                                    ? 'Đã cập nhật chuyên khoa'
                                    : 'Đã thêm chuyên khoa',
                                Colors.green,
                              );

                              await loadSpecialties();
                            } else {
                              setDialogState(() {
                                saving = false;
                              });

                              showMessage(
                                isEdit
                                    ? 'Cập nhật chuyên khoa thất bại'
                                    : 'Thêm chuyên khoa thất bại',
                                Colors.red,
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;

                            setDialogState(() {
                              saving = false;
                            });

                            showMessage(
                              'Lỗi kết nối API: $e',
                              Colors.red,
                            );
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEdit ? 'Lưu' : 'Thêm',
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // XÓA CHUYÊN KHOA
  // ============================================================

  void confirmDelete(Specialty specialty) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        bool deleting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Xóa chuyên khoa',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Bạn có chắc muốn xóa "${specialty.name}" không?',
              ),
              actions: [
                TextButton(
                  onPressed: deleting
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: deleting
                      ? null
                      : () async {
                          setDialogState(() {
                            deleting = true;
                          });

                          try {
                            final success =
                                await ApiService.deleteSpecialty(
                              specialty.id,
                            );

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            if (success) {
                              showMessage(
                                'Đã xóa chuyên khoa',
                                Colors.green,
                              );

                              await loadSpecialties();
                            } else {
                              showMessage(
                                'Xóa chuyên khoa thất bại',
                                Colors.red,
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            showMessage(
                              'Lỗi kết nối API: $e',
                              Colors.red,
                            );
                          }
                        },
                  child: deleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Xóa',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // TÌM KIẾM
  // ============================================================

  List<Specialty> get filteredSpecialties {
    final keyword = searchController.text
        .toLowerCase()
        .trim();

    if (keyword.isEmpty) {
      return specialties;
    }

    return specialties.where((specialty) {
      return specialty.name
              .toLowerCase()
              .contains(keyword) ||
          specialty.description
              .toLowerCase()
              .contains(keyword);
    }).toList();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final data = filteredSpecialties;

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản lý chuyên khoa',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Thêm, sửa và xóa chuyên khoa',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                // NÚT THÊM
                ElevatedButton.icon(
                  onPressed: () {
                    showSpecialtyDialog();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Thêm chuyên khoa',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ==================================================
            // THANH TÌM KIẾM
            // ==================================================

            TextField(
              controller: searchController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm chuyên khoa...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
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

            const SizedBox(height: 20),

            // ==================================================
            // DANH SÁCH
            // ==================================================

            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : data.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.local_hospital_outlined,
                                size: 60,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                searchController.text
                                        .trim()
                                        .isEmpty
                                    ? 'Chưa có chuyên khoa'
                                    : 'Không tìm thấy chuyên khoa',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection:
                                Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                columnSpacing: 35,
                                headingRowHeight: 55,
                                dataRowMinHeight: 60,
                                dataRowMaxHeight: 80,
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'STT',
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Tên chuyên khoa',
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Mô tả',
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Trạng thái',
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Thao tác',
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: List.generate(
                                  data.length,
                                  (index) {
                                    final specialty =
                                        data[index];

                                    final bool isActive =
                                        specialty.status ==
                                            'ACTIVE';

                                    return DataRow(
                                      cells: [
                                        // STT
                                        DataCell(
                                          Text(
                                            '${index + 1}',
                                          ),
                                        ),

                                        // TÊN
                                        DataCell(
                                          SizedBox(
                                            width: 180,
                                            child: Text(
                                              specialty.name,
                                              style:
                                                  const TextStyle(
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // MÔ TẢ
                                        DataCell(
                                          SizedBox(
                                            width: 320,
                                            child: Text(
                                              specialty
                                                      .description
                                                      .isEmpty
                                                  ? 'Không có mô tả'
                                                  : specialty
                                                      .description,
                                              maxLines: 2,
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                            ),
                                          ),
                                        ),

                                        // TRẠNG THÁI
                                        DataCell(
                                          Container(
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration:
                                                BoxDecoration(
                                              color: isActive
                                                  ? Colors.green
                                                      .withOpacity(
                                                      0.1,
                                                    )
                                                  : Colors.red
                                                      .withOpacity(
                                                      0.1,
                                                    ),
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                20,
                                              ),
                                            ),
                                            child: Text(
                                              isActive
                                                  ? 'Hoạt động'
                                                  : 'Không hoạt động',
                                              style: TextStyle(
                                                color: isActive
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // THAO TÁC
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                tooltip: 'Sửa',
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color:
                                                      Colors.blue,
                                                ),
                                                onPressed: () {
                                                  showSpecialtyDialog(
                                                    specialty:
                                                        specialty,
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                tooltip: 'Xóa',
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color:
                                                      Colors.red,
                                                ),
                                                onPressed: () {
                                                  confirmDelete(
                                                    specialty,
                                                  );
                                                },
                                              ),
                                            ],
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
          ],
        ),
      ),
    );
  }
}