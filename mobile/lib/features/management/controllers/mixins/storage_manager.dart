import 'package:get/get.dart';
import 'package:mobile/data/models/storage_model.dart';
import 'package:mobile/domain/repositories/storage_repository.dart';

mixin StorageManager {
  final storageRepo = Get.find<StorageRepository>();
  var rxStorages = <StorageModel>[].obs;

  Future<void> fetchStorages(String orgId) async {
    rxStorages.assignAll(await storageRepo.getByOrg(orgId));
  }

  Future<void> doAddStorage(StorageModel data) => storageRepo.create(data);
  Future<void> doUpdateStorage(String id, StorageModel data) =>
      storageRepo.update(id, data);
  Future<void> doDeleteStorage(String id) => storageRepo.deleteStorage(id);
}
