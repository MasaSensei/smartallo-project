import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "SmartAllo",
      debugShowCheckedModeBanner: false,

      // Pakai Dark Theme Sultan Hasan
      theme: AppTheme.darkTheme,

      // Navigasi Terpusat
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,

      // Default transisi global kalau tidak di-set di GetPage
      defaultTransition: Transition.cupertino,

      // Mengatur scroll agar konsisten (Bouncing di Android & iOS)
      scrollBehavior: const ScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      ),
    );
  }
}
