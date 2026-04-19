import '../../data/models/pocket_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';

abstract class DashboardRepository {
  Future<List<PocketModel>> getPockets();
  Future<List<CategoryModel>> getCategories();
  Future<List<TransactionModel>> getHistory({int limit = 10});
  Future<bool> createTransaction(TransactionModel tx);
  Future<bool> deleteTransaction(String id);
}
