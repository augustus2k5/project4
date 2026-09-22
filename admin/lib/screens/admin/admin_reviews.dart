import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../../services/api_service.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  List<AdminReviewModel> _reviews = [];
  bool _loading = true;
  int? _selectedRating;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _loading = true);
    try {
      final raw = await ApiService.getAdminReviews(rating: _selectedRating);
      if (mounted) {
        setState(() {
          _reviews = raw
              .map(
                (e) => AdminReviewModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteReview(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa đánh giá'),
        content: const Text(
          'Hành động này sẽ xóa vĩnh viễn đánh giá và tính lại điểm bác sĩ. Bạn có chắc không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Xóa vĩnh viễn',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.adminDeleteReview(id);
        _loadReviews();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa đánh giá thành công!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$e')));
        }
      }
    }
  }

  void _showReplyDialog(AdminReviewModel review) {
    final ctrl = TextEditingController(text: review.adminReply ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Phản hồi cho ${review.patientName}'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Nhập nội dung phản hồi từ phòng khám...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await ApiService.adminReplyReview(review.id, ctrl.text.trim());
              _loadReviews();
            },
            child: const Text('Gửi phản hồi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _reviews.where((r) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return r.doctorName.toLowerCase().contains(q) ||
          r.patientName.toLowerCase().contains(q) ||
          r.comment.toLowerCase().contains(q);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xffF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề & Toolbar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quản lý Đánh giá & Phản hồi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0F172A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _loadReviews,
                icon: const Icon(Icons.refresh),
                label: const Text('Làm mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1565C0),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bộ lọc & Tìm kiếm
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText:
                          'Tìm theo bác sĩ, người đánh giá hoặc nội dung...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<int?>(
                  value: _selectedRating,
                  hint: const Text('Tất cả mức sao'),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Tất cả mức sao'),
                    ),
                    DropdownMenuItem(value: 5, child: Text('5 Sao ⭐⭐⭐⭐⭐')),
                    DropdownMenuItem(value: 4, child: Text('4 Sao ⭐⭐⭐⭐')),
                    DropdownMenuItem(value: 3, child: Text('3 Sao ⭐⭐⭐')),
                    DropdownMenuItem(value: 2, child: Text('2 Sao ⭐⭐')),
                    DropdownMenuItem(value: 1, child: Text('1 Sao ⭐')),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedRating = val);
                    _loadReviews();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Danh sách bảng đánh giá
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? const Center(child: Text('Không có đánh giá nào phù hợp.'))
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xffE2E8F0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Bác sĩ: ${item.doctorName}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xff1565C0),
                                          ),
                                        ),
                                        Text(
                                          'Người đánh giá: ${item.patientName} ${item.isAnonymous ? "(Ẩn danh)" : ""}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xff64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (s) {
                                      return Icon(
                                        s < item.rating.round()
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.reply,
                                      color: Color(0xff0284C7),
                                    ),
                                    tooltip: 'Phản hồi',
                                    onPressed: () => _showReplyDialog(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Xóa vĩnh viễn',
                                    onPressed: () => _deleteReview(item.id),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.comment.isEmpty
                                    ? '(Không có lời bình luận)'
                                    : item.comment,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff334155),
                                ),
                              ),
                              if (item.adminReply != null &&
                                  item.adminReply!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffF0FDF4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.reply,
                                        size: 16,
                                        color: Color(0xff16A34A),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Admin phản hồi: ${item.adminReply!}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xff16A34A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
