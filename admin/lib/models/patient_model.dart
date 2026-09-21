class PatientModel {
  final String id;
  final String userId;
  final String patientCode;

  // Thông tin từ User
  final String fullName;
  final String email;
  final String phoneNumber;
  final String status;

  // Thông tin Patient
  final DateTime? dateOfBirth;
  final String gender;
  final String identityCard;
  final String address;
  final String medicalHistory;
  final String allergies;

  PatientModel({
    required this.id,
    required this.userId,
    required this.patientCode,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.status,
    required this.dateOfBirth,
    required this.gender,
    required this.identityCard,
    required this.address,
    required this.medicalHistory,
    required this.allergies,
  });

  factory PatientModel.fromJson(
    Map<String, dynamic> json,
  ) {
    String userId = '';
    String fullName = '';
    String email = '';
    String phoneNumber = '';
    String status = '';

    final user = json['userId'];

    // ==========================================================
    // USER ĐÃ ĐƯỢC POPULATE
    // ==========================================================

    if (user is Map) {
      userId = (
        user['_id'] ??
        user['id'] ??
        ''
      ).toString();

      fullName = (
        user['fullName'] ??
        ''
      ).toString();

      email = (
        user['email'] ??
        ''
      ).toString();

      phoneNumber = (
        user['phoneNumber'] ??
        ''
      ).toString();

      status = (
        user['status'] ??
        ''
      ).toString();
    }

    // ==========================================================
    // USERID LÀ STRING
    // ==========================================================

    else if (user != null) {
      userId = user.toString();
    }

    // ==========================================================
    // BACKEND FORMAT PATIENT TRẢ STATUS TRỰC TIẾP
    // ==========================================================

    if (fullName.isEmpty) {
      fullName = (
        json['fullName'] ??
        ''
      ).toString();
    }

    if (email.isEmpty) {
      email = (
        json['email'] ??
        ''
      ).toString();
    }

    if (phoneNumber.isEmpty) {
      phoneNumber = (
        json['phoneNumber'] ??
        ''
      ).toString();
    }

    // QUAN TRỌNG:
    // Backend formatPatient() trả status trực tiếp
    if (status.isEmpty) {
      status = (
        json['status'] ??
        'ACTIVE'
      ).toString();
    }

    // Chuẩn hóa status
    status = status.toUpperCase();

    // Chỉ cho phép 3 trạng thái
    if (![
      'ACTIVE',
      'INACTIVE',
      'BLOCKED',
    ].contains(status)) {
      status = 'ACTIVE';
    }

    // ==========================================================
    // NGÀY SINH
    // ==========================================================

    DateTime? dateOfBirth;

    final dob = json['dateOfBirth'];

    if (dob != null &&
        dob.toString().trim().isNotEmpty) {
      try {
        dateOfBirth = DateTime.parse(
          dob.toString(),
        );
      } catch (_) {
        dateOfBirth = null;
      }
    }

    // ==========================================================
    // RETURN
    // ==========================================================

    return PatientModel(
      id: (
        json['_id'] ??
        json['id'] ??
        ''
      ).toString(),

      userId: userId,

      patientCode: (
        json['patientCode'] ??
        ''
      ).toString(),

      fullName: fullName,

      email: email,

      phoneNumber: phoneNumber,

      status: status,

      dateOfBirth: dateOfBirth,

      gender: (
        json['gender'] ??
        'OTHER'
      ).toString(),

      identityCard: (
        json['identityCard'] ??
        ''
      ).toString(),

      address: (
        json['address'] ??
        ''
      ).toString(),

      medicalHistory: (
        json['medicalHistory'] ??
        ''
      ).toString(),

      allergies: (
        json['allergies'] ??
        ''
      ).toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'patientCode': patientCode,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'status': status,
      'dateOfBirth':
          dateOfBirth?.toIso8601String(),
      'gender': gender,
      'identityCard': identityCard,
      'address': address,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
    };
  }
}