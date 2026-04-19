import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../data/repositories/auth_repository_impl.dart'; // Import Impl-nya
import '../../../domain/repositories/auth_repository.dart'; // Import Interface-nya

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl());

    Get.lazyPut<AuthController>(
      () => AuthController(repository: Get.find<AuthRepository>()),
    );
  }
}
