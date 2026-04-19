import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/routes/app_routes.dart';
import '../../../domain/repositories/auth_repository.dart'; // Import Repository Interface

class AuthController extends GetxController {
  // 1. Ambil instance Repository via Dependency Injection
  final AuthRepository repository;

  // 2. Ambil instance AuthService untuk session management
  final AuthService _authService = Get.find<AuthService>();

  // Constructor untuk menerima repository dari Binding
  AuthController({required this.repository});

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  // --- LOGIN ---
  void login() async {
    if (!_validate()) return;

    try {
      isLoading.value = true;

      // Panggil Repository (Gak perlu post manual lagi di sini)
      final data = await repository.login(
        emailController.text.trim(),
        passwordController.text,
      );

      // Simpan session via Service
      await _authService.saveAuth(data['token'], data['user']);

      Get.offAllNamed(Routes.ORGANIZATION);
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- REGISTER ---
  void register() async {
    if (nameController.text.isEmpty) {
      _showError("Silakan masukkan nama lengkap.");
      return;
    }
    if (!_validate()) return;

    try {
      isLoading.value = true;

      // Panggil Repository
      final success = await repository.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );

      if (success) {
        Get.back();
        Get.snackbar(
          "Sukses",
          "Akun ${nameController.text} berhasil dibuat! Silakan masuk.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        _clearControllers();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGOUT ---
  void logout() {
    _authService.clearAuth();
    Get.offAllNamed(Routes.LOGIN);
  }

  // --- UTILS ---
  void togglePasswordVisibility() => isPasswordVisible.toggle();

  bool _validate() {
    if (!GetUtils.isEmail(emailController.text)) {
      _showError("Format email tidak valid.");
      return false;
    }
    if (passwordController.text.length < 6) {
      _showError("Password minimal harus 6 karakter!");
      return false;
    }
    return true;
  }

  void _showError(String message) {
    String friendlyMessage = message;
    if (message.contains("pq:") ||
        message.contains("500") ||
        message.contains("connection")) {
      friendlyMessage =
          "Waduh, server kami sedang istirahat sejenak. Coba lagi ya! ✨";
    }

    Get.snackbar(
      "Ups!",
      friendlyMessage,
      backgroundColor: AppTheme.danger.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(15),
      borderRadius: 20,
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
    );
  }

  void _clearControllers() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
  }
}
