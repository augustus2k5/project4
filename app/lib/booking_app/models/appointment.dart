class AppointmentItem {
  final String id;
  final String date;
  final String timeSlot;
  final String reason;
  final String status;
  final String doctorName;
  final String specialty;
  final String patientName;
  final String doctorId;

  const AppointmentItem(
      {required this.id, required this.date, required this.timeSlot, required this.reason, required this.status, required this.doctorName, required this.specialty, required this.patientName, required this.doctorId});

  factory AppointmentItem.fromJson(Map<String, dynamic> j) {
    final d = j['doctorId'] is Map
        ? Map<String, dynamic>.from(j['doctorId'])
        : <String, dynamic>{};
    final u = d['userId'] is Map ? Map<String, dynamic>.from(d['userId']) : <
        String,
        dynamic>{};
    final s = d['specialtyId'] is Map ? Map<String, dynamic>.from(
        d['specialtyId']) : <String, dynamic>{};
    final p = j['patientId'] is Map
        ? Map<String, dynamic>.from(j['patientId'])
        : <String, dynamic>{};
    return AppointmentItem(
      id: '${j['_id'] ?? j['id'] ?? ''}',
      date: '${j['date'] ?? ''}',
      timeSlot: '${j['timeSlot'] ?? ''}',
      reason: '${j['reason'] ?? ''}',
      status: '${j['status'] ?? 'PENDING'}',
      doctorName: '${u['fullName'] ?? d['name'] ?? 'Bác sĩ'}',
      specialty: '${s['name'] ?? d['specialty'] ?? 'Chuyên khoa'}',
      patientName: '${p['fullName'] ?? ''}',
      doctorId: '${d['_id'] ?? j['doctorId'] ?? ''}',
    );
  }
}
