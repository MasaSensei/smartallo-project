import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/data/models/category_model.dart';
import 'package:mobile/data/models/pocket_model.dart';
import 'package:mobile/data/models/transaction_model.dart';
import '../../../domain/repositories/dashboard_repository.dart';
import '../../organization/controllers/organization_controller.dart';

class DashboardController extends GetxController {
  final DashboardRepository repository;
  final orgCtrl = Get.find<OrganizationController>();

  DashboardController({required this.repository});

  // --- DATA STATES ---
  final rxPockets = <PocketModel>[].obs;
  final rxCategories = <CategoryModel>[].obs;
  final rxTransactions = <TransactionModel>[].obs;
  final isLoading = false.obs;

  // --- CHART DATA ---
  final rxIncomeData = <double>[].obs;
  final rxExpenseData = <double>[].obs;
  final rxChartLabels = <String>[].obs;

  // --- FORM STATES (Sesuai dengan UI Sheet) ---
  final isIncome = false.obs;
  final selectedPocket = "".obs; // Untuk Dropdown UI
  final selectedCategory = "".obs; // Untuk Dropdown UI
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  // --- GETTERS UNTUK UI ---
  List<String> get rxPocketOptions => rxPockets.map((e) => e.name).toList();

  List<String> get rxCategoryOptions =>
      rxCategories
          .where((c) => c.type == (isIncome.value ? "IN" : "OUT"))
          .map((e) => e.name)
          .toList();

  @override
  void onInit() {
    super.onInit();
    ever(orgCtrl.selectedOrg, (_) => fetchAllData());
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    final orgId = orgCtrl.selectedOrg.value?.id;
    if (orgId == null) return;

    try {
      isLoading.value = true;
      final results = await Future.wait([
        repository
            .getPockets(), // Backend pake middleware, orgId gak wajib dikirim via param
        repository.getCategories(),
        repository.getHistory(limit: 15),
      ]);

      rxPockets.assignAll(results[0] as List<PocketModel>);
      rxCategories.assignAll(results[1] as List<CategoryModel>);
      rxTransactions.assignAll(results[2] as List<TransactionModel>);

      _syncDefaultValues();
      _syncChartData();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _syncDefaultValues() {
    // Set default pocket kalau kosong
    if (rxPockets.isNotEmpty && selectedPocket.value.isEmpty) {
      selectedPocket.value = rxPockets.first.name;
    }

    // Set default category berdasarkan tipe
    final typeFilter = isIncome.value ? "IN" : "OUT";
    final first = rxCategories.firstWhereOrNull((c) => c.type == typeFilter);
    if (first != null) selectedCategory.value = first.name;
  }

  void _syncChartData() {
    final chart = orgCtrl.selectedOrg.value?.weeklyChart;
    if (chart != null) {
      rxIncomeData.assignAll(chart.income);
      rxExpenseData.assignAll(chart.expense);
      rxChartLabels.assignAll(chart.labels);
    }
  }

  void setTransactionType(bool val) {
    isIncome.value = val;
    _syncDefaultValues();
  }

  // --- HANDLERS DIALOG "ADD NEW" ---
  void addCustomPocket(String name) => selectedPocket.value = name;
  void addCustomCategory(String name) => selectedCategory.value = name;

  Future<void> saveTransaction() async {
    final amount = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (amount.isEmpty || selectedCategory.value.isEmpty) {
      Get.snackbar("Info", "Nominal dan Kategori wajib diisi");
      return;
    }

    // Mapping Nama ke ID
    final pocketObj = rxPockets.firstWhereOrNull(
      (p) => p.name == selectedPocket.value,
    );
    final categoryObj = rxCategories.firstWhereOrNull(
      (c) => c.name == selectedCategory.value,
    );

    try {
      isLoading.value = true;

      // Kirim model ke repository
      final success = await repository.createTransaction(
        TransactionModel(
          sourcePocketId:
              pocketObj?.id ?? (rxPockets.isNotEmpty ? rxPockets.first.id : ""),
          categoryId: categoryObj?.id ?? "",
          totalAmount: int.parse(amount),
          type: isIncome.value ? "IN" : "OUT",
          description: descriptionController.text,
        ),
      );

      if (success) {
        Get.back();
        amountController.clear();
        descriptionController.clear();
        await fetchAllData();
        await orgCtrl.syncSelectedOrgDetails(orgCtrl.selectedOrg.value!.id);
      }
    } catch (e) {
      Get.snackbar("Gagal", e.toString(), backgroundColor: Colors.redAccent);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
