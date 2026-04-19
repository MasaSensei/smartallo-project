import 'package:mobile/data/models/organization_model.dart';

abstract class OrganizationRepository {
  Future<List<OrganizationModel>> getAll();
  Future<OrganizationModel> getDetail(String id);
  Future<bool> create(String name);
}
