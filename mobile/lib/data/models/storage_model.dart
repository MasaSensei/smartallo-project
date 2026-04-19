// lib/app/data/models/storage_model.dart
class StorageModel {
  final String? id;
  final String orgId;
  final String name;
  final String type; // BANK, CASH, E-WALLET
  final double balance;

  StorageModel({
    this.id,
    required this.orgId,
    required this.name,
    required this.type,
    this.balance = 0,
  });

  factory StorageModel.fromJson(Map<String, dynamic> json) => StorageModel(
    id: json['id'],
    orgId: json['org_id'],
    name: json['name'],
    type: json['type'],
    balance: double.tryParse(json['balance'].toString()) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "org_id": orgId,
    "name": name,
    "type": type,
    "balance": balance,
  };
}
