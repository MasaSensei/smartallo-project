import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Tambahkan ini
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'features/organization/controllers/organization_controller.dart'; // Import controller

void main() async {
  // Wajib panggil ini kalau ada async sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi storage biar token & org_id aman
  await GetStorage.init();

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

      // --- SOLUSI UTAMA: Inject OrganizationController secara Global ---
      initialBinding: BindingsBuilder(() {
        Get.put(OrganizationController(), permanent: true);
      }),

      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,

      scrollBehavior: const ScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      ),
    );
  }
}
