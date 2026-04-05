import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'features/auth/services/auth_service.dart';

void main() async {
  // Pastikan binding Flutter siap
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi GetStorage (Global & Spesifik Auth)
  await GetStorage.init();
  await GetStorage.init('SmartAlloAuth');

  // 2. Siapkan AuthService (Sistem Memori Utama)
  // Kita inisialisasi manual dulu agar .init() (baca token) selesai sempurna
  final authService = AuthService();
  await authService.init();

  // 3. Inject ke GetX secara permanen agar bisa diakses BaseClient & Controller lain
  Get.put(authService, permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "SmartAllo",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // initialBinding sekarang bersih dari controller fitur (Organization, dll)
      // Fitur-fitur tersebut akan di-load lewat Bindings di AppPages
      initialBinding: BindingsBuilder(() {
        // Taruh controller yang bener-bener global di sini jika ada.
        // Contoh: ThemeController atau ConnectivityController.
      }),

      initialRoute: AppPages.INITIAL, // Akan lari ke SPLASH dulu
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,

      scrollBehavior: const ScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      ),
    );
  }
}
