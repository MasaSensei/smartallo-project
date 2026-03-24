import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';

void main() {
  // Pastikan inisialisasi system dilakukan jika nanti pakai Storage/Firebase
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

      // Pakai Theme Sultan kita
      theme: AppTheme.darkTheme,

      // Navigasi
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,

      // Efek scroll ala iOS (Bouncing) sedunia
      defaultTransition: Transition.cupertino,
    );
  }
}
