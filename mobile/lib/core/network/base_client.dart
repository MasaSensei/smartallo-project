import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:mobile/features/auth/services/auth_service.dart';

class BaseClient {
  static AuthService get _auth => Get.find<AuthService>();

  // Helper untuk Header (Otomatis sisipkan Token)
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_auth.token != null) 'Authorization': 'Bearer ${_auth.token}',
    };
  }

  // --- GET REQUEST ---
  static Future<http.Response?> get(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: _getHeaders());
      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // --- POST REQUEST ---
  static Future<http.Response?> post(String url, dynamic body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // --- THE LOGIC: SATPAM 401 ---
  static http.Response? _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      print("Sesi Berakhir (401)! Database di-reset atau Token Invalid.");

      // Hapus data lokal & tendang ke Login
      _auth.clearAuth();
      Get.offAllNamed('/login');

      Get.snackbar(
        "Sesi Berakhir",
        "Silakan login kembali demi keamanan data.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
    return response;
  }

  static void _handleError(dynamic error) {
    print("Network Error: $error");
    Get.snackbar("Error", "Gagal terhubung ke server SmartAllo.");
  }
}
