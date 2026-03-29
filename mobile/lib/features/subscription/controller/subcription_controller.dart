import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_theme.dart';

class SubscriptionController extends GetxController {
  var isLoading = false.obs;
  final storage = GetStorage();
  final _connect = GetConnect();

  final plans = <dynamic>[].obs;

  // Tambahkan ini untuk memantau tier user saat ini
  var currentTier = 'FREE'.obs;

  @override
  void onInit() {
    super.onInit();
    _connect.timeout = const Duration(seconds: 10);
    // Ambil tier dari storage yang disimpan pas Login
    currentTier.value = storage.read('user_tier') ?? 'FREE';
    fetchPlans();
  }

  Map<String, String> _getHeaders() {
    final token = storage.read('token');
    return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
  }

  Future<void> fetchPlans() async {
    try {
      isLoading.value = true;
      final response = await _connect.get(
        ApiConstants.subscriptionPlans,
        headers: _getHeaders(),
      );

      if (response.isOk) {
        final List? data = response.body;
        if (data != null) {
          plans.assignAll(data);
        }
      } else {
        _showError(response.body?['message'] ?? "Gagal mengambil paket.");
      }
    } catch (e) {
      _showError("Koneksi bermasalah!");
    } finally {
      isLoading.value = false;
    }
  }

  void activateSubscription(String planId, String tierName) async {
    try {
      isLoading.value = true;
      final response = await _connect.post(ApiConstants.subscribe, {
        "plan_id": planId,
      }, headers: _getHeaders());

      if (response.isOk) {
        // Update tier di lokal storage dan variable obs
        storage.write('user_tier', tierName);
        currentTier.value = tierName;

        Get.snackbar(
          "Sukses",
          "Yeay! Paket $tierName berhasil diaktifkan. Enjoy Bos!",
          backgroundColor: AppTheme.primary,
          colorText: Colors.white,
        );

        // Balik ke organization buat refresh view utama
        Get.offAllNamed('/organization');
      } else {
        _showError(response.body?['message'] ?? "Gagal memproses langganan.");
      }
    } catch (e) {
      _showError("Gagal terhubung ke server pembayaran.");
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      "Waduh!",
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
