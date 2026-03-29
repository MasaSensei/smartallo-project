import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/features/subscription/controller/subcription_controller.dart';
import '../../../../core/theme/app_theme.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Pilih Paket Sultan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        if (controller.plans.isEmpty) {
          return const Center(
            child: Text(
              "Belum ada paket tersedia.",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          itemCount: controller.plans.length,
          itemBuilder: (context, index) {
            final plan = controller.plans[index];
            final List<String> features = List<String>.from(
              plan['features'] ?? [],
            );

            final String planTier = plan['tier'] ?? 'FREE';
            final bool isPro = planTier == 'PRO';
            // Logic Cek Paket Aktif
            final bool isActive = controller.currentTier.value == planTier;

            return _buildPlanCard(
              name: plan['name'] ?? "Plan",
              price: "Rp ${plan['price']}",
              features: features,
              isPopular: isPro,
              isActive: isActive,
              onPressed:
                  isActive
                      ? null // Tombol mati kalau paket sedang aktif
                      : () =>
                          controller.activateSubscription(plan['id'], planTier),
            );
          },
        );
      }),
    );
  }

  Widget _buildPlanCard({
    required String name,
    required String price,
    required List<String> features,
    required VoidCallback? onPressed,
    bool isPopular = false,
    bool isActive = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:
            isActive
                ? Colors.green.withOpacity(0.05)
                : (isPopular
                    ? AppTheme.primary.withOpacity(0.08)
                    : AppTheme.cardDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isActive
                  ? Colors.greenAccent
                  : (isPopular
                      ? AppTheme.primary
                      : Colors.white.withOpacity(0.05)),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isPopular && !isActive)
                _buildBadge("REKOMENDASI", Colors.amber),
              if (isActive)
                _buildBadge("PAKET ANDA SAAT INI", Colors.greenAccent),
              const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              fontSize: 20,
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 40, color: Colors.white10),
          ...features
              .map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color:
                            isActive
                                ? Colors.greenAccent
                                : Colors.greenAccent.withOpacity(0.5),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isActive
                        ? Colors.white12
                        : (isPopular ? AppTheme.primary : Colors.white10),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                isActive ? "Sedang Digunakan" : "Pilih Paket Ini",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
