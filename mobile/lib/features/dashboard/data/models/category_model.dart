class CategoryModel {
  final String id;
  final String orgId;
  final String name;
  final String type; // IN atau OUT

  CategoryModel({
    required this.id,
    required this.orgId,
    required this.name,
    required this.type,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      orgId: json['org_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'OUT',
    );
  }
}
