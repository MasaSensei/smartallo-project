import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/routes/app_routes.dart';
import '../../../../core/constants/api_constants.dart';

class AuthController extends GetxController {
  // Ambil instance AuthService yang sudah di-init di main.dart
  final AuthService _authService = Get.find<AuthService>();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  final _connect = GetConnect();

  // Menangani alur login
  void login() async {
    if (!_validate()) return;

    try {
      isLoading.value = true;

      final response = await _connect.post(ApiConstants.login, {
        "email": emailController.text.trim(),
        "password": passwordController.text,
      });

      if (response.isOk) {
        final token = response.body['data']['token'];
        final userData = response.body['data']['user'];

        await _authService.saveAuth(token, userData);

        // Get.offAllNamed akan menghancurkan controller ini,
        // jadi tidak perlu clear manual di sini.
        Get.offAllNamed(Routes.ORGANIZATION);
      } else {
        String msg = response.body?['message'] ?? "Email atau password salah!";
        _showError(msg);
      }
    } catch (e) {
      _showError("Gagal terhubung ke server. Periksa koneksi internet.");
    } finally {
      isLoading.value = false;
    }
  }

  // Menangani alur registrasi
  void register() async {
    if (nameController.text.isEmpty) {
      _showError("Silakan masukkan nama lengkap.");
      return;
    }
    if (!_validate()) return;

    try {
      isLoading.value = true;

      final response = await _connect.post(ApiConstants.register, {
        "username": nameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text,
      });

      if (response.isOk) {
        // Kembali ke halaman Login
        Get.back();
        Get.snackbar(
          "Sukses",
          "Akun ${nameController.text} berhasil dibuat! Silakan masuk.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        _clearControllers();
      } else {
        String msg =
            response.body?['message'] ?? "Registrasi gagal. Coba email lain.";
        _showError(msg);
      }
    } catch (e) {
      _showError("Terjadi kesalahan saat mendaftar.");
    } finally {
      isLoading.value = false;
    }
  }

  // Logout menggunakan Service
  void logout() {
    _authService.clearAuth();
    Get.offAllNamed(Routes.LOGIN);
  }

  // Toggle mata pada password field
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Validasi input sederhana
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

    // Jika pesan mengandung bau-bau database (pq, sql, dll)
    if (message.contains("pq:") ||
        message.contains("server error") ||
        message.contains("500")) {
      friendlyMessage =
          "Waduh, server kami sedang istirahat sejenak. Coba lagi ya! ✨";
    }

    Get.snackbar(
      "Ups!",
      friendlyMessage,
      backgroundColor: AppTheme.danger.withOpacity(
        0.9,
      ), // Pakai warna merah Ai Hoshino
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(15),
      borderRadius: 20, // Tetap imut
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
    );
  }

  void _clearControllers() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
  }

  @override
  void onClose() {
    // Bersihkan memory controller saat tidak digunakan
    // emailController.dispose();
    // passwordController.dispose();
    // nameController.dispose();
    super.onClose();
  }
}
