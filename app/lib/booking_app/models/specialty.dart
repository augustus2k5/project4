class Specialty {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String status;
  const Specialty({required this.id, required this.name, required this.description, required this.iconUrl, required this.status});
  factory Specialty.fromJson(Map<String, dynamic> j) => Specialty(
    id: '${j['_id'] ?? j['id'] ?? ''}', name: '${j['name'] ?? ''}', description: '${j['description'] ?? ''}',
    iconUrl: '${j['iconUrl'] ?? ''}', status: '${j['status'] ?? 'ACTIVE'}',
  );
}
