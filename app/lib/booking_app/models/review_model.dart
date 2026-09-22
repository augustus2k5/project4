class ReviewItem {
  final String id;
  final String? appointmentId;
  final String? patientId;
  final String doctorId;
  final double rating;
  final String comment;
  final List<String> images;
  final bool isAnonymous;
  final String authorName;
  final String authorAvatar;
  final String? adminReplyComment;
  final DateTime? adminRepliedAt;
  final DateTime createdAt;

  ReviewItem({
    required this.id,
    this.appointmentId,
    this.patientId,
    required this.doctorId,
    required this.rating,
    required this.comment,
    required this.images,
    required this.isAnonymous,
    required this.authorName,
    required this.authorAvatar,
    this.adminReplyComment,
    this.adminRepliedAt,
    required this.createdAt,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    double parseD(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? 5.0;

    List<String> parseImages(dynamic img) {
      if (img is List) return img.map((e) => '$e').toList();
      return [];
    }

    final adminReply = json['adminReply'] is Map ? json['adminReply'] : null;

    return ReviewItem(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      appointmentId: json['appointmentId'] != null
          ? '${json['appointmentId']}'
          : null,
      patientId: json['patientId'] != null ? '${json['patientId']}' : null,
      doctorId: '${json['doctorId'] ?? ''}',
      rating: parseD(json['rating']),
      comment: '${json['comment'] ?? ''}',
      images: parseImages(json['images']),
      isAnonymous: json['isAnonymous'] == true,
      authorName:
          '${json['authorName'] ?? (json['isAnonymous'] == true ? 'Bệnh nhân ẩn danh' : 'Bệnh nhân')}',
      authorAvatar: '${json['authorAvatar'] ?? ''}',
      adminReplyComment: adminReply != null ? adminReply['comment'] : null,
      adminRepliedAt: adminReply != null && adminReply['repliedAt'] != null
          ? DateTime.tryParse('${adminReply['repliedAt']}')
          : null,
      createdAt: DateTime.tryParse('${json['createdAt']}') ?? DateTime.now(),
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} năm trước';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} tháng trước';
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }
}

class DoctorReviewsSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> breakdown;
  final List<ReviewItem> reviews;

  DoctorReviewsSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.breakdown,
    required this.reviews,
  });

  factory DoctorReviewsSummary.fromJson(Map<String, dynamic> json) {
    double parseD(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? 5.0;
    int parseI(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

    final breakdownMap = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    if (json['breakdown'] is Map) {
      final b = json['breakdown'] as Map;
      b.forEach((k, v) {
        final key = int.tryParse('$k');
        if (key != null) breakdownMap[key] = parseI(v);
      });
    }

    final list = json['reviews'] is List
        ? (json['reviews'] as List)
              .map((e) => ReviewItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <ReviewItem>[];

    return DoctorReviewsSummary(
      averageRating: parseD(json['averageRating']),
      totalReviews: parseI(json['totalReviews']),
      breakdown: breakdownMap,
      reviews: list,
    );
  }
}
