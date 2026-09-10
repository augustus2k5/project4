class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String specialtyId;
  final double rating;
  final int patients;
  final double price;
  final String bio;
  final int experienceYears;
  final String email;
  final String phone;

  const Doctor({
    required this.id, required this.name, required this.specialty,
    required this.specialtyId, required this.rating, required this.patients,
    required this.price, required this.bio, required this.experienceYears,
    required this.email, required this.phone,
  });

  factory Doctor.fromJson(Map<String, dynamic> j) {
    final user = j['userId'] is Map ? Map<String, dynamic>.from(j['userId']) : <String, dynamic>{};
    final spec = j['specialtyId'] is Map ? Map<String, dynamic>.from(j['specialtyId']) : <String, dynamic>{};
    double numD(dynamic x) => x is num ? x.toDouble() : double.tryParse('$x') ?? 0;
    int numI(dynamic x) => x is num ? x.toInt() : int.tryParse('$x') ?? 0;
    return Doctor(
      id: '${j['_id'] ?? j['id'] ?? ''}',
      name: '${user['fullName'] ?? j['name'] ?? 'Bác sĩ'}',
      specialty: '${spec['name'] ?? j['specialty'] ?? 'Chuyên khoa'}',
      specialtyId: '${spec['_id'] ?? spec['id'] ?? (j['specialtyId'] is String ? j['specialtyId'] : '')}',
      rating: numD(j['rating'] ?? 5),
      patients: numI(j['patients'] ?? 0),
      price: numD(j['price'] ?? 0),
      bio: '${j['bio'] ?? 'Tư vấn và thăm khám tận tâm, chuyên nghiệp.'}',
      experienceYears: numI(j['experienceYears'] ?? 0),
      email: '${user['email'] ?? ''}',
      phone: '${user['phoneNumber'] ?? ''}',
    );
  }
}
