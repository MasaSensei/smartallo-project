import 'package:get/get.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/base_client.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/routes/app_routes.dart';

class SplashController extends GetxController {
  final auth = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _startRouting();
  }

  void _startRouting() async {
    // 1. Catat waktu mulai
    final startTime = DateTime.now();

    if (auth.isLoggedIn) {
      try {
        // 2. Langsung tembak server (sambil animasi jalan)
        final response = await BaseClient.get(ApiConstants.mainDashboard);

        // 3. Hitung sisa waktu biar animasi minimal tampil (misal minimal 2 detik)
        final duration = DateTime.now().difference(startTime);
        if (duration.inSeconds < 2) {
          await Future.delayed(Duration(seconds: 2 - duration.inSeconds));
        }

        if (response != null && response.statusCode == 200) {
          Get.offAllNamed(Routes.DASHBOARD);
        } else {
          // Jika gagal/401, BaseClient sudah handle tendang ke login,
          // tapi kita kasih fallback biar nggak macet di Splash
          if (Get.currentRoute != Routes.LOGIN) Get.offAllNamed(Routes.LOGIN);
        }
      } catch (e) {
        Get.offAllNamed(Routes.LOGIN);
      }
    } else {
      // Kalau nggak login, tetap tunggu 2 detik biar logo SmartAllo kelihatan
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
