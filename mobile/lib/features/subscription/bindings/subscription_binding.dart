import 'package:get/get.dart';
import 'package:mobile/features/subscription/controller/subcription_controller.dart';

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    // Inject controller agar bisa dipanggil di View pakai GetView
    Get.lazyPut<SubscriptionController>(() => SubscriptionController());
  }
}
