class PocketModel {
  final String id;
  final String orgId;
  final String name;
  final double balance;
  final double targetAmount;
  final double allocationRule;
  final double selfTaxPercentage; // Baru
  final double selfTaxFlat; // Baru
  final bool isMain; // Baru
  final String? color;

  PocketModel({
    required this.id,
    required this.orgId,
    required this.name,
    required this.balance,
    this.targetAmount = 0,
    this.allocationRule = 0,
    this.selfTaxPercentage = 0,
    this.selfTaxFlat = 0,
    this.isMain = false,
    this.color,
  });

  factory PocketModel.fromJson(Map<String, dynamic> json) {
    return PocketModel(
      id: json['id'] ?? '',
      orgId: json['org_id'] ?? '',
      name: json['name'] ?? '',
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0,
      targetAmount:
          double.tryParse(json['target_amount']?.toString() ?? '0') ?? 0,
      allocationRule:
          double.tryParse(json['allocation_rule']?.toString() ?? '0') ?? 0,
      selfTaxPercentage:
          double.tryParse(json['self_tax_percentage']?.toString() ?? '0') ?? 0,
      selfTaxFlat:
          double.tryParse(json['self_tax_flat']?.toString() ?? '0') ?? 0,
      isMain: json['is_main'] ?? false,
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'org_id': orgId,
    'name': name,
    'balance': balance,
    'target_amount': targetAmount,
    'allocation_rule': allocationRule,
    'self_tax_percentage': selfTaxPercentage,
    'self_tax_flat': selfTaxFlat,
    'is_main': isMain,
    'color': color,
  };
}
