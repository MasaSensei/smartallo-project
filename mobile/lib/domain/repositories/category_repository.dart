import 'package:mobile/data/models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getByOrg(String orgId);
  Future<CategoryModel> create(CategoryModel category);
  Future<CategoryModel> update(String id, CategoryModel category);
  Future<bool> deleteCategory(String id);
}
