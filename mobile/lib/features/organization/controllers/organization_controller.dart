import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/organization_service.dart';
import '../data/models/organization_model.dart';

class OrganizationController extends GetxController {
  var isLoading = false.obs;
  var isCreating = false.obs;
  final storage = GetStorage();

  final organizations = <OrganizationModel>[].obs;
  final selectedOrg = Rxn<OrganizationModel>();
  final orgNameController = TextEditingController();
  var currentTier = 'FREE'.obs;

  @override
  void onInit() {
    super.onInit();
    currentTier.value = storage.read('user_tier') ?? 'FREE';
    fetchWorkspaces();
  }

  Future<void> fetchWorkspaces() async {
    try {
      isLoading.value = true;
      final result = await OrganizationService.fetchAll();

      if (result != null) {
        final List? data = result['data'];

        if (data != null) {
          final list = data.map((e) => OrganizationModel.fromJson(e)).toList();
          organizations.assignAll(list);
          _handleAutoSelect();
        }

        // Update Tier dari Storage saja dulu kalau BE belum kirim di List
        currentTier.value = storage.read('user_tier') ?? 'FREE';
      }
    } catch (e) {
      print("Error fetch: $e"); // Biar ketahuan kalau mapping Model gagal
    } finally {
      isLoading.value = false;
    }
  }

  void _handleAutoSelect() {
    final savedId = storage.read('active_org_id');
    if (savedId != null && organizations.any((o) => o.id == savedId)) {
      selectedOrg.value = organizations.firstWhere((o) => o.id == savedId);
    } else if (organizations.isNotEmpty) {
      selectedOrg.value = organizations.first;
    }

    if (selectedOrg.value != null) {
      syncSelectedOrgDetails(selectedOrg.value!.id);
    }
  }

  Future<void> syncSelectedOrgDetails(String orgId) async {
    // Panggil service yang nembak endpoint detail
    final detail = await OrganizationService.getDetail(orgId);

    if (detail != null) {
      int index = organizations.indexWhere((o) => o.id == orgId);
      if (index != -1) {
        organizations[index] = detail; // Update list biar saldo berubah
      }
      if (selectedOrg.value?.id == orgId) {
        selectedOrg.value = detail; // Update state yang lagi dipake
      }
    }
  }

  void selectWorkspace(OrganizationModel org) async {
    selectedOrg.value = org;
    storage.write('active_org_id', org.id);
    await syncSelectedOrgDetails(org.id);
    Get.offAllNamed('/dashboard');
  }

  Future<void> createWorkspace() async {
    final name = orgNameController.text.trim();
    if (name.isEmpty) {
      _showError("Workspace name cannot be empty!");
      return;
    }

    try {
      isCreating.value = true;
      final result = await OrganizationService.create(name);

      if (result != null && result['success'] == true) {
        Get.back();
        orgNameController.clear();
        Get.snackbar(
          "Success",
          "Workspace '$name' created!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchWorkspaces();
      } else {
        _showError(result?['message'] ?? "Failed to create workspace.");
      }
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
