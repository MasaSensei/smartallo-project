import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'features/organization/controllers/organization_controller.dart';
import 'features/auth/services/auth_service.dart'; // Import AuthService kamu

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi storage
  await GetStorage.init();

  // 2. Inject AuthService secara Async agar .init() (baca token) selesai dulu
  // Ini lebih aman daripada taruh di Binding kalau servicenya butuh 'await'
  await Get.putAsync(() => AuthService().init());

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

      // Tambahkan controller global lainnya di sini
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
