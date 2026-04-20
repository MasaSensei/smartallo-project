import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/management_controller.dart';

// Widgets
import '../widgets/pocket_card.dart';
import '../widgets/category_item.dart';
import '../widgets/management_forms.dart';
import '../widgets/delete_dialog.dart';

class ManagementView extends GetView<ManagementController> {
  const ManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
          bottom: const TabBar(
            indicatorColor: AppTheme.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            tabs: [
              Tab(text: "Storages", icon: Icon(Icons.account_balance_rounded)),
              Tab(text: "Pockets", icon: Icon(Icons.wallet_rounded)),
              Tab(text: "Categories", icon: Icon(Icons.grid_view_rounded)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStorageTab(),
            _buildPocketTab(),
            _buildCategoryTab(),
          ],
        ),
        floatingActionButton: _buildFab(),
      ),
    );
  }

  // --- TAB STORAGE ---
  Widget _buildStorageTab() {
    return Obx(() {
      if (controller.isLoading.value)
        return const Center(child: CircularProgressIndicator());
      if (controller.rxStorages.isEmpty)
        return _emptyState("No storages found.");

      return ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: controller.rxStorages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final s = controller.rxStorages[i];
          return ListTile(
            tileColor: Colors.white.withOpacity(0.03),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: const CircleAvatar(
              backgroundColor: AppTheme.primary,
              child: Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              s.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              s.type,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 20,
              ),
              onPressed:
                  () => DeleteDialog.show(
                    onConfirm: () => controller.deleteStorage(s.id!),
                  ),
            ),
            onTap:
                () => ManagementForms.showStorageForm(
                  storage: s,
                  controller: controller,
                ),
          );
        },
      );
    });
  }

  // --- TAB POCKETS ---
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
          return PocketCard(
            p: p,
            onEdit:
                () => ManagementForms.showPocketForm(
                  pocket: p, // Context sudah dihapus di parameter form
                  controller: controller,
                ),
            onDelete:
                () => DeleteDialog.show(
                  onConfirm: () => controller.deletePocket(p.id),
                ),
          );
        },
      );
    });
  }

  // --- TAB CATEGORIES ---
  Widget _buildCategoryTab() {
    return Obx(() {
      if (controller.isLoading.value)
        return const Center(child: CircularProgressIndicator());
      if (controller.rxCategories.isEmpty)
        return _emptyState("No categories found.");

      return ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: controller.rxCategories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final c = controller.rxCategories[i];
          return CategoryItem(
            category: c,
            onEdit:
                () => ManagementForms.showCategoryForm(
                  category: c,
                  controller: controller,
                ),
            onDelete:
                () => DeleteDialog.show(
                  onConfirm: () => controller.deleteCategory(c.id),
                ),
          );
        },
      );
    });
  }

  // --- FLOATING ACTION BUTTON ---
  Widget _buildFab() {
    return Builder(
      builder:
          (fabContext) => FloatingActionButton.extended(
            backgroundColor: AppTheme.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Add New",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              final index = DefaultTabController.of(fabContext).index;
              // Panggilan form sekarang seragam tanpa BuildContext
              if (index == 0) {
                ManagementForms.showStorageForm(controller: controller);
              } else if (index == 1) {
                ManagementForms.showPocketForm(controller: controller);
              } else {
                ManagementForms.showCategoryForm(controller: controller);
              }
            },
          ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Text(msg, style: const TextStyle(color: Colors.white24)),
    );
  }
}
