class OrganizationModel {
  final String id;
  final String name;
  final String type;
  final double totalIncome;
  final double totalExpense;
  final double totalBalance;
  final DateTime createdAt;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.type,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalBalance,
    required this.createdAt,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) =>
      OrganizationModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        type: json['type'] ?? 'PERSONAL',
        totalIncome: double.tryParse(json['total_income'].toString()) ?? 0.0,
        totalExpense: double.tryParse(json['total_expense'].toString()) ?? 0.0,
        totalBalance: double.tryParse(json['total_balance'].toString()) ?? 0.0,
        createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String(),
        ),
      );
}
