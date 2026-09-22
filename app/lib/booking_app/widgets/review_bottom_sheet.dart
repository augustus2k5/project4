import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/review_model.dart';

class ReviewBottomSheet extends StatefulWidget {
  final String appointmentId;
  final String doctorName;
  final ReviewItem? existingReview;
  final VoidCallback? onReviewSubmitted;

  const ReviewBottomSheet({
    super.key,
    required this.appointmentId,
    required this.doctorName,
    this.existingReview,
    this.onReviewSubmitted,
  });

  static Future<void> show(
    BuildContext context, {
    required String appointmentId,
    required String doctorName,
    ReviewItem? existingReview,
    VoidCallback? onSubmitted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ReviewBottomSheet(
        appointmentId: appointmentId,
        doctorName: doctorName,
        existingReview: existingReview,
        onReviewSubmitted: onSubmitted,
      ),
    );
  }

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  int _rating = 5;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _isAnonymous = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating.round();
      _commentCtrl.text = widget.existingReview!.comment;
      _isAnonymous = widget.existingReview!.isAnonymous;
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() => _submitting = true);
    try {
      if (widget.existingReview != null) {
        // Cập nhật review
        await ApiService.patch('/reviews/${widget.existingReview!.id}', {
          'rating': _rating,
          'comment': _commentCtrl.text.trim(),
          'isAnonymous': _isAnonymous,
        }, token: token);
      } else {
        // Tạo review mới
        await ApiService.post('/reviews', {
          'appointmentId': widget.appointmentId,
          'rating': _rating,
          'comment': _commentCtrl.text.trim(),
          'isAnonymous': _isAnonymous,
        }, token: token);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingReview != null
                  ? 'Đã cập nhật đánh giá!'
                  : 'Cảm ơn bạn đã gửi đánh giá!',
            ),
            backgroundColor: const Color(0xff16A34A),
          ),
        );
        widget.onReviewSubmitted?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: const Color(0xffDC2626),
          ),
        );
      }
    }
  }

  Future<void> _delete() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || widget.existingReview == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _submitting = true);
    try {
      final r = await ApiService.get(
        '/reviews/doctor/${widget.existingReview!.doctorId}',
      );
      // Xóa qua DELETE
      // Dùng custom http delete hoặc patch nếu API service có
      await ApiService.post(
        '/reviews/${widget.existingReview!.id}',
        {}, // Tùy cấu hình hoặc gọi http.delete
        token: token,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa đánh giá!')));
        widget.onReviewSubmitted?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingReview != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEdit ? 'Chỉnh sửa đánh giá' : 'Đánh giá buổi khám',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Bác sĩ: ${widget.doctorName}',
            style: const TextStyle(color: Color(0xff64748B), fontSize: 14),
          ),
          const SizedBox(height: 18),

          // Chọn số sao
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final star = index + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = star),
                icon: Icon(
                  star <= _rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: const Color(0xffffb703),
                  size: 38,
                ),
              );
            }),
          ),
          Center(
            child: Text(
              _rating == 5
                  ? 'Tuyệt vời ⭐⭐⭐⭐⭐'
                  : _rating == 4
                  ? 'Rất tốt ⭐⭐⭐⭐'
                  : _rating == 3
                  ? 'Bình thường ⭐⭐⭐'
                  : _rating == 2
                  ? 'Chưa hài lòng ⭐⭐'
                  : 'Rất tệ ⭐',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xff0284C7),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Nhập nhận xét
          TextField(
            controller: _commentCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Chia sẻ trải nghiệm của bạn về bác sĩ và phòng khám...',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xff94A3B8),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              filled: true,
              fillColor: const Color(0xffF8FAFC),
            ),
          ),
          const SizedBox(height: 12),

          // Toggle Ẩn danh
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xffF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.security, size: 20, color: Color(0xff64748B)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Đánh giá ẩn danh (Giấu tên & avatar)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                Switch(
                  value: _isAnonymous,
                  activeColor: const Color(0xff0284C7),
                  onChanged: (val) => setState(() => _isAnonymous = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Nút gửi
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isEdit ? 'Lưu thay đổi' : 'Gửi đánh giá',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
