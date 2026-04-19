import 'dart:convert';
import 'package:mobile/data/models/category_model.dart';
import 'package:mobile/data/models/pocket_model.dart';
import 'package:mobile/data/models/transaction_model.dart';

import '../../../core/network/base_client.dart'; // Sesuaikan path BaseClient kamu
import '../../../core/constants/api_constants.dart';

class DashboardService {
  /// Mengambil semua data Pocket berdasarkan OrgID
  static Future<List<PocketModel>> getPockets(String orgId) async {
    final response = await BaseClient.get(
      "${ApiConstants.pockets}?org_id=$orgId",
    );

    if (response != null && response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'] ?? [];
      return data.map((json) => PocketModel.fromJson(json)).toList();
    }
    return [];
  }

  /// Mengambil semua Kategori (IN/OUT)
  static Future<List<CategoryModel>> getCategories(String orgId) async {
    final response = await BaseClient.get(
      "${ApiConstants.categories}?org_id=$orgId",
    );

    if (response != null && response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'] ?? [];
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    }
    return [];
  }

  /// Mengambil Riwayat Transaksi terakhir
  static Future<List<TransactionModel>> getTransactionHistory(
    String orgId, {
    int limit = 5,
  }) async {
    final response = await BaseClient.get(
      "${ApiConstants.transactionHistory}?org_id=$orgId&limit=$limit",
    );

    if (response != null && response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'] ?? [];
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    }
    return [];
  }

  /// Simpan Transaksi Baru
  static Future<bool> createTransaction(Map<String, dynamic> payload) async {
    final response = await BaseClient.post(ApiConstants.transactions, payload);
    return response != null &&
        (response.statusCode == 201 || response.statusCode == 200);
  }
}
