import 'package:get/get.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/routes/app_routes.dart';

class SplashController extends GetxController {
  // Panggil AuthService yang sudah standby di memori
  AuthService get _authService => Get.find<AuthService>();
  @override
  void onInit() {
    super.onInit();
    _startApp();
  }

  void _startApp() async {
    // 1. Kasih napas 3 detik buat user liat branding SmartAllo
    await Future.delayed(const Duration(seconds: 3));

    // 2. Cek status login dari Service
    if (_authService.isLoggedIn) {
      // JOS! Token ada, langsung masuk ke Dashboard Organisasi
      Get.offAllNamed(Routes.ORGANIZATION);
    } else {
      // Token kosong, suruh login dulu
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
