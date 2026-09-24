import 'package:app/booking_app/screens/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showMedicalRecordsHistoryDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    final token = auth.token;

    if (user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.medical_information_outlined, color: Color(0xff0284C7)),
                  const SizedBox(width: 8),
                  const Text(
                    'Sổ khám bệnh / Lịch sử bệnh án',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: FutureBuilder(
                  future: ApiService.get(
                    '/medical-records/patient/${user.id}',
                    token: token,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return const Center(child: Text('Chưa có lịch sử bệnh án.'));
                    }

                    final data = snapshot.data;
                    List records = data is List
                        ? data
                        : (data is Map && data['data'] is List ? data['data'] : []);

                    if (records.isEmpty) {
                      return const Center(
                        child: Text('Bạn chưa có hồ sơ bệnh án nào.'),
                      );
                    }

                    return ListView.separated(
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final item = records[i];

                        // Lấy tên Bác sĩ
                        String doctorName = 'Bác sĩ';
                        if (item['doctorId'] is Map) {
                          final docUser = item['doctorId']['userId'];
                          if (docUser is Map) {
                            doctorName = docUser['fullName'] ?? 'Bác sĩ';
                          }
                        }

                        // Lấy ngày khám
                        String dateStr = '';
                        if (item['createdAt'] != null) {
                          final dt = DateTime.tryParse(item['createdAt'].toString());
                          if (dt != null) {
                            dateStr = '${dt.day}/${dt.month}/${dt.year}';
                          }
                        }

                        // Chẩn đoán & Ghi chú
                        final diagnosis = item['diagnosis'] ?? 'Chưa cập nhật';
                        final notes = item['notes'] ?? '';

                        // Đơn thuốc (duyệt mảng prescriptions)
                        String prescriptionText = '';
                        if (item['prescriptions'] is List && (item['prescriptions'] as List).isNotEmpty) {
                          List pList = item['prescriptions'];
                          List<String> drugItems = [];
                          for (var p in pList) {
                            if (p is Map) {
                              final name = p['drugName'] ?? p['name'] ?? '';
                              final quantity = p['quantity'] != null ? ' (SL: ${p['quantity']})' : '';
                              final dosage = p['dosage'] != null && p['dosage'].toString().isNotEmpty
                                  ? '\n  Liều dùng: ${p['dosage']}'
                                  : '';
                              drugItems.add('• $name$quantity$dosage');
                            } else if (p is String) {
                              drugItems.add('• $p');
                            }
                          }
                          prescriptionText = drugItems.join('\n');
                        } else if (item['prescription'] != null && item['prescription'].toString().isNotEmpty) {
                          prescriptionText = item['prescription'].toString();
                        }

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xffF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xffE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    doctorName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xff0284C7),
                                    ),
                                  ),
                                  if (dateStr.isNotEmpty)
                                    Text(
                                      dateStr,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                ],
                              ),
                              const Divider(height: 16),
                              Text(
                                'Chẩn đoán: $diagnosis',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              if (prescriptionText.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Đơn thuốc:',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff0369A1)),
                                ),
                                const SizedBox(height: 2),
                                Text(prescriptionText, style: const TextStyle(fontSize: 13)),
                              ],
                              if (notes.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Ghi chú bác sĩ: $notes',
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ],
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

  @override
  Widget build(BuildContext context) {
    final a = context.watch<AuthProvider>();
    final u = a.currentUser;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        const Text(
          'Hồ sơ',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff0284C7), Color(0xff38BDF8)],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u?.fullName ?? 'Người dùng',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      u?.email ?? '',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _row(Icons.person_outline, 'Họ và tên', u?.fullName ?? ''),
        _row(Icons.mail_outline, 'Email', u?.email ?? ''),
        _row(
          Icons.phone_outlined,
          'Số điện thoại',
          u?.phoneNumber.isEmpty == true ? 'Chưa cập nhật' : u!.phoneNumber,
        ),
        const SizedBox(height: 18),

        // ==================== LỊCH SỬ BỆNH ÁN ====================
        ElevatedButton.icon(
          onPressed: () => _showMedicalRecordsHistoryDialog(context),
          icon: const Icon(Icons.medical_information_outlined),
          label: const Text(
            'Lịch sử bệnh án / Sổ khám bệnh',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0284C7),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ==================== CHỈNH SỬA HỒ SƠ ====================
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            );
          },
          icon: const Icon(Icons.edit_outlined),
          label: const Text(
            'Chỉnh sửa hồ sơ',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xff0284C7),
            padding: const EdgeInsets.all(16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xffE0F2FE), width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () {
            a.logout();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const BookingLoginPage()),
              (_) => false,
            );
          },
          icon: const Icon(Icons.logout_rounded, color: Color(0xffDC2626)),
          label: const Text(
            'Đăng xuất',
            style: TextStyle(
              color: Color(0xffDC2626),
              fontWeight: FontWeight.w700,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            side: const BorderSide(color: Color(0xffFECACA)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(IconData i, String t, String v) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(i, color: const Color(0xff0284C7)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t,
                    style: const TextStyle(color: Color(0xff64748B), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      );
}