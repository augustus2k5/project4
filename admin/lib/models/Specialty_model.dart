class Specialty {
  final String id;
  final String name;
  final String description;
  final String status;

  Specialty({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ACTIVE',
    );
  }
}