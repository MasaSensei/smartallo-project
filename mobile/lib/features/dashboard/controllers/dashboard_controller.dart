import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../organization/controllers/organization_controller.dart';

class DashboardController extends GetxController {
  final storage = GetStorage();
  final _connect = GetConnect();

  // Ambil instance OrganizationController yang sudah permanent
  final orgCtrl = Get.find<OrganizationController>();

  // --- DATA REAKSIF ---
  final rxPockets = <dynamic>[].obs;
  final rxTransactions = <dynamic>[].obs;
  final isLoading = false.obs;

  // Form States (Untuk BottomSheet Tambah Transaksi)
  final rxPocketOptions = <String>[].obs;
  final rxCategoryOptions = <String>[].obs;
  final isIncome = true.obs;
  final selectedPocket = "".obs;
  final selectedCategory = "".obs;
  final amountController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    // 1. Dengerin perubahan Workspace.
    // Kalau selectedOrg berubah, otomatis re-fetch data dashboard.
    ever(orgCtrl.selectedOrg, (_) => fetchAllData());

    // 2. Load data pertama kali
    fetchAllData();

    // 3. Mock Kategori (Nanti bisa ditarik dari API juga)
    rxCategoryOptions.assignAll([
      "Gaji",
      "Bonus",
      "Makan",
      "Transport",
      "Hobi",
    ]);
  }

  // --- CORE DATA FETCHING ---

  Future<void> fetchAllData() async {
    final orgId = orgCtrl.selectedOrg.value?.id;
    if (orgId == null) return;

    try {
      isLoading.value = true;
      final token = storage.read('token');
      final headers = {'Authorization': 'Bearer $token'};

      // Kita tarik data Kantong dan History Transaksi secara paralel
      final responses = await Future.wait([
        _connect.get("${ApiConstants.pockets}?org_id=$orgId", headers: headers),
        _connect.get(
          "${ApiConstants.transactionHistory}?org_id=$orgId",
          headers: headers,
        ),
      ]);

      final pocketRes = responses[0];
      final transRes = responses[1];

      if (pocketRes.isOk) {
        rxPockets.assignAll(pocketRes.body['data'] ?? []);
        _syncPocketOptions();
      }

      if (transRes.isOk) {
        rxTransactions.assignAll(transRes.body['data'] ?? []);
      }
    } catch (e) {
      _showError("Gagal sinkronisasi data, Bos!");
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIC HELPER ---

  void _syncPocketOptions() {
    rxPocketOptions.assignAll(
      rxPockets.map((e) => e['name'].toString()).toList(),
    );
    if (rxPocketOptions.isNotEmpty) {
      selectedPocket.value = rxPocketOptions.first;
    }
    if (rxCategoryOptions.isNotEmpty) {
      selectedCategory.value = rxCategoryOptions.first;
    }
  }

  // --- CORE ACTION: SAVE TO DATABASE ---

  Future<void> saveTransaction() async {
    if (amountController.text.isEmpty) return;
    final orgId = orgCtrl.selectedOrg.value?.id;

    // Cari pocket_id berdasarkan nama yang dipilih di dropdown
    final pocket = rxPockets.firstWhere(
      (p) => p['name'] == selectedPocket.value,
    );

    try {
      isLoading.value = true;
      final response = await _connect.post(
        ApiConstants.transactions,
        {
          "org_id": orgId,
          "pocket_id": pocket['id'],
          "category": selectedCategory.value,
          "amount": double.tryParse(amountController.text) ?? 0,
          "type": isIncome.value ? "IN" : "OUT",
          "notes": "Input via Mobile",
        },
        headers: {'Authorization': 'Bearer ${storage.read('token')}'},
      );

      if (response.isOk) {
        Get.back(); // Tutup BottomSheet
        amountController.clear();
        Get.snackbar(
          "Sukses",
          "Transaksi berhasil dicatat!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // RE-FETCH: Update list transaksi & saldo organisasi
        fetchAllData();
        orgCtrl.fetchWorkspaces();
      } else {
        _showError(response.body?['message'] ?? "Gagal simpan transaksi");
      }
    } catch (e) {
      _showError("Server Error pas simpan transaksi");
    } finally {
      isLoading.value = false;
    }
  }

  // --- ACTION: Tambah Kantong Baru ke Database ---
  void addCustomPocket(String name) async {
    final orgId = orgCtrl.selectedOrg.value?.id;
    if (orgId == null || name.isEmpty) return;

    try {
      isLoading.value = true;

      // Ambil token dari storage
      final token = storage.read('token');

      // Tembak API Backend Go Bos Hasan
      final response = await _connect.post(
        ApiConstants
            .pockets, // Pastikan endpoint ini sudah terdaftar di ApiConstants
        {
          "org_id": orgId,
          "name": name,
          "balance": 0.0, // Default saldo 0 buat kantong baru
        },
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isOk) {
        // Refresh semua data biar list kantong di UI update
        await fetchAllData();

        // Langsung pilih kantong yang baru dibuat biar user nggak milih lagi
        selectedPocket.value = name;

        Get.snackbar(
          "Sukses",
          "Kantong '$name' berhasil ditambahkan!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        _showError(response.body?['message'] ?? "Gagal tambah kantong.");
      }
    } catch (e) {
      _showError("Koneksi server bermasalah pas tambah kantong.");
    } finally {
      isLoading.value = false;
    }
  }

  // --- ACTION: Tambah Kategori (Cukup Lokal dulu atau API) ---
  void addCustomCategory(String name) {
    if (name.trim().isNotEmpty && !rxCategoryOptions.contains(name)) {
      rxCategoryOptions.add(name);
      selectedCategory.value = name;
    }
  }

  void _showError(String msg) {
    Get.snackbar(
      "Error",
      msg,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }
}
