class AdminReviewModel {
  final String id;
  final String? appointmentId;
  final String doctorId;
  final String doctorName;
  final String patientName;
  final String patientEmail;
  final double rating;
  final String comment;
  final bool isAnonymous;
  final String? adminReply;
  final DateTime createdAt;

  AdminReviewModel({
    required this.id,
    this.appointmentId,
    required this.doctorId,
    required this.doctorName,
    required this.patientName,
    required this.patientEmail,
    required this.rating,
    required this.comment,
    required this.isAnonymous,
    this.adminReply,
    required this.createdAt,
  });

  factory AdminReviewModel.fromJson(Map<String, dynamic> json) {
    double parseD(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? 5.0;

    String docName = 'Bác sĩ';
    if (json['doctorId'] is Map) {
      final docObj = json['doctorId'] as Map;
      if (docObj['userId'] is Map) {
        docName = '${docObj['userId']['fullName'] ?? 'Bác sĩ'}';
      }
    }

    String patName = '${json['customAuthorName'] ?? ''}';
    String patEmail = '';
    if (json['patientId'] is Map) {
      final pObj = json['patientId'] as Map;
      patName = '${pObj['fullName'] ?? 'Bệnh nhân'}';
      patEmail = '${pObj['email'] ?? ''}';
    }
    if (patName.isEmpty)
      patName = json['isAnonymous'] == true ? 'Ẩn danh' : 'Khách hàng';

    String? replyText;
    if (json['adminReply'] is Map) {
      replyText = json['adminReply']['comment'];
    }

    return AdminReviewModel(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      appointmentId: json['appointmentId'] != null
          ? '${json['appointmentId']}'
          : null,
      doctorId: json['doctorId'] is Map
          ? '${json['doctorId']['_id'] ?? ''}'
          : '${json['doctorId'] ?? ''}',
      doctorName: docName,
      patientName: patName,
      patientEmail: patEmail,
      rating: parseD(json['rating']),
      comment: '${json['comment'] ?? ''}',
      isAnonymous: json['isAnonymous'] == true,
      adminReply: replyText,
      createdAt: DateTime.tryParse('${json['createdAt']}') ?? DateTime.now(),
    );
  }
}
