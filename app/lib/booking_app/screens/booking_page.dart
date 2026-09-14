import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import '../models/doctor.dart';
import '../services/api_service.dart';

class BookingPage extends StatefulWidget {
  final Doctor doctor;

  const BookingPage({
    super.key,
    required this.doctor,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime date = DateTime.now();
  String slot = '08:00 - 09:00';
  final reason = TextEditingController();
  bool loading = false;

  final List<String> slots = const [
    '08:00 - 09:00',
    '09:00 - 10:00',
    '10:00 - 11:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
  ];

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  String dateValue() {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> submit() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    final token = auth.token;

    if (user == null || token == null) {
      _message('Phiên đăng nhập không hợp lệ.');
      return;
    }

    setState(() => loading = true);

    try {
      await ApiService.post(
        '/appointments',
        {
          'patientId': user.id,
          'doctorId': widget.doctor.id,
          'date': dateValue(),
          'timeSlot': slot,
          'reason': reason.text.trim(),
        },
        token: token,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (_) =>
            AlertDialog(
              title: const Text('Đặt lịch thành công'),
              content: Text(
                'Bạn đã đặt lịch với ${widget.doctor.name} '
                    'vào ngày ${dateValue()}, $slot.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đồng ý'),
                ),
              ],
            ),
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        _message(
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5FAFD),
      appBar: AppBar(
        title: const Text(
          'Đặt lịch khám',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xffE0F2FE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xff0284C7),
                    size: 34,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.doctor.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.doctor.specialty,
                        style: const TextStyle(
                          color: Color(0xff0284C7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            'Ngày khám',
            InkWell(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(
                    const Duration(days: 60),
                  ),
                  initialDate: date,
                );
                if (selectedDate != null) {
                  setState(() => date = selectedDate);
                }
              },
              child: _tile(
                Icons.event_rounded,
                '${date.day.toString().padLeft(2, '0')}/'
                    '${date.month.toString().padLeft(2, '0')}/'
                    '${date.year}',
              ),
            ),
          ),
          const SizedBox(height: 14),
          _section(
            'Khung giờ',
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: slots
                  .map(
                    (s) =>
                    ChoiceChip(
                      label: Text(s),
                      selected: slot == s,
                      onSelected: (_) => setState(() => slot = s),
                    ),
              )
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          _section(
            'Lý do khám',
            TextField(
              controller: reason,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ví dụ: đau đầu, khám định kỳ...',
                filled: true,
                fillColor: const Color(0xffF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: loading ? null : submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: loading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'Xác nhận đặt lịch',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 9),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _tile(IconData icon, String text) {
    return Row(
      children: [
        const SizedBox(width: 2),
        Icon(
          icon,
          color: Color(0xff0284C7),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
