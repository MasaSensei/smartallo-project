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

  factory OrganizationModel.fromJson(Map<String, dynamic> json) =>
      OrganizationModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        type: json['type'] ?? 'PERSONAL',
        // Note: Check if your JSON keys are 'total_income' or 'TotalIncome'
        // to match your Go struct tags
        totalIncome: json['total_income']?.toString(),
        totalExpense: json['total_expense']?.toString(),
        totalBalance: json['total_balance']?.toString(),
        createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String(),
        ),
        weeklyChart:
            json['weekly_chart'] != null
                ? WeeklyChartModel.fromJson(json['weekly_chart'])
                : null,
      );
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
