import 'package:get/get.dart';
import '../features/dashboard/views/dashboard_view.dart';
import '../features/dashboard/bindings/dashboard_binding.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.DASHBOARD;

  static final routes = [
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(), // Penting! Biar Controller ke-load
      transition: Transition.fadeIn, // Animasi perpindahan smooth
    ),
  ];
}
