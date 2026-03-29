import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/amount_text.dart';
import '../../organization/controllers/organization_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/pocket_card.dart';
import '../widgets/add_transaction_sheet.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
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
                _buildTopBar(orgCtrl),

                // Chart Section
                Obx(
                  () =>
                      controller.isLoading.value
                          ? _buildChartSkeleton()
                          : _buildChartSection(),
                ),

                _buildSectionTitle("Saving Pockets"),
                Obx(
                  () =>
                      controller.isLoading.value
                          ? _buildPocketSkeleton()
                          : _buildPocketCarousel(),
                ),

                _buildSectionTitle("Recent Activity"),
                Obx(
                  () =>
                      controller.isLoading.value
                          ? _buildTransactionSkeleton()
                          : _buildTransactionList(),
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // --- Top Bar ---
  Widget _buildTopBar(OrganizationController orgCtrl) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
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
                    Obx(
                      () => Text(
                        orgCtrl.selectedOrg.value?.name ?? "Select Workspace",
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() {
                  if (controller.isLoading.value) {
                    return _buildBaseShimmer(
                      Container(
                        height: 32,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                  final balance =
                      double.tryParse(
                        orgCtrl.selectedOrg.value?.totalBalance ?? '0',
                      ) ??
                      0.0;
                  return AmountText(
                    balance,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  );
                }),
              ],
            ),
          ),
          _buildSwitchBtn(),
        ],
      ),
    );
  }

  // --- Chart Section (Smoothed Line Chart) ---
  Widget _buildChartSection() {
    return Container(
      height: 260,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Weekly Analytics",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildChartLegend(),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: _buildChartTitles(),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _lineData(AppTheme.success, controller.rxIncomeData),
                  _lineData(AppTheme.danger, controller.rxExpenseData),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _lineData(Color color, List<double> data) {
    return LineChartBarData(
      isCurved: true,
      curveSmoothness: 0.35,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.15), color.withOpacity(0)],
        ),
      ),
      spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
    );
  }

  FlTitlesData _buildChartTitles() {
    return FlTitlesData(
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(),
      leftTitles: const AxisTitles(),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (val, _) {
            int i = val.toInt();
            if (i >= 0 && i < controller.rxChartLabels.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  controller.rxChartLabels[i],
                  style: const TextStyle(color: Colors.white24, fontSize: 10),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      children: [
        _legendItem("In", AppTheme.success),
        const SizedBox(width: 12),
        _legendItem("Out", AppTheme.danger),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }

  // --- List & Carousel ---
  Widget _buildPocketCarousel() {
    return SizedBox(
      height: 190,
      child: Obx(() {
        if (controller.rxPockets.isEmpty) {
          return const Center(
            child: Text(
              "No pockets found",
              style: TextStyle(color: Colors.white24),
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
      if (controller.rxTransactions.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Text(
              "No recent activity.",
              style: TextStyle(color: Colors.white38),
            ),
          ),
        );
      }
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: controller.rxTransactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tx = controller.rxTransactions[index];
          final amt = double.tryParse(tx['total_amount'].toString()) ?? 0.0;
          final bool isIncome = tx['type'] == 'IN';

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: (isIncome
                          ? AppTheme.success
                          : AppTheme.danger)
                      .withOpacity(0.1),
                  child: Icon(
                    isIncome ? Icons.add : Icons.remove,
                    color: isIncome ? AppTheme.success : AppTheme.danger,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['category_name'] ?? "Uncategorized",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tx['created_at'].toString().split('T')[0],
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                AmountText(
                  amt,
                  style: TextStyle(
                    color: isIncome ? AppTheme.success : AppTheme.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  // --- Skeletons & Helpers ---
  Widget _buildBaseShimmer(Widget child) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.1),
      child: child,
    );
  }

  Widget _buildChartSkeleton() {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: _buildBaseShimmer(const SizedBox.expand()),
    );
  }

  Widget _buildPocketSkeleton() {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder:
            (_, __) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _buildBaseShimmer(
                Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildTransactionSkeleton() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 5,
      itemBuilder:
          (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildBaseShimmer(
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildSwitchBtn() {
    return GestureDetector(
      onTap: () => Get.toNamed('/organization'),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: const Icon(
          Icons.grid_view_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        controller.setTransactionType(true);
        Get.bottomSheet(const AddTransactionSheet(), isScrollControlled: true);
      },
      backgroundColor: AppTheme.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        "Add Record",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
