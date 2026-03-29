import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../organization/controllers/organization_controller.dart';

class DashboardController extends GetxController {
  final storage = GetStorage();
  final _connect = GetConnect();
  final orgCtrl = Get.find<OrganizationController>();

  // --- Observables (Typed) ---
  final rxPockets =
      <dynamic>[].obs; // Replace dynamic with PocketModel if you have it
  final rxCategories = <dynamic>[].obs;
  final rxTransactions = <dynamic>[].obs;
  final isLoading = false.obs;

  // Chart Data
  final rxIncomeData = <double>[].obs;
  final rxExpenseData = <double>[].obs;
  final rxChartLabels = <String>[].obs;

  // Form State
  final rxPocketOptions = <String>[].obs;
  final rxCategoryOptions = <String>[].obs;
  final isIncome = true.obs;
  final selectedPocket = "".obs;
  final selectedCategory = "".obs;
  final amountController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _connect.timeout = const Duration(seconds: 10);

    // Trigger data fetch whenever the selected organization changes
    ever(orgCtrl.selectedOrg, (_) {
      fetchAllData();
      _syncChartData();
    });

    fetchAllData();
    _syncChartData();
  }

  /// Refreshes all dashboard data from the API
  Future<void> fetchAllData() async {
    final orgId = orgCtrl.selectedOrg.value?.id;
    if (orgId == null) return;

    try {
      isLoading.value = true;
      final headers = {'Authorization': 'Bearer ${storage.read('token')}'};

      final responses = await Future.wait([
        _connect.get("${ApiConstants.pockets}?org_id=$orgId", headers: headers),
        _connect.get(
          "${ApiConstants.categories}?org_id=$orgId",
          headers: headers,
        ),
        _connect.get(
          "${ApiConstants.transactionHistory}?org_id=$orgId",
          headers: headers,
        ),
      ]);

      if (responses[0].isOk) {
        rxPockets.assignAll(responses[0].body['data'] ?? []);
        _syncPocketOptions();
      }

      if (responses[1].isOk) {
        rxCategories.assignAll(responses[1].body['data'] ?? []);
        _syncCategoryOptions();
      }

      if (responses[2].isOk) {
        rxTransactions.assignAll(responses[2].body['data'] ?? []);
      }
    } catch (e) {
      _showError("Failed to load dashboard data.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Maps the WeeklyChart data from OrganizationModel to local UI observables
  void _syncChartData() {
    final chart = orgCtrl.selectedOrg.value?.weeklyChart;
    if (chart != null) {
      rxIncomeData.assignAll(chart.income);
      rxExpenseData.assignAll(chart.expense);
      rxChartLabels.assignAll(chart.labels);
    } else {
      // Default empty state (7 days)
      rxIncomeData.assignAll(List.filled(7, 0.0));
      rxExpenseData.assignAll(List.filled(7, 0.0));
      rxChartLabels.assignAll(["M", "T", "W", "T", "F", "S", "S"]);
    }
  }

  // --- Form Logic ---

  void _syncPocketOptions() {
    if (rxPockets.isEmpty) return;
    final names = rxPockets.map((e) => e['name'].toString()).toList();
    rxPocketOptions.assignAll(names);
    if (selectedPocket.value.isEmpty || !names.contains(selectedPocket.value)) {
      selectedPocket.value = names.first;
    }
  }

  void _syncCategoryOptions() {
    final typeFilter = isIncome.value ? "IN" : "OUT";
    final filtered =
        rxCategories
            .where((c) => c['type'] == typeFilter)
            .map((e) => e['name'].toString())
            .toList();
    rxCategoryOptions.assignAll(filtered);
    if (filtered.isNotEmpty) selectedCategory.value = filtered.first;
  }

  void setTransactionType(bool val) {
    isIncome.value = val;
    _syncCategoryOptions();
  }

  // --- Actions ---

  Future<void> saveTransaction() async {
    final amountText = amountController.text.trim();
    final orgId = orgCtrl.selectedOrg.value?.id;

    final pocket = rxPockets.firstWhere(
      (p) => p['name'] == selectedPocket.value,
      orElse: () => null,
    );
    final category = rxCategories.firstWhere(
      (c) => c['name'] == selectedCategory.value,
      orElse: () => null,
    );

    if (pocket == null ||
        category == null ||
        amountText.isEmpty ||
        orgId == null) {
      _showError("Please complete all fields.");
      return;
    }

    try {
      isLoading.value = true;
      final response = await _connect.post(
        ApiConstants.transactions,
        {
          "org_id": orgId,
          "pocket_id": pocket['id'],
          "category_id": category['id'],
          "total_amount": amountText,
          "type": isIncome.value ? "IN" : "OUT",
          "description": "Mobile Input",
        },
        headers: {'Authorization': 'Bearer ${storage.read('token')}'},
      );

      if (response.isOk) {
        Get.back();
        amountController.clear();

        // Refresh everything: dashboard data + organization balance/chart
        await Future.wait([
          fetchAllData(),
          orgCtrl.syncSelectedOrgDetails(orgId),
        ]);

        _showSuccess("Transaction recorded.");
      } else {
        _showError(response.body?['message'] ?? "Save failed.");
      }
    } finally {
      isLoading.value = false;
    }
  }

  // --- Dynamic Add Methods ---

  Future<void> addCustomPocket(String name) async {
    final orgId = orgCtrl.selectedOrg.value?.id;
    if (orgId == null || name.isEmpty) return;

    final response = await _connect.post(
      ApiConstants.pockets,
      {"org_id": orgId, "name": name, "balance": 0, "color": "#4285F4"},
      headers: {'Authorization': 'Bearer ${storage.read('token')}'},
    );

    if (response.isOk) {
      await fetchAllData();
      selectedPocket.value = name;
    }
  }

  Future<void> addCustomCategory(String name) async {
    final orgId = orgCtrl.selectedOrg.value?.id;
    if (orgId == null || name.isEmpty) return;

    final response = await _connect.post(
      ApiConstants.categories,
      {"org_id": orgId, "name": name, "type": isIncome.value ? "IN" : "OUT"},
      headers: {'Authorization': 'Bearer ${storage.read('token')}'},
    );

    if (response.isOk) {
      await fetchAllData();
      selectedCategory.value = name;
    }
  }

  // --- Feedback ---

  void _showSuccess(String msg) => Get.snackbar(
    "Success",
    msg,
    backgroundColor: Colors.green,
    colorText: Colors.white,
  );

  void _showError(String msg) => Get.snackbar(
    "Error",
    msg,
    backgroundColor: Colors.redAccent,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
  );

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
