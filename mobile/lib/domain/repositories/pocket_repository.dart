import 'package:mobile/data/models/pocket_model.dart';

abstract class PocketRepository {
  Future<List<PocketModel>> getByOrg(String orgId);
  Future<PocketModel> create(PocketModel pocket);
  Future<PocketModel> update(String id, PocketModel pocket);
  Future<bool> deletePocket(String id);
}
