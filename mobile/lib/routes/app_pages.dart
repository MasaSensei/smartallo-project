import 'package:get/get.dart';
import 'package:mobile/features/splash/bindings/splash_binding.dart';
import 'package:mobile/features/splash/views/splash_view.dart';
import '../features/auth/bindings/auth_binding.dart';
import '../features/auth/views/login_view.dart';
import '../features/auth/views/register_view.dart';
import '../features/dashboard/bindings/dashboard_binding.dart';
import '../features/dashboard/views/dashboard_view.dart';
import 'app_routes.dart';

class AppPages {
  // Ganti INITIAL ke LOGIN sesuai alur sistem
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition:
          Transition.fadeIn, // <--- Tambahkan ini biar transisinya halus
      transitionDuration: const Duration(milliseconds: 800),
    ),
    // --- AUTH FEATURE ---
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeftWithFade, // Animasi geser biar cakep
    ),

    // --- DASHBOARD FEATURE ---
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      transition: Transition.cupertino,
    ),
  ];
}
