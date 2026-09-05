enum UserRole {
  patient,
  doctor,
  admin;

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'DOCTOR':
        return UserRole.doctor;
      case 'ADMIN':
        return UserRole.admin;
      case 'PATIENT':
      default:
        return UserRole.patient;
    }
  }

  String toShortString() => name.toUpperCase();
}

class UserModels {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final UserRole role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModels({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModels.fromJson(Map<String, dynamic> json) {
    return UserModels(
      id: json['id'] ?? json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: UserRole.fromString(json['role'] ?? 'PATIENT'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.toShortString(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
