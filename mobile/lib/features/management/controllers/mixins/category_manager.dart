import 'package:get/get.dart';
import 'package:mobile/data/models/category_model.dart';
import 'package:mobile/domain/repositories/category_repository.dart';

mixin CategoryManager {
  final categoryRepo = Get.find<CategoryRepository>();
  var rxCategories = <CategoryModel>[].obs;

  Future<void> fetchCategories(String orgId) async {
    rxCategories.assignAll(await categoryRepo.getByOrg(orgId));
  }

  Future<void> doAddCategory(CategoryModel data) => categoryRepo.create(data);
  Future<void> doUpdateCategory(String id, CategoryModel data) =>
      categoryRepo.update(id, data);
  Future<void> doDeleteCategory(String id) => categoryRepo.deleteCategory(id);
}
