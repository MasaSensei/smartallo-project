import 'package:mobile/data/models/category_model.dart';
import 'package:mobile/data/models/pocket_model.dart';
import 'package:mobile/data/models/storage_model.dart';
import 'package:mobile/features/management/controllers/management_controller.dart';
import 'package:mobile/features/management/widgets/forms/category_form.dart';
import 'package:mobile/features/management/widgets/forms/pocket_form.dart';
import 'package:mobile/features/management/widgets/forms/storage_form.dart';

class ManagementForms {
  static void showStorageForm({
    StorageModel? storage,
    required ManagementController controller,
  }) {
    StorageForm.show(storage: storage, controller: controller);
  }

  static void showPocketForm({
    PocketModel? pocket,
    required ManagementController controller,
  }) {
    PocketForm.show(pocket: pocket, controller: controller);
  }

  static void showCategoryForm({
    CategoryModel? category,
    required ManagementController controller,
  }) {
    CategoryForm.show(category: category, controller: controller);
  }
}
