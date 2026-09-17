class AppointmentModel {
  final String id;
  final String patientName;
  final String patientPhone;
  final String patientEmail;
  final String doctorId;
  final String doctorName;
  final String specialtyName;
  final String date;
  final String timeSlot;
  final String reason;
  String status;

  AppointmentModel({
    required this.id,
    required this.patientName,
    required this.patientPhone,
    required this.patientEmail,
    required this.doctorId,
    required this.doctorName,
    required this.specialtyName,
    required this.date,
    required this.timeSlot,
    required this.reason,
    required this.status,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // Thông tin Bệnh nhân
    final patient = json['patientId'] is Map ? json['patientId'] : {};
    final pName = patient['fullName'] ?? 'Bệnh nhân';
    final pPhone = patient['phoneNumber'] ?? '';
    final pEmail = patient['email'] ?? '';

    // Thông tin Bác sĩ
    final doctorObj = json['doctorId'] is Map ? json['doctorId'] : {};
    final docId = doctorObj['_id'] ?? doctorObj['id'] ?? '';
    final docUser = doctorObj['userId'] is Map ? doctorObj['userId'] : {};
    final dName = docUser['fullName'] ?? 'Bác sĩ';
    final specialtyObj = doctorObj['specialtyId'] is Map
        ? doctorObj['specialtyId']
        : {};
    final sName = specialtyObj['name'] ?? 'Đa khoa';

    return AppointmentModel(
      id: json['_id'] ?? json['id'] ?? '',
      patientName: pName,
      patientPhone: pPhone,
      patientEmail: pEmail,
      doctorId: docId,
      doctorName: dName,
      specialtyName: sName,
      date: json['date'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'PENDING',
    );
  }
}

/// Gom nhóm lịch hẹn theo từng Bác sĩ
class DoctorAppointmentGroup {
  final String doctorId;
  final String doctorName;
  final String specialtyName;
  final List<AppointmentModel> appointments;

  DoctorAppointmentGroup({
    required this.doctorId,
    required this.doctorName,
    required this.specialtyName,
    required this.appointments,
  });

  int get totalAppointments => appointments.length;
  int get pendingCount =>
      appointments.where((a) => a.status == 'PENDING').length;
  int get confirmedCount =>
      appointments.where((a) => a.status == 'CONFIRMED').length;
  int get completedCount =>
      appointments.where((a) => a.status == 'COMPLETED').length;
}
