class TransactionModel {
  final String id;
  final String categoryName;
  final String description;
  final double totalAmount;
  final String type;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.categoryName,
    required this.description,
    required this.totalAmount,
    required this.type,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      categoryName: json['category_name'] ?? 'Uncategorized',
      description: json['description'] ?? '',
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      type: json['type'] ?? 'OUT',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }
}
