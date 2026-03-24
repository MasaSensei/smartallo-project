import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/pocket_card.dart';
import '../widgets/add_transaction_sheet.dart'; // Pastikan import sheet-nya

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Latar gelap yang lebih solid
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              _buildChartSection(),
              _buildSectionTitle("Kantong Tabungan"),
              _buildPocketCarousel(),
              _buildSectionTitle("Aktivitas Terakhir"),
              _buildTransactionList(),
              const SizedBox(
                height: 120,
              ), // Spasi ekstra agar FAB tidak menutupi list
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  "Halo, ${controller.rxUserName}",
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ),
              const SizedBox(height: 4),
              Obx(
                () => AmountText(
                  controller.rxTotalBalance.value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          _buildTierBadge(),
        ],
      ),
    );
  }

  Widget _buildTierBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Obx(
        () => Text(
          controller.rxUserTier.value,
          style: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Aktivitas Mingguan", // Judul baru
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.bar_chart_rounded, color: AppTheme.primary, size: 18),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(
              () => BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100, // Sekarang kita pakai data visual saja
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: const FlTitlesData(show: false),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: _chartGroups(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _chartGroups() {
    // Kita pakai data visual statis dulu untuk merepresentasikan aktivitas
    // Bar terakhir sengaja dibuat menonjol sebagai "Hari Ini"
    List<double> visualData = [45, 70, 35, 90, 60, 50, 80];

    return List.generate(
      visualData.length,
      (i) => BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: visualData[i],
            // Warna bar terakhir (index 6) dibuat solid, sisanya agak transparan
            color:
                i == 6 ? AppTheme.primary : AppTheme.primary.withOpacity(0.2),
            width: 16,
            borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPocketCarousel() {
    return SizedBox(
      height: 190,
      child: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.rxPockets.length,
          itemBuilder:
              (context, index) =>
                  PocketCard(pocket: controller.rxPockets[index]),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return Obx(
      () => ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.rxTransactions.length,
        itemBuilder: (context, index) {
          final trx = controller.rxTransactions[index];
          return TransactionTile(
            title: trx['title'],
            amount: trx['amount'],
            type: trx['type'],
            date: trx['date'],
          );
        },
      ),
    );
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              "Lihat Semua",
              style: TextStyle(color: AppTheme.primary, fontSize: 12),
            ),
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
      icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
      label: const Text(
        "Catat Transaksi",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
