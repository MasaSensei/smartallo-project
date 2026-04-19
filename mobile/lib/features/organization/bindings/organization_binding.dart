import 'package:get/get.dart';
import 'package:mobile/data/repositories/organization_repository_impl.dart';
import 'package:mobile/domain/repositories/organization_repository.dart';
import '../controllers/organization_controller.dart';

class OrganizationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrganizationRepository>(() => OrganizationRepositoryImpl());
    Get.lazyPut(() => OrganizationController(repository: Get.find()));
  }
}
