import 'package:get/get.dart';
// Controllers
import 'package:mobile/features/organization/controllers/organization_controller.dart';
import 'package:mobile/features/dashboard/controllers/dashboard_controller.dart';
// Repositories Interface
import 'package:mobile/domain/repositories/dashboard_repository.dart';
import 'package:mobile/domain/repositories/organization_repository.dart';
// Repositories Impl (PENTING: Harus di-import agar class-nya dikenal)
import 'package:mobile/data/repositories/dashboard_repository_impl.dart';
import 'package:mobile/data/repositories/organization_repository_impl.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // 1. DAFTARKAN REPOSITORY DENGAN TIPE INTERFACE-NYA
    // Gunakan Get.put<OrganizationRepository>(...) agar GetX tahu ini adalah implementasi dari Interface tersebut
    final orgRepo = Get.put<OrganizationRepository>(
      OrganizationRepositoryImpl(),
    );

    // Sama halnya dengan DashboardRepository
    final dashRepo = Get.put<DashboardRepository>(DashboardRepositoryImpl());

    // 2. INJECT KE CONTROLLER
    // OrganizationController biasanya butuh repo di constructor-nya
    Get.put(OrganizationController(repository: orgRepo), permanent: true);

    // DashboardController
    Get.lazyPut<DashboardController>(
      () => DashboardController(repository: dashRepo),
    );
  }
}
