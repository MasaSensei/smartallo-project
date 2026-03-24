import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/base_input.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const Text(
                "Siap Atur Uangmu Lagi?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Masuk untuk melanjutkan pengelolaan keuanganmu.",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 48),

              // Input Email
              BaseInput(
                controller: controller.emailController,
                label: "Email",
                hint: "hasan@dev.com",
                icon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 24),

              // Input Password
              Obx(
                () => BaseInput(
                  controller: controller.passwordController,
                  label: "Password",
                  hint: "••••••••",
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  obscureText: !controller.isPasswordVisible.value,
                  onToggleVisibility:
                      () => controller.isPasswordVisible.toggle(),
                ),
              ),

              const SizedBox(height: 32),

              // Button Login
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed:
                        controller.isLoading.value
                            ? null
                            : () => controller.login(),
                    child:
                        controller.isLoading.value
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              "Masuk",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Belum punya akun?",
                    style: TextStyle(color: Colors.white54),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/register'),
                    child: const Text(
                      "Daftar",
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
