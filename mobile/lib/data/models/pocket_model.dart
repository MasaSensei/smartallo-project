class PocketModel {
  final String id;
  final String orgId;
  final String name;
  final double balance;
  final double targetAmount; // Tambahin ini
  final double allocationRule; // Tambahin ini
  final String? color;

  PocketModel({
    required this.id,
    required this.orgId,
    required this.name,
    required this.balance,
    this.targetAmount = 0,
    this.allocationRule = 0,
    this.color,
  });

  factory PocketModel.fromJson(Map<String, dynamic> json) {
    return PocketModel(
      id: json['id'] ?? '',
      orgId: json['org_id'] ?? '',
      name: json['name'] ?? '',
      // Backend kirim decimal, Flutter baca sebagai double/num
      balance: (json['balance'] ?? 0).toDouble(),
      targetAmount:
          (json['target_amount'] ?? 0).toDouble(), // Sesuai db:"target_amount"
      allocationRule: (json['allocation_rule'] ?? 0).toDouble(),
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'org_id': orgId,
      'name': name,
      'balance': balance,
      'target_amount': targetAmount,
      'allocation_rule': allocationRule,
      'color': color,
    };
  }
}
