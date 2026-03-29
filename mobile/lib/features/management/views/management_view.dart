// lib/app/modules/management/views/management_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/core/widgets/amount_text.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/management_controller.dart';

class ManagementView extends GetView<ManagementController> {
  const ManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.bgDark,
        appBar: AppBar(
          backgroundColor: AppTheme.bgDark,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Management",
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
          bottom: TabBar(
            indicatorColor: AppTheme.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "Pockets", icon: Icon(Icons.wallet_rounded)),
              Tab(text: "Categories", icon: Icon(Icons.grid_view_rounded)),
            ],
          ),
        ),
        body: TabBarView(children: [_buildPocketTab(), _buildCategoryTab()]),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppTheme.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Add New",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            final index = DefaultTabController.of(context).index;
            index == 0 ? _showPocketForm() : _showCategoryForm();
          },
        ),
      ),
    );
  }

  // --- MODERN POCKET CARD ---
  Widget _buildPocketTab() {
    return Obx(() {
      if (controller.isLoading.value)
        return const Center(child: CircularProgressIndicator());
      if (controller.rxPockets.isEmpty)
        return _emptyState("No financial goals set yet.");

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: controller.rxPockets.length,
        itemBuilder: (context, i) {
          final p = controller.rxPockets[i];
          double balance = double.tryParse(p['balance'].toString()) ?? 0;
          double target =
              double.tryParse(p['target_amount']?.toString() ?? "0") ?? 0;
          double progress =
              (target > 0) ? (balance / target).clamp(0.0, 1.0) : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(20),
                    title: Row(
                      children: [
                        Text(
                          p['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (p['allocation_rule'] > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${p['allocation_rule']}%",
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: AmountText(
                        balance,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    trailing: _actionButtons(p, true),
                  ),
                  if (target > 0) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Target: ${target.toInt()}",
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "${(progress * 100).toInt()}%",
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white10,
                            color: AppTheme.primary,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildCategoryTab() {
    return Obx(() {
      if (controller.isLoading.value)
        return const Center(child: CircularProgressIndicator());
      return ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: controller.rxCategories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final c = controller.rxCategories[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.white10,
                child: Icon(Icons.tag, color: AppTheme.primary),
              ),
              title: Text(
                c['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: _actionButtons(c, false),
            ),
          );
        },
      );
    });
  }

  Widget _actionButtons(dynamic item, bool isPocket) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_note_rounded, color: Colors.white38),
          onPressed:
              () =>
                  isPocket
                      ? _showPocketForm(pocket: item)
                      : _showCategoryForm(category: item),
        ),
        IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppTheme.danger,
          ),
          onPressed: () => _confirmDelete(item['id'], isPocket),
        ),
      ],
    );
  }

  // --- GLASSMORPHISM DELETE ALERT ---
  void _confirmDelete(dynamic id, bool isPocket) {
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: AppTheme.cardDark.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: AppTheme.danger.withOpacity(0.2)),
          ),
          title: const Icon(
            Icons.auto_delete_rounded,
            color: AppTheme.danger,
            size: 40,
          ),
          content: const Text(
            "Hapus data ini? Aksi ini tidak bisa dibatalkan.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.white38),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                isPocket
                    ? controller.deletePocket(id)
                    : controller.deleteCategory(id);
                Get.back();
              },
              child: const Text(
                "Ya, Hapus",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODERN FORM POCKET ---
  void _showPocketForm({dynamic pocket}) {
    final isEdit = pocket != null;
    final nameCtrl = TextEditingController(text: isEdit ? pocket['name'] : "");
    final allocCtrl = TextEditingController(
      text: isEdit ? pocket['allocation_rule'].toString() : "0",
    );
    final targetCtrl = TextEditingController(
      text: isEdit ? (pocket['target_amount']?.toString() ?? "") : "",
    );

    Get.bottomSheet(
      _modernSheetWrapper(isEdit ? "Update Financial Goal" : "New Pocket", [
        _modernInput("Pocket Name", Icons.label_outline, nameCtrl),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _modernInput(
                "Allocation %",
                Icons.percent,
                allocCtrl,
                isNumber: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _modernInput(
                "Target Amount",
                Icons.track_changes,
                targetCtrl,
                isNumber: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _gradientButton(isEdit ? "Update Pocket" : "Activate Pocket", () {
          final alloc = double.tryParse(allocCtrl.text) ?? 0;
          final target = double.tryParse(targetCtrl.text) ?? 0;
          isEdit
              ? controller.updatePocket(
                pocket['id'],
                nameCtrl.text,
                alloc,
                target,
              )
              : controller.addPocket(nameCtrl.text, alloc, target);
        }),
      ]),
      isScrollControlled: true,
    );
  }

  void _showCategoryForm({dynamic category}) {
    final isEdit = category != null;
    final nameCtrl = TextEditingController(
      text: isEdit ? category['name'] : "",
    );

    Get.bottomSheet(
      _modernSheetWrapper(isEdit ? "Edit Category" : "New Category", [
        _modernInput("Category Name", Icons.category_outlined, nameCtrl),
        const SizedBox(height: 32),
        _gradientButton("Save Category", () {
          isEdit
              ? controller.updateCategory(category['id'], nameCtrl.text)
              : controller.addCategory(nameCtrl.text);
        }),
      ]),
    );
  }

  // --- UI COMPONENTS HELPER ---
  Widget _modernSheetWrapper(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 40, spreadRadius: 10),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _modernInput(
    String label,
    IconData icon,
    TextEditingController ctrl, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
      ),
    );
  }

  Widget _gradientButton(String label, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String msg) =>
      Center(child: Text(msg, style: const TextStyle(color: Colors.white24)));
}
