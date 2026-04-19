import 'package:get/get.dart';
import 'package:mobile/data/models/pocket_model.dart';
import 'package:mobile/domain/repositories/pocket_repository.dart';

mixin PocketManager {
  final pocketRepo = Get.find<PocketRepository>();
  var rxPockets = <PocketModel>[].obs;

  Future<void> fetchPockets(String orgId) async {
    rxPockets.assignAll(await pocketRepo.getByOrg(orgId));
  }

  Future<void> doAddPocket(PocketModel data) => pocketRepo.create(data);
  Future<void> doUpdatePocket(String id, PocketModel data) =>
      pocketRepo.update(id, data);
  Future<void> doDeletePocket(String id) => pocketRepo.deletePocket(id);
}
