import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/features/dashboard/data/models/category_model.dart';
import 'package:mobile/features/dashboard/data/models/pocket_model.dart';
import 'package:mobile/features/dashboard/data/models/transaction_model.dart';
import '../../organization/controllers/organization_controller.dart';

import '../services/dashboard_service.dart';

class DashboardController extends GetxController {
  final orgCtrl = Get.find<OrganizationController>();

  // --- Observables (Strongly Typed) ---
  final rxPockets = <PocketModel>[].obs;
  final rxCategories = <CategoryModel>[].obs;
  final rxTransactions = <TransactionModel>[].obs;
  final isLoading = false.obs;

  // Chart Data
  final rxIncomeData = <double>[].obs;
  final rxExpenseData = <double>[].obs;
  final rxChartLabels = <String>[].obs;

  // Form State (Untuk BottomSheet Add Record)
  final rxPocketOptions = <String>[].obs;
  final rxCategoryOptions = <String>[].obs;
  final isIncome = true.obs;
  final selectedPocket = "".obs;
  final selectedCategory = "".obs;

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    // Otomatis refresh data kalau user ganti Workspace/Organization
    ever(orgCtrl.selectedOrg, (_) {
      fetchAllData();
      _syncChartData();
    });

    fetchAllData();
    _syncChartData();
  }

  /// Sinkronisasi semua data dari Service
  Future<void> fetchAllData() async {
    final orgId = orgCtrl.selectedOrg.value?.id;
    if (orgId == null) return;

    try {
      isLoading.value = true;

      // Ambil semua data secara paralel (lebih cepat)
      final results = await Future.wait([
        DashboardService.getPockets(orgId),
        DashboardService.getCategories(orgId),
        DashboardService.getTransactionHistory(orgId, limit: 5),
      ]);

      rxPockets.assignAll(results[0] as List<PocketModel>);
      rxCategories.assignAll(results[1] as List<CategoryModel>);
      rxTransactions.assignAll(results[2] as List<TransactionModel>);

      _syncPocketOptions();
      _syncCategoryOptions();
    } catch (e) {
      _showError("Gagal memuat data Dashboard.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Mapping data chart dari Organization Controller ke UI Dashboard
  void _syncChartData() {
    final chart = orgCtrl.selectedOrg.value?.weeklyChart;
    if (chart != null) {
      rxIncomeData.assignAll(chart.income);
      rxExpenseData.assignAll(chart.expense);
      rxChartLabels.assignAll(chart.labels);
    } else {
      rxIncomeData.assignAll(List.filled(7, 0.0));
      rxExpenseData.assignAll(List.filled(7, 0.0));
      rxChartLabels.assignAll(["M", "T", "W", "T", "F", "S", "S"]);
    }
  }

  // --- Form Logic ---

  void _syncPocketOptions() {
    if (rxPockets.isEmpty) return;
    final names = rxPockets.map((e) => e.name).toList();
    rxPocketOptions.assignAll(names);

    if (selectedPocket.value.isEmpty || !names.contains(selectedPocket.value)) {
      selectedPocket.value = names.first;
    }
  }

  void _syncCategoryOptions() {
    final typeFilter = isIncome.value ? "IN" : "OUT";
    final filtered =
        rxCategories
            .where((c) => c.type == typeFilter)
            .map((e) => e.name)
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
    final rawAmount = amountController.text.replaceAll('.', '').trim();
    final descText = descriptionController.text.trim();
    final orgId = orgCtrl.selectedOrg.value?.id;

    // Cari ID berdasarkan Nama yang dipilih di Dropdown
    final pocket = rxPockets.firstWhereOrNull(
      (p) => p.name == selectedPocket.value,
    );
    final category = rxCategories.firstWhereOrNull(
      (c) => c.name == selectedCategory.value,
    );

    if (pocket == null ||
        category == null ||
        orgId == null ||
        rawAmount.isEmpty) {
      _showError("Lengkapi semua data transaksi.");
      return;
    }

    try {
      isLoading.value = true;

      final success = await DashboardService.createTransaction({
        "org_id": orgId,
        "source_pocket_id": pocket.id,
        "category_id": category.id,
        "total_amount": int.parse(rawAmount),
        "type": isIncome.value ? "IN" : "OUT",
        "description": descText.isEmpty ? "Transaction via Mobile" : descText,
      });

      if (success) {
        Get.back(); // Tutup BottomSheet
        amountController.clear();
        descriptionController.clear();

        // Refresh data dashboard & update saldo di OrganizationController
        await fetchAllData();
        await orgCtrl.syncSelectedOrgDetails(orgId);

        _showSuccess("Transaksi berhasil dicatat.");
      } else {
        _showError("Gagal menyimpan transaksi.");
      }
    } catch (e) {
      _showError("Terjadi kesalahan sistem.");
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  // --- Quick Add Methods (Optional) ---

  Future<void> addCustomPocket(String name) async {
    final orgId = orgCtrl.selectedOrg.value?.id;
    if (orgId == null || name.isEmpty) return;

    // Kamu bisa buatkan method khusus di DashboardService untuk ini
    // Untuk sementara kita biarkan logic fetchAllData dipanggil setelah sukses
    await fetchAllData();
  }

  // TAMBAHKAN METHOD INI YANG HILANG:
  Future<void> addCustomCategory(String name) async {
    final orgId = orgCtrl.selectedOrg.value?.id;
    if (orgId == null || name.isEmpty) return;

    // Logic: Panggil DashboardService untuk create category
    // Untuk sekarang kita panggil fetch ulang supaya list terupdate
    await fetchAllData();

    // Otomatis pilih kategori yang baru dibuat
    selectedCategory.value = name;
  }

  // --- Feedback Helpers ---

  void _showSuccess(String msg) => Get.snackbar(
    "Berhasil",
    msg,
    backgroundColor: Colors.green,
    colorText: Colors.white,
    snackPosition: SnackPosition.TOP,
  );

  void _showError(String msg) => Get.snackbar(
    "Oops!",
    msg,
    backgroundColor: Colors.redAccent,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
  );

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
