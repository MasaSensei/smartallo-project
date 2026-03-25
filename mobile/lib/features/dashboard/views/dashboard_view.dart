import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../../organization/controllers/organization_controller.dart'; // Import ini
import '../controllers/dashboard_controller.dart';
import '../widgets/pocket_card.dart';
import '../widgets/add_transaction_sheet.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita butuh akses ke OrganizationController untuk nama Workspace
    final orgCtrl = Get.find<OrganizationController>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.fetchAllData(),
          color: AppTheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(orgCtrl), // Kirim instance orgCtrl
                _buildChartSection(),
                _buildSectionTitle("Kantong Tabungan"),
                _buildPocketCarousel(),
                _buildSectionTitle("Aktivitas Terakhir"),
                _buildTransactionList(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildTopBar(OrganizationController orgCtrl) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            // Pakai expanded agar teks tidak overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppTheme.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    // Tampilkan Nama Workspace yang aktif
                    Obx(
                      () => Text(
                        orgCtrl.selectedOrg.value?.name ?? "Pilih Workspace",
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Total Balance dari Workspace yang dipilih
                Obx(
                  () => AmountText(
                    orgCtrl.selectedOrg.value?.totalBalance ?? 0.0,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tombol Switch Workspace
          GestureDetector(
            onTap: () => Get.toNamed('/organization'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Section Chart tetap sama (Visual Only), tapi pastikan responsive
  Widget _buildChartSection() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Statistik Aktivitas",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _chartGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _chartGroups() {
    List<double> visualData = [30, 50, 40, 80, 55, 45, 90];
    return List.generate(
      visualData.length,
      (i) => BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: visualData[i],
            color:
                i == 6 ? AppTheme.primary : AppTheme.primary.withOpacity(0.2),
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildPocketCarousel() {
    return SizedBox(
      height: 170,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.rxPockets.isEmpty) {
          return const Center(
            child: Text(
              "Belum ada kantong.",
              style: TextStyle(color: Colors.white38),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.rxPockets.length,
          itemBuilder:
              (context, index) =>
                  PocketCard(pocket: controller.rxPockets[index]),
        );
      }),
    );
  }

  Widget _buildTransactionList() {
    return Obx(() {
      if (controller.isLoading.value) return const SizedBox();
      if (controller.rxTransactions.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              "Belum ada transaksi.",
              style: TextStyle(color: Colors.white38),
            ),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.rxTransactions.length,
        itemBuilder: (context, index) {
          final trx = controller.rxTransactions[index];
          // Sesuaikan field dengan JSON dari Backend Go Bos Hasan
          return TransactionTile(
            title: trx['category'] ?? "Tanpa Kategori",
            amount: (trx['amount'] as num).toDouble(),
            type: trx['type'], // "IN" atau "OUT"
            date: trx['created_at'] ?? "Baru saja",
          );
        },
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white24,
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        controller.isIncome.value = true;
        Get.bottomSheet(
          const AddTransactionSheet(),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        );
      },
      backgroundColor: AppTheme.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        "Catat",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
