import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/base_input.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(leading: const BackButton(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Atur Uangmu Lebih Rapi 💰",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Mulai pisahkan keuanganmu jadi lebih terkontrol.",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 40),

            BaseInput(
              controller: controller.nameController,
              label: "Nama Lengkap",
              hint: "Hasan Syafi'i",
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 20),
            BaseInput(
              controller: controller.emailController,
              label: "Email",
              hint: "hasan@dev.com",
              icon: Icons.alternate_email_rounded,
            ),
            const SizedBox(height: 20),
            Obx(
              () => BaseInput(
                controller: controller.passwordController,
                label: "Password",
                hint: "••••••••",
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: !controller.isPasswordVisible.value,
                onToggleVisibility: () => controller.isPasswordVisible.toggle(),
              ),
            ),

            const SizedBox(height: 40),

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
                  ),
                  onPressed:
                      controller.isLoading.value
                          ? null
                          : () => controller.register(),
                  child:
                      controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Daftar Sekarang",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
