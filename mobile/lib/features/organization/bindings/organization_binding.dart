import 'package:get/get.dart';
import '../controllers/organization_controller.dart';

class OrganizationBinding extends Bindings {
  @override
  void dependencies() {
    // Menggunakan lazyPut dengan fenix true agar controller
    // bisa di-instantiate ulang otomatis jika dibutuhkan fitur lain
    Get.lazyPut<OrganizationController>(
      () => OrganizationController(),
      fenix: true,
    );
  }
}
