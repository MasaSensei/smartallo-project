import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/features/splash/controllers/splash_controller.dart';
import '../../../../core/theme/app_theme.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Memastikan controller langsung ter-load
    controller;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // Efek Cahaya Halus di Background
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.03),
              ),
            ),
          ),

          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)), // Animasi naik pelan
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo dengan Glow Premium
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.15),
                                blurRadius: 50,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppTheme.primary,
                            size: 80,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Nama App - Lebih Bold & Berjarak
                        const Text(
                          "SMARTALLO",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 12, // Kesan eksklusif
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Kalimat Welcome yang lebih Mengajak
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Column(
                            children: [
                              Text(
                                "Atur setiap rupiah, amankan setiap langkah.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Selamat datang di ekosistem alokasi pintarmu.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Indicator loading halus di bawah
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primary.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
