import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../domain/repositories/organization_repository.dart';
import '../../../data/models/organization_model.dart';
import '../../../routes/app_routes.dart';

class OrganizationController extends GetxController {
  final OrganizationRepository repository;
  final storage = GetStorage();

  OrganizationController({required this.repository});

  // States
  var isLoading = false.obs;
  var isCreating = false.obs;
  var organizations = <OrganizationModel>[].obs;
  var selectedOrg = Rxn<OrganizationModel>();
  var currentTier = 'FREE'.obs;

  final orgNameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    currentTier.value = storage.read('user_tier') ?? 'FREE';
    fetchWorkspaces();
  }

  /// Ambil semua list workspace
  Future<void> fetchWorkspaces() async {
    try {
      isLoading.value = true;
      final result = await repository.getAll();
      organizations.assignAll(result);
      _handleAutoSelect();
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// REFRESH DETAIL: Sinkronisasi saldo/chart workspace tertentu
  Future<void> syncSelectedOrgDetails(String id) async {
    try {
      // Ambil data terbaru dari API
      final updatedOrg = await repository.getDetail(id);

      // Update di list utama
      int index = organizations.indexWhere((element) => element.id == id);
      if (index != -1) {
        organizations[index] = updatedOrg;
      }

      // Jika yang di-update adalah yang sedang dipilih user, update RX-nya
      if (selectedOrg.value?.id == id) {
        selectedOrg.value = updatedOrg;
        selectedOrg.refresh();
      }
    } catch (e) {
      print("Silent error syncing org: $e");
    }
  }

  void _handleAutoSelect() {
    final savedId = storage.read('active_org_id');
    if (savedId != null && organizations.any((o) => o.id == savedId)) {
      selectedOrg.value = organizations.firstWhere((o) => o.id == savedId);
    } else if (organizations.isNotEmpty) {
      selectedOrg.value = organizations.first;
    }
  }

  /// Pilih Workspace dan arahkan ke Dashboard
  void selectWorkspace(OrganizationModel org) {
    selectedOrg.value = org;
    storage.write('active_org_id', org.id);

    // Gunakan offAll kalau baru login/ganti total,
    // tapi kalau cuma update data bisa pakai logic lain.
    if (Get.currentRoute != Routes.DASHBOARD) {
      Get.offAllNamed(Routes.DASHBOARD);
    }
  }

  Future<void> createWorkspace() async {
    final name = orgNameController.text.trim();
    if (name.isEmpty) return;

    try {
      isCreating.value = true;
      await repository.create(name);

      Get.back();
      orgNameController.clear();
      Get.snackbar(
        "Sukses",
        "Workspace '$name' berhasil dibuat! ✨",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await fetchWorkspaces();
    } catch (e) {
      _showError(e.toString());
    } finally {
      isCreating.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      "Ups!",
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
