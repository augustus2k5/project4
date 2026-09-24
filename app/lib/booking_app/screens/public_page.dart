import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

class PublicPage extends StatelessWidget {
  const PublicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xffE0F2FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: Color(0xff0284C7),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phòng khám Y khoa',
                  style: TextStyle(
                    color: Color(0xff0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Uy tín • Tận tâm • Chuyên nghiệp',
                  style: TextStyle(color: Color(0xff64748B), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingLoginPage()),
              );
            },
            child: const Text(
              'Đăng nhập',
              style: TextStyle(
                color: Color(0xff0284C7),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // 1. HERO BANNER
            // ============================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff0284C7), Color(0xff38BDF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff0284C7).withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Chuẩn Y Khoa Chất Lượng Cao',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Chăm Sóc Sức Khỏe\nToàn Diện Cho Bạn & Gia Đình',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Đặt lịch khám nhanh chóng với đội ngũ Bác sĩ chuyên khoa đầu ngành. Tiết kiệm 90% thời gian chờ đợi.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BookingLoginPage(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.calendar_month_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'Đặt khám ngay',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xff0284C7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            // ============================================================
            // CHUYÊN KHOA KHÁM CHỮA BỆNH CHUYÊN SÂU
            // ============================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Chuyên khoa chuyên sâu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff0F172A),
                  ),
                ),
                Text(
                  '8 Khoa mũi nhọn',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff0284C7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Trang thiết bị hiện đại cùng phác đồ điều trị chuẩn quốc tế',
              style: TextStyle(fontSize: 12, color: Color(0xff64748B)),
            ),
            const SizedBox(height: 14),
            // Lưới 8 chuyên khoa chuyên sâu
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
              children: [
                _buildSpecialtyItem(
                  context,
                  title: 'Tim mạch',
                  icon: Icons.favorite_rounded,
                  color: const Color(0xffEF4444),
                ),
                _buildSpecialtyItem(
                  context,
                  title: 'Nhi khoa',
                  icon: Icons.child_care_rounded,
                  color: const Color(0xffF59E0B),
                ),
                _buildSpecialtyItem(
                  context,
                  title: 'Cơ Xương Khớp',
                  icon: Icons.accessibility_new_rounded,
                  color: const Color(0xff10B981),
                ),
                _buildSpecialtyItem(
                  context,
                  title: 'Tai Mũi Họng',
                  icon: Icons.hearing_rounded,
                  color: const Color(0xff06B6D4),
                ),
                _buildSpecialtyItem(
                  context,
                  title: 'Da liễu',
                  icon: Icons.face_retouching_natural_rounded,
                  color: const Color(0xffEC4899),
                ),
                _buildSpecialtyItem(
                  context,
                  title: 'Tiêu hóa',
                  icon: Icons.restaurant_menu_rounded,
                  color: const Color(0xff8B5CF6),
                ),
                _buildSpecialtyItem(
                  context,
                  title: 'Thần kinh',
                  icon: Icons.psychology_rounded,
                  color: const Color(0xff3B82F6),
                ),
                _buildSpecialtyItem(
                  context,
                  title: 'Răng Hàm Mặt',
                  icon: Icons.medical_services_outlined,
                  color: const Color(0xff14B8A6),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ============================================================
            // 2. CON SỐ UY TÍN (STATS)
            // ============================================================
            Row(
              children: [
                _buildStatItem(
                  '50+',
                  'Bác sĩ giỏi',
                  Icons.medical_services_rounded,
                ),
                const SizedBox(width: 10),
                _buildStatItem('20+', 'Chuyên khoa', Icons.domain_rounded),
                const SizedBox(width: 10),
                _buildStatItem(
                  '15.000+',
                  'Lượt khám',
                  Icons.people_alt_rounded,
                ),
                const SizedBox(width: 10),
                _buildStatItem('4.9 ⭐', 'Hài lòng', Icons.star_rounded),
              ],
            ),
            const SizedBox(height: 26),

            // ============================================================
            // 3. TẠI SAO CHỌN PHÒNG KHÁM Y KHOA
            // ============================================================
            const Text(
              'Lý do chọn Phòng khám Y khoa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xff0F172A),
              ),
            ),
            const SizedBox(height: 14),
            _buildFeatureTile(
              icon: Icons.timer_outlined,
              title: 'Không chờ đợi lâu',
              desc:
                  'Chọn chính xác khung giờ khám bạn mong muốn, đến là được khám ngay.',
              color: const Color(0xff0284C7),
            ),
            _buildFeatureTile(
              icon: Icons.badge_outlined,
              title: 'Đội ngũ Bác sĩ đầu ngành',
              desc:
                  'Các bác sĩ giàu kinh nghiệm, tận tâm từ các bệnh viện lớn tuyến trung ương.',
              color: const Color(0xff16A34A),
            ),
            _buildFeatureTile(
              icon: Icons.description_outlined,
              title: 'Hồ sơ bệnh án điện tử',
              desc:
                  'Theo dõi lịch sử khám, đơn thuốc và kết quả xét nghiệm ngay trên điện thoại.',
              color: const Color(0xff7C3AED),
            ),
            _buildFeatureTile(
              icon: Icons.security_outlined,
              title: 'Bảo mật thông tin 100%',
              desc:
                  'Thông tin cá nhân và bệnh án được mã hóa an toàn theo chuẩn quốc tế.',
              color: const Color(0xffEA580C),
            ),
            const SizedBox(height: 26),

            // ============================================================
            // 4. ĐỘI NGŨ BÁC SĨ TIÊU BIỂU
            // ============================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Bác sĩ tiêu biểu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff0F172A),
                  ),
                ),
                Text(
                  'Nhiều năm kinh nghiệm',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildDoctorCard(
              name: 'TS. BS Nguyễn Văn An',
              specialty: 'Chuyên khoa Tim mạch',
              exp: '18 năm kinh nghiệm',
              rating: '5.0 (140 đánh giá)',
              avatarUrl:
                  'https://htmediagroup.vn/wp-content/uploads/2022/09/Anh-bac-si-nu-1-min.jpg.webp',
            ),
            _buildDoctorCard(
              name: 'ThS. BS Trần Thị Mai',
              specialty: 'Chuyên khoa Nhi',
              exp: '12 năm kinh nghiệm',
              rating: '4.9 (98 đánh giá)',
              avatarUrl:
                  'https://htmediagroup.vn/wp-content/uploads/2022/01/Anh-bac-si-1-min.jpg.webp',
            ),
            _buildDoctorCard(
              name: 'BS. CKI Lê Hoàng Nam',
              specialty: 'Chuyên khoa Cơ Xương Khớp',
              exp: '15 năm kinh nghiệm',
              rating: '4.9 (115 đánh giá)',
              avatarUrl:
                  'https://htmediagroup.vn/wp-content/uploads/2022/12/Anh-bac-si-12-min.jpg.webp',
            ),
            const SizedBox(height: 26),

            // ============================================================
            // 5. CẢM NHẬN TỪ BỆNH NHÂN (TESTIMONIALS)
            // ============================================================
            const Text(
              'Bệnh nhân nói về chúng tôi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xff0F172A),
              ),
            ),
            const SizedBox(height: 14),
            _buildReviewCard(
              patientName: 'Chị Hoàng Thu Hằng',
              date: 'Đã khám ngày 15/09/2026',
              comment:
                  'Đặt lịch qua ứng dụng rất tiện, đến phòng khám được hướng dẫn tận tình và bác sĩ thăm khám cực kỳ nhẹ nhàng, chi tiết!',
            ),
            _buildReviewCard(
              patientName: 'Anh Phạm Minh Đức',
              date: 'Đã khám ngày 20/09/2026',
              comment:
                  'Hồ sơ bệnh án hiển thị rõ ràng trên app, không sợ bị thất lạc kết quả hay đơn thuốc. Dịch vụ tuyệt vời!',
            ),
            const SizedBox(height: 26),

            // ============================================================
            // 6. THÔNG TIN LIÊN HỆ & ĐỊA CHỈ
            // ============================================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xffE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin liên hệ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildContactRow(
                    Icons.location_on_outlined,
                    'Số 123 Đường Y Dược,Hà Nội',
                  ),
                  _buildContactRow(
                    Icons.phone_in_talk_outlined,
                    'Hotline cấp cứu & Tư vấn: 1900 6868',
                  ),
                  _buildContactRow(
                    Icons.access_time_rounded,
                    'Giờ làm việc: Thứ 2 - Chủ Nhật (07:00 - 20:00)',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ============================================================
      // 7. THANH NÚT ĐĂNG NHẬP / ĐĂNG KÝ CỐ ĐỊNH Ở ĐÁY (STICKY CTA)
      // ============================================================
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingRegisterPage(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xff0284C7), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Đăng ký',
                  style: TextStyle(
                    color: Color(0xff0284C7),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingLoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0284C7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text(
                  'Đăng nhập để sử dụng',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Thống kê
  Widget _buildStatItem(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xff0284C7), size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: Color(0xff0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xff64748B),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Widget Tính năng nổi bật
  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xff0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Color(0xff64748B),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Thẻ Bác sĩ
  Widget _buildDoctorCard({
    required String name,
    required String specialty,
    required String exp,
    required String rating,
    required String avatarUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              avatarUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: const Color(0xffE0F2FE),
                child: const Icon(Icons.person, color: Color(0xff0284C7)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xff0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  specialty,
                  style: const TextStyle(
                    color: Color(0xff0284C7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xffffb703),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Đánh giá bệnh nhân
  Widget _buildReviewCard({
    required String patientName,
    required String date,
    required String comment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                patientName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => const Icon(
                    Icons.star_rounded,
                    color: Color(0xffffb703),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: const TextStyle(color: Color(0xff94A3B8), fontSize: 11),
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: const TextStyle(
              color: Color(0xff334155),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xff0284C7)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xff475569)),
            ),
          ),
        ],
      ),
    );
  }

  //chuyên khoa
  Widget _buildSpecialtyItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookingLoginPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7), // Tinh chỉnh padding icon
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xff1E293B),
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
