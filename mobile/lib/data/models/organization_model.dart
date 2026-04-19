class OrganizationModel {
  final String id;
  final String name;
  final String type;
  final String? totalIncome;
  final String? totalExpense;
  final String? totalBalance;
  final DateTime createdAt;
  final WeeklyChartModel? weeklyChart; // New field

  OrganizationModel({
    required this.id,
    required this.name,
    required this.type,
    this.totalIncome,
    this.totalExpense,
    this.totalBalance,
    required this.createdAt,
    this.weeklyChart,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      // Decimal dari Go sering dikirim sebagai String di JSON
      totalIncome: json['total_income']?.toString() ?? '0',
      totalExpense: json['total_expense']?.toString() ?? '0',
      totalBalance: json['total_balance']?.toString() ?? '0',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }
}

class WeeklyChartModel {
  final List<String> labels;
  final List<double> income;
  final List<double> expense;

  WeeklyChartModel({
    required this.labels,
    required this.income,
    required this.expense,
  });

  factory WeeklyChartModel.fromJson(Map<String, dynamic> json) {
    return WeeklyChartModel(
      labels: List<String>.from(json['labels'] ?? []),
      income:
          (json['income'] as List?)
              ?.map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList() ??
          [],
      expense:
          (json['expense'] as List?)
              ?.map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList() ??
          [],
    );
  }
}
