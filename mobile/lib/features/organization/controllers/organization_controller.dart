import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../data/models/organization_model.dart';

class OrganizationController extends GetxController {
  var isLoading = false.obs;
  var isCreating = false.obs;
  final storage = GetStorage();
  final _connect = GetConnect();

  final organizations = <OrganizationModel>[].obs;
  final selectedOrg = Rxn<OrganizationModel>();
  final orgNameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _connect.timeout = const Duration(seconds: 10);
    fetchWorkspaces();
  }

  Map<String, String> _getHeaders() {
    final token = storage.read('token');
    return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
  }

  Future<void> fetchWorkspaces() async {
    try {
      isLoading.value = true;
      final response = await _connect.get(
        ApiConstants.organizations,
        headers: _getHeaders(),
      );

      if (response.isOk) {
        final List? data = response.body['data'];
        if (data != null) {
          final list = data.map((e) => OrganizationModel.fromJson(e)).toList();
          organizations.assignAll(list);

          // Cek apakah ada ID yang tersimpan di storage sebelumnya
          final savedId = storage.read('active_org_id');
          if (savedId != null && organizations.any((o) => o.id == savedId)) {
            selectedOrg.value = organizations.firstWhere(
              (o) => o.id == savedId,
            );
          } else if (organizations.isNotEmpty) {
            selectedOrg.value = organizations.first;
          }
        }
      } else {
        organizations.clear();
        _showError(
          response.body?['message'] ?? "Gagal ambil daftar workspace.",
        );
      }
    } catch (e) {
      _showError("Koneksi ke server bermasalah!");
    } finally {
      isLoading.value = false;
    }
  }

  void createWorkspace() async {
    final name = orgNameController.text.trim();
    if (name.isEmpty) {
      _showError("Nama workspace jangan kosong!");
      return;
    }

    try {
      isCreating.value = true;
      final response = await _connect.post(ApiConstants.organizations, {
        "name": name,
      }, headers: _getHeaders());

      if (response.isOk) {
        Get.back();
        orgNameController.clear();
        Get.snackbar(
          "Sukses",
          "Workspace '$name' dibuat!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchWorkspaces();
      } else {
        _showError(response.body?['message'] ?? "Gagal membuat workspace.");
      }
    } catch (e) {
      _showError("Gagal terhubung ke server.");
    } finally {
      isCreating.value = false;
    }
  }

  void selectWorkspace(OrganizationModel org) {
    selectedOrg.value = org;
    storage.write('active_org_id', org.id);

    // Langsung pindah ke Dashboard setelah pilih
    Get.offAllNamed('/dashboard');
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

  @override
  void onClose() {
    orgNameController.dispose();
    super.onClose();
  }
}
