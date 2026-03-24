import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startApp();
  }

  void _startApp() async {
    // Kasih napas 3 detik buat user liat animasi/logo Bos
    await Future.delayed(const Duration(seconds: 3));

    // Nanti di sini bisa tambah logic: GetStorage().read('isLogin')
    Get.offAllNamed(Routes.LOGIN);
  }
}
