import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/api_constants.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  final storage = GetStorage();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  final _connect = GetConnect();

  void login() async {
    if (!_validate()) return;

    try {
      isLoading.value = true;

      final response = await _connect.post(ApiConstants.login, {
        "email": emailController.text.trim(),
        "password": passwordController.text,
      });

      // FIX: Pakai .isOk (milik instance Response)
      if (response.isOk) {
        final token = response.body['data']['token'];
        final userData = response.body['data']['user'];

        await storage.write('token', token);
        await storage.write('user', userData);

        Get.offAllNamed('/organization');
        _clearControllers();
      } else {
        // Handle error message dari backend
        String msg = response.body?['message'] ?? "Email atau Password salah!";
        _showError(msg);
      }
    } catch (e) {
      _showError("Server lagi rewel, Bos. Cek koneksi!");
    } finally {
      isLoading.value = false;
    }
  }

  void register() async {
    if (nameController.text.isEmpty) {
      _showError("Username jangan kosong, Bos!");
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

      // FIX: Pakai .isOk juga di sini
      if (response.isOk) {
        Get.back();
        Get.snackbar(
          "Sukses",
          "Akun ${nameController.text} berhasil dibuat! Silakan login.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _clearControllers();
      } else {
        String msg =
            response.body?['message'] ?? "Gagal daftar, coba email lain.";
        _showError(msg);
      }
    } catch (e) {
      _showError("Gagal konek ke server pas daftar.");
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate() {
    if (!GetUtils.isEmail(emailController.text)) {
      _showError("Format email salah!");
      return false;
    }
    if (passwordController.text.length < 6) {
      _showError("Password minimal 6 karakter!");
      return false;
    }
    return true;
  }

  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _clearControllers() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
  }

  void logout() {
    storage.erase();
    Get.offAllNamed('/login');
  }
}
