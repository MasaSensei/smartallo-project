import 'package:get/get.dart';
import 'package:mobile/data/repositories/category_repository_impl.dart';
import 'package:mobile/data/repositories/pocket_repository_impl.dart';
import 'package:mobile/data/repositories/storage_repository_impl.dart';
import '../controllers/management_controller.dart';
import '../../../domain/repositories/storage_repository.dart';
import '../../../domain/repositories/pocket_repository.dart';
import '../../../domain/repositories/category_repository.dart';

class ManagementBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<StorageRepository>(() => StorageRepositoryImpl());
    Get.lazyPut<PocketRepository>(() => PocketRepositoryImpl());
    Get.lazyPut<CategoryRepository>(() => CategoryRepositoryImpl());

    // Controller
    Get.lazyPut<ManagementController>(() => ManagementController());
  }
}
