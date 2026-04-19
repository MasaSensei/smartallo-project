import '../../data/models/storage_model.dart';

abstract class StorageRepository {
  Future<List<StorageModel>> getByOrg(String orgId);
  Future<StorageModel> create(StorageModel storage);
  Future<StorageModel> update(String id, StorageModel storage);
  Future<bool> deleteStorage(String id);
}
