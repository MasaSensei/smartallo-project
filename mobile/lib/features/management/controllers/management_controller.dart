// lib/app/modules/management/controllers/management_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/organization/controllers/organization_controller.dart';

class ManagementController extends GetxController {
  final _connect = GetConnect();
  final _storage = GetStorage();

  final orgCtrl = Get.find<OrganizationController>();
  String get _orgId => orgCtrl.selectedOrg.value?.id ?? "";

  var isLoading = false.obs;
  var rxPockets = <dynamic>[].obs;
  var rxCategories = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (_orgId.isNotEmpty) {
      fetchAllData();
    }

    ever(orgCtrl.selectedOrg, (_) {
      if (_orgId.isNotEmpty) fetchAllData();
    });
  }

  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${_storage.read('token')}',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<void> fetchAllData() async {
    if (_orgId.isEmpty) return;
    isLoading.value = true;
    try {
      await Future.wait([_fetchPockets(), _fetchCategories()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchPockets() async {
    final res = await _connect.get(
      "${ApiConstants.pockets}?org_id=$_orgId",
      headers: _headers,
    );
    if (res.status.isOk) rxPockets.assignAll(res.body['data'] ?? []);
  }

  Future<void> _fetchCategories() async {
    final res = await _connect.get(
      "${ApiConstants.categories}?org_id=$_orgId",
      headers: _headers,
    );
    if (res.status.isOk) rxCategories.assignAll(res.body['data'] ?? []);
  }

  // --- CRUD POCKET ---
  Future<void> addPocket(String name, double alloc, double target) async {
    final res = await _connect.post(ApiConstants.pockets, {
      'name': name,
      'allocation_rule': alloc,
      'target_amount': target,
      'org_id': _orgId,
    }, headers: _headers);

    _handleResponse(res, "Pocket created", _fetchPockets);
  }

  Future<void> updatePocket(
    dynamic id,
    String name,
    double alloc,
    double target,
  ) async {
    final res = await _connect.put("${ApiConstants.pockets}/$id", {
      'name': name,
      'allocation_rule': alloc,
      'target_amount': target,
      'org_id': _orgId,
    }, headers: _headers);

    _handleResponse(res, "Pocket updated", _fetchPockets);
  }

  Future<void> deletePocket(dynamic id) async {
    final res = await _connect.delete(
      "${ApiConstants.pockets}/$id",
      headers: _headers,
    );
    if (res.status.isOk) _fetchPockets();
  }

  // --- CRUD CATEGORY ---
  Future<void> addCategory(String name) async {
    final res = await _connect.post(ApiConstants.categories, {
      'name': name,
      'org_id': _orgId,
    }, headers: _headers);
    _handleResponse(res, "Category added", _fetchCategories);
  }

  Future<void> updateCategory(dynamic id, String name) async {
    final res = await _connect.put("${ApiConstants.categories}/$id", {
      'name': name,
      'org_id': _orgId,
    }, headers: _headers);
    _handleResponse(res, "Category updated", _fetchCategories);
  }

  Future<void> deleteCategory(dynamic id) async {
    final res = await _connect.delete(
      "${ApiConstants.categories}/$id",
      headers: _headers,
    );
    if (res.status.isOk) _fetchCategories();
  }

  void _handleResponse(Response res, String successMsg, Function refresh) {
    if (res.status.isOk) {
      refresh();
      Get.back();
      Get.snackbar(
        "Success",
        successMsg,
        backgroundColor: Colors.green.withOpacity(0.5),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Error",
        res.body['message'] ?? "Something went wrong",
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
    }
  }
}
