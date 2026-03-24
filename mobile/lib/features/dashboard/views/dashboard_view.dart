import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/pocket_card.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              const SizedBox(height: 100), // Spasi agar tidak tertutup FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Open Bottom Sheet Input Transaksi
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text(
          "Catat Nabung",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
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
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Statistik Mingguan",
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
                maxY: 20,
                barTouchData: BarTouchData(enabled: false),
                titlesData: const FlTitlesData(
                  show: false,
                ), // Hide titles for cleaner look
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, 12, AppTheme.primary),
                  _makeGroupData(1, 18, AppTheme.success),
                  _makeGroupData(2, 6, AppTheme.primary),
                  _makeGroupData(3, 15, AppTheme.primary),
                  _makeGroupData(4, 9, AppTheme.danger),
                  _makeGroupData(5, 11, AppTheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 14,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ],
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
}
