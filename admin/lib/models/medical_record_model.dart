class MedicalRecordModel {
  final String id;

  final String appointmentId;
  final String patientId;
  final String doctorId;

  final String patientName;
  final String patientEmail;
  final String patientPhone;

  final String doctorName;
  final String doctorEmail;
  final String doctorPhone;

  final String date;
  final String timeSlot;
  final String appointmentStatus;

  final String diagnosis;
  final String notes;

  final List<PrescriptionModel> prescriptions;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  MedicalRecordModel({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.patientEmail,
    required this.patientPhone,
    required this.doctorName,
    required this.doctorEmail,
    required this.doctorPhone,
    required this.date,
    required this.timeSlot,
    required this.appointmentStatus,
    required this.diagnosis,
    required this.notes,
    required this.prescriptions,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicalRecordModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final patient =
        json['patientId'] is Map
            ? Map<String, dynamic>.from(
                json['patientId'],
              )
            : <String, dynamic>{};

    final doctor =
        json['doctorId'] is Map
            ? Map<String, dynamic>.from(
                json['doctorId'],
              )
            : <String, dynamic>{};

    final doctorUser =
        doctor['userId'] is Map
            ? Map<String, dynamic>.from(
                doctor['userId'],
              )
            : <String, dynamic>{};

    final appointment =
        json['appointmentId'] is Map
            ? Map<String, dynamic>.from(
                json['appointmentId'],
              )
            : <String, dynamic>{};

    final prescriptionList =
        json['prescriptions'] is List
            ? json['prescriptions'] as List
            : [];

    return MedicalRecordModel(
      id: json['_id']?.toString() ?? '',

      appointmentId:
          appointment['_id']?.toString() ??
          json['appointmentId']?.toString() ??
          '',

      patientId:
          patient['_id']?.toString() ??
          json['patientId']?.toString() ??
          '',

      doctorId:
          doctor['_id']?.toString() ??
          json['doctorId']?.toString() ??
          '',

      patientName:
          patient['fullName']?.toString() ?? '',

      patientEmail:
          patient['email']?.toString() ?? '',

      patientPhone:
          patient['phoneNumber']?.toString() ?? '',

      doctorName:
          doctorUser['fullName']?.toString() ?? '',

      doctorEmail:
          doctorUser['email']?.toString() ?? '',

      doctorPhone:
          doctorUser['phoneNumber']?.toString() ?? '',

      date:
          appointment['date']?.toString() ?? '',

      timeSlot:
          appointment['timeSlot']?.toString() ?? '',

      appointmentStatus:
          appointment['status']?.toString() ?? '',

      diagnosis:
          json['diagnosis']?.toString() ?? '',

      notes:
          json['notes']?.toString() ?? '',

      prescriptions:
          prescriptionList
              .whereType<Map>()
              .map(
                (item) =>
                    PrescriptionModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),

      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(
                  json['createdAt'].toString(),
                )
              : null,

      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(
                  json['updatedAt'].toString(),
                )
              : null,
    );
  }
}

class PrescriptionModel {
  final String drugName;
  final int quantity;
  final String dosage;

  PrescriptionModel({
    required this.drugName,
    required this.quantity,
    required this.dosage,
  });

  factory PrescriptionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PrescriptionModel(
      drugName:
          json['drugName']?.toString() ?? '',

      quantity:
          int.tryParse(
                json['quantity']?.toString() ?? '0',
              ) ??
              0,

      dosage:
          json['dosage']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drugName': drugName,
      'quantity': quantity,
      'dosage': dosage,
    };
  }
}