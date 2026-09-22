import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../models/review_model.dart';
import '../services/api_service.dart';
import 'booking_page.dart';

class DoctorDetailPage extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailPage({super.key, required this.doctor});

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  DoctorReviewsSummary? _reviewsSummary;
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorReviews();
  }

  Future<void> _loadDoctorReviews() async {
    try {
      final data = await ApiService.get('/reviews/doctor/${widget.doctor.id}');
      if (mounted && data is Map) {
        setState(() {
          _reviewsSummary = DoctorReviewsSummary.fromJson(
            Map<String, dynamic>.from(data),
          );
          _loadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    final rating = _reviewsSummary?.averageRating ?? doctor.rating;
    final totalReviews = _reviewsSummary?.totalReviews ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xffF5FAFD),
      appBar: AppBar(
        title: const Text('Thông tin bác sĩ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          // Card thông tin bác sĩ
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff0284C7), Color(0xff38BDF8)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 58,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  doctor.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  doctor.specialty,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xffffd166)),
                    Text(
                      ' ${rating.toStringAsFixed(1)} ($totalReviews đánh giá)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '${doctor.experienceYears} năm kinh nghiệm',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          _info(
            'Giới thiệu',
            doctor.bio.isEmpty
                ? 'Bác sĩ chưa cập nhật phần giới thiệu.'
                : doctor.bio,
          ),
          _info(
            'Liên hệ',
            doctor.phone.isEmpty ? 'Chưa cập nhật số điện thoại' : doctor.phone,
          ),
          _info(
            'Email',
            doctor.email.isEmpty ? 'Chưa cập nhật email' : doctor.email,
          ),
          if (doctor.price > 0)
            _info('Chi phí khám', '${doctor.price.toStringAsFixed(0)} đ'),

          const SizedBox(height: 14),

          // ============================================================
          // KHỐI ĐÁNH GIÁ & PHẢN HỒI (REVIEWS SECTION) Ở DƯỚI CÙNG
          // ============================================================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Đánh giá & Nhận xét',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '$totalReviews lượt',
                      style: const TextStyle(
                        color: Color(0xff64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_loadingReviews)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_reviewsSummary == null ||
                    _reviewsSummary!.reviews.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    alignment: Alignment.center,
                    child: Column(
                      children: const [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 42,
                          color: Color(0xff94A3B8),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Bác sĩ chưa có đánh giá nào.',
                          style: TextStyle(
                            color: Color(0xff64748B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  // Bảng tổng quan điểm và phân bổ sao
                  _buildRatingOverview(_reviewsSummary!),
                  const Divider(height: 32),

                  // Danh sách các bài đánh giá
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _reviewsSummary!.reviews.length,
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (ctx, idx) =>
                        _buildReviewCard(_reviewsSummary!.reviews[idx]),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Nút Đặt lịch
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookingPage(doctor: doctor)),
              ),
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text(
                'Đặt lịch với bác sĩ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Khối tổng quan số sao + biểu đồ cột
  Widget _buildRatingOverview(DoctorReviewsSummary summary) {
    return Row(
      children: [
        Column(
          children: [
            Text(
              summary.averageRating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Color(0xff0F172A),
              ),
            ),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < summary.averageRating.round()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: const Color(0xffffb703),
                  size: 18,
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(
              '${summary.totalReviews} đánh giá',
              style: const TextStyle(fontSize: 12, color: Color(0xff64748B)),
            ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [5, 4, 3, 2, 1].map((star) {
              final count = summary.breakdown[star] ?? 0;
              final percent = summary.totalReviews > 0
                  ? count / summary.totalReviews
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text(
                      '$star',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xffffb703),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          backgroundColor: const Color(0xffE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xffffb703),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 20,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xff64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Từng Card Review
  Widget _buildReviewCard(ReviewItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xffE0F2FE),
              child: item.authorAvatar.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        item.authorAvatar,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      color: Color(0xff0284C7),
                      size: 20,
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.authorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    item.timeAgo,
                    style: const TextStyle(
                      color: Color(0xff94A3B8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < item.rating.round()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: const Color(0xffffb703),
                  size: 16,
                );
              }),
            ),
          ],
        ),
        if (item.comment.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            item.comment,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xff334155),
              height: 1.4,
            ),
          ),
        ],

        // Phản hồi từ Admin/Phòng khám (nếu có)
        if (item.adminReplyComment != null &&
            item.adminReplyComment!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffBBF7D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.verified, size: 15, color: Color(0xff16A34A)),
                    SizedBox(width: 5),
                    Text(
                      'Phản hồi từ Phòng khám / Admin',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff16A34A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.adminReplyComment!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _info(String t, String v) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        const SizedBox(height: 7),
        Text(v, style: const TextStyle(color: Color(0xff64748B), height: 1.45)),
      ],
    ),
  );
}
