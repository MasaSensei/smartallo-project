import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/features/organization/controllers/organization_controller.dart';

// Import Mixins
import 'mixins/storage_manager.dart';
import 'mixins/pocket_manager.dart';
import 'mixins/category_manager.dart';

// Import Models
import '../../../data/models/storage_model.dart';
import '../../../data/models/pocket_model.dart';
import '../../../data/models/category_model.dart';

class ManagementController extends GetxController
    with StorageManager, PocketManager, CategoryManager {
  final orgCtrl = Get.find<OrganizationController>();
  String get _orgId => orgCtrl.selectedOrg.value?.id ?? "";
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (_orgId.isNotEmpty) fetchAllData();
    ever(orgCtrl.selectedOrg, (_) {
      if (_orgId.isNotEmpty) fetchAllData();
    });
  }

  Future<void> fetchAllData() async {
    if (_orgId.isEmpty) return;
    isLoading.value = true;
    try {
      await Future.wait([
        fetchStorages(_orgId),
        fetchPockets(_orgId),
        fetchCategories(_orgId),
      ]);
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // --- STORAGE ACTIONS ---
  Future<void> addStorage(String name, String type, double balance) async {
    final data = StorageModel(
      id: '',
      orgId: _orgId,
      name: name,
      type: type,
      balance: balance,
    );
    await _runTask(() => doAddStorage(data), "Storage created!");
  }

  Future<void> updateStorage(
    String id,
    String name,
    String type,
    double balance,
  ) async {
    final data = StorageModel(
      id: id,
      orgId: _orgId,
      name: name,
      type: type,
      balance: balance,
    );
    await _runTask(() => doUpdateStorage(id, data), "Storage updated!");
  }

  Future<void> deleteStorage(String id) async {
    await _runTask(
      () => doDeleteStorage(id),
      "Storage deleted!",
      isDelete: true,
    );
  }

  // --- POCKET ACTIONS ---
  Future<void> addPocket(
    String name,
    double alloc,
    double target,
    bool isMain,
  ) async {
    final data = PocketModel(
      id: '',
      orgId: _orgId,
      name: name,
      balance: 0,
      allocationRule: alloc, // Masukin alloc
      targetAmount: target, // Masukin target
      isMain: isMain, // Masukin isMain
      color: '#4285F4',
    );
    await _runTask(() => doAddPocket(data), "Pocket created!");
  }

  Future<void> updatePocket(
    String id,
    String name,
    double alloc,
    double target,
    double balance,
    bool isMain,
  ) async {
    final data = PocketModel(
      id: id,
      orgId: _orgId,
      name: name,
      balance: balance,
      allocationRule: alloc, // Masukin alloc
      targetAmount: target, // Masukin target
      isMain: isMain, // Masukin isMain
      color: '#4285F4',
    );
    await _runTask(() => doUpdatePocket(id, data), "Pocket updated!");
  }

  Future<void> deletePocket(String id) async {
    await _runTask(() => doDeletePocket(id), "Pocket deleted!", isDelete: true);
  }

  // --- CATEGORY ACTIONS ---
  Future<void> addCategory(String name, String type) async {
    final data = CategoryModel(id: '', orgId: _orgId, name: name, type: type);
    await _runTask(() => doAddCategory(data), "Category added!");
  }

  Future<void> updateCategory(String id, String name, String type) async {
    final data = CategoryModel(id: id, orgId: _orgId, name: name, type: type);
    await _runTask(() => doUpdateCategory(id, data), "Category updated!");
  }

  Future<void> deleteCategory(String id) async {
    await _runTask(
      () => doDeleteCategory(id),
      "Category deleted!",
      isDelete: true,
    );
  }

  // --- GLOBAL UI HELPERS ---
  Future<void> _runTask(
    Future Function() task,
    String msg, {
    bool isDelete = false,
  }) async {
    try {
      await task();
      await fetchAllData();
      if (!isDelete && Get.isBottomSheetOpen == true) Get.back();
      Get.snackbar(
        "Success",
        msg,
        backgroundColor: Colors.green.withOpacity(0.5),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(dynamic e) {
    Get.snackbar(
      "Error",
      e.toString().replaceAll("Exception: ", ""),
      backgroundColor: Colors.red.withOpacity(0.5),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
