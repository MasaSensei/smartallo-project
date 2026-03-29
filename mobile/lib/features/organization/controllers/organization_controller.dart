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
  var currentTier = 'FREE'.obs;

  @override
  void onInit() {
    super.onInit();
    _connect.timeout = const Duration(seconds: 10);
    currentTier.value = storage.read('user_tier') ?? 'FREE';
    fetchWorkspaces();
  }

  Map<String, String> _getHeaders() {
    return {
      'Authorization': 'Bearer ${storage.read('token')}',
      'Accept': 'application/json',
    };
  }

  Future<void> fetchWorkspaces() async {
    try {
      isLoading.value = true;
      final response = await _connect.get(
        ApiConstants.organizations,
        headers: _getHeaders(),
      );

      if (response.isOk) {
        // 1. Sync Tier
        if (response.body['tier'] != null) {
          currentTier.value = response.body['tier'];
          storage.write('user_tier', currentTier.value);
        }

        // 2. Map List
        final List? data = response.body['data'];
        if (data != null) {
          final list = data.map((e) => OrganizationModel.fromJson(e)).toList();
          organizations.assignAll(list);

          // 3. Auto Select Workspace terakhir
          final savedId = storage.read('active_org_id');
          if (savedId != null && organizations.any((o) => o.id == savedId)) {
            selectedOrg.value = organizations.firstWhere(
              (o) => o.id == savedId,
            );
          } else if (organizations.isNotEmpty) {
            selectedOrg.value = organizations.first;
          }

          // 4. Sync detail saldo untuk org yang terpilih
          if (selectedOrg.value != null) {
            syncSelectedOrgDetails(selectedOrg.value!.id);
          }
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi sakti untuk ambil detail saldo terbaru dari Go
  Future<void> syncSelectedOrgDetails(String orgId) async {
    try {
      final response = await _connect.get(
        "${ApiConstants.organizations}/$orgId",
        headers: _getHeaders(),
      );
      if (response.isOk) {
        final detail = OrganizationModel.fromJson(response.body['data']);
        // Update data di list dan selected variable
        int index = organizations.indexWhere((o) => o.id == orgId);
        if (index != -1) organizations[index] = detail;
        if (selectedOrg.value?.id == orgId) {
          selectedOrg.value = detail;
        }
      }
    } catch (e) {
      print("Sync detail failed: $e");
    }
  }

  void selectWorkspace(OrganizationModel org) async {
    selectedOrg.value = org;
    storage.write('active_org_id', org.id);

    // Sebelum pindah, pastikan data saldo terbaru ditarik
    await syncSelectedOrgDetails(org.id);

    Get.offAllNamed('/dashboard');
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
