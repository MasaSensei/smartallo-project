class TransactionModel {
  final String? id;
  final String sourcePocketId;
  final String? pocketName; // Tambahan biar UI gampang nampilin nama kantong
  final String categoryId;
  final String? categoryName; // FIX UTAMA: Biar DashboardView gak error
  final int totalAmount;
  final String type; // IN or OUT
  final String description;
  final DateTime? createdAt;

  TransactionModel({
    this.id,
    required this.sourcePocketId,
    this.pocketName,
    required this.categoryId,
    this.categoryName,
    required this.totalAmount,
    required this.type,
    required this.description,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    "source_pocket_id": sourcePocketId,
    "category_id": categoryId,
    "total_amount": totalAmount,
    "type": type,
    "description": description,
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'],
        sourcePocketId: json['source_pocket_id'] ?? "",
        pocketName: json['pocket_name'], // Mapping dari field pocket_name
        categoryId: json['category_id'] ?? "",
        categoryName: json['category_name'], // Mapping dari field category_name
        totalAmount: json['total_amount'] ?? 0,
        type: json['type'] ?? "OUT",
        description: json['description'] ?? "",
        createdAt:
            json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : null,
      );
}
