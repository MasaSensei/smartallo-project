import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardController extends GetxController {
  // Data Reactive
  final rxPockets = <Map<String, dynamic>>[].obs;
  final rxTransactions = <Map<String, dynamic>>[].obs;
  final rxTotalBalance = 0.0.obs;
  final rxUserName = "Hasan Syafi'i".obs;
  final rxUserTier = "PREMIUM".obs;

  // Form States (Dropdown & Input)
  final rxPocketOptions = <String>[].obs;
  final rxCategoryOptions = <String>[].obs;
  final isIncome = true.obs;
  final selectedPocket = "".obs;
  final selectedCategory = "".obs;
  final amountController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
    _syncOptions();
  }

  // --- REVENUE LOGIC (Tambah Kategori/Kantong) ---

  void addCustomCategory(String name) {
    if (name.trim().isNotEmpty && !rxCategoryOptions.contains(name)) {
      rxCategoryOptions.add(name);
      selectedCategory.value = name;
    }
  }

  void addCustomPocket(String name) {
    if (name.trim().isNotEmpty && !rxPocketOptions.contains(name)) {
      rxPockets.add({"name": name, "balance": 0.0, "color": Colors.blueGrey});
      _syncOptions();
      selectedPocket.value = name;
    }
  }

  // --- DATA LOADING ---

  void _loadMockData() {
    rxPockets.assignAll([
      {
        "name": "Tabungan Nikah",
        "balance": 15000000.0,
        "color": AppTheme.primary,
      },
      {"name": "Dana Darurat", "balance": 5000000.0, "color": AppTheme.success},
      {"name": "Investasi", "balance": 2500000.0, "color": Colors.orange},
    ]);

    rxTransactions.assignAll([
      {
        "title": "Gaji Maret",
        "amount": 8500000.0,
        "type": "IN",
        "date": "Today",
      },
      {
        "title": "Kopi Starling",
        "amount": 15000.0,
        "type": "OUT",
        "date": "Today",
      },
    ]);

    rxCategoryOptions.assignAll([
      "Gaji",
      "Bonus",
      "Makan",
      "Transport",
      "Hobi",
    ]);
    _calculateTotal();
  }

  void _syncOptions() {
    rxPocketOptions.assignAll(
      rxPockets.map((e) => e['name'] as String).toList(),
    );

    // Set default selection kalau masih kosong
    if (rxPocketOptions.isNotEmpty && selectedPocket.value.isEmpty) {
      selectedPocket.value = rxPocketOptions.first;
    }
    if (rxCategoryOptions.isNotEmpty && selectedCategory.value.isEmpty) {
      selectedCategory.value = rxCategoryOptions.first;
    }
  }

  void _calculateTotal() {
    double total = 0.0;
    for (var pocket in rxPockets) {
      var balance = pocket['balance'];
      if (balance is num) total += balance.toDouble();
    }
    rxTotalBalance.value = total;
  }

  // --- CORE ACTION ---

  void saveTransaction() {
    if (amountController.text.isEmpty) return;
    double val = double.tryParse(amountController.text) ?? 0;

    // Cari index kantong yang dipilih
    int index = rxPockets.indexWhere((p) => p['name'] == selectedPocket.value);

    if (index != -1) {
      if (isIncome.value) {
        rxPockets[index]['balance'] += val;
      } else {
        // Cek saldo cukup atau nggak
        if (rxPockets[index]['balance'] < val) {
          Get.snackbar(
            "Saldo Kurang",
            "Duit di kantong '${selectedPocket.value}' nggak cukup, Bos!",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(15),
          );
          return;
        }
        rxPockets[index]['balance'] -= val;
      }

      // Masukin ke list transaksi (paling atas)
      rxTransactions.insert(0, {
        "title": selectedCategory.value,
        "amount": val,
        "type": isIncome.value ? "IN" : "OUT",
        "date": "Just now",
      });

      rxPockets.refresh();
      _calculateTotal();
      Get.back(); // Tutup BottomSheet
      amountController.clear(); // Reset input
    }
  }
}
