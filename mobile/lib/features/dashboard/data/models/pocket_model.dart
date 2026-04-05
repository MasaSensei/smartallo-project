class PocketModel {
  final String id;
  final String orgId;
  final String name;
  final double balance;
  final String color;

  PocketModel({
    required this.id,
    required this.orgId,
    required this.name,
    required this.balance,
    required this.color,
  });

  factory PocketModel.fromJson(Map<String, dynamic> json) {
    return PocketModel(
      id: json['id'] ?? '',
      orgId: json['org_id'] ?? '',
      name: json['name'] ?? '',
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      color: json['color'] ?? '#4285F4',
    );
  }
}
