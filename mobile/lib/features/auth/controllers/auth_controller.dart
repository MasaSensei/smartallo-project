import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile/routes/app_routes.dart';
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

      if (response.isOk) {
        final token = response.body['data']['token'];
        final userData = response.body['data']['user'];

        await storage.write('token', token);
        await storage.write('user', userData);

        Get.offAllNamed(Routes.ORGANIZATION);
        _clearControllers();
      } else {
        // Updated: Pesan error login
        String msg = response.body?['message'] ?? "Invalid email or password!";
        _showError(msg);
      }
    } catch (e) {
      _showError("Connection failed. Please check your internet.");
    } finally {
      isLoading.value = false;
    }
  }

  void register() async {
    if (nameController.text.isEmpty) {
      _showError("Please enter your full name.");
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
        Get.back();
        Get.snackbar(
          "Success", // "Sukses"
          "Account for ${nameController.text} created! Please sign in.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _clearControllers();
      } else {
        // Updated: Pesan error register
        String msg =
            response.body?['message'] ??
            "Registration failed. Try another email.";
        _showError(msg);
      }
    } catch (e) {
      _showError("Failed to connect to server during registration.");
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate() {
    if (!GetUtils.isEmail(emailController.text)) {
      _showError("Please enter a valid email address.");
      return false;
    }
    if (passwordController.text.length < 6) {
      _showError("Password must be at least 6 characters!");
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
    Get.offAllNamed(Routes.LOGIN);
  }
}
