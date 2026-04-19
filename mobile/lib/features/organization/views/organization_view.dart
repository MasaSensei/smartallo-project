import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/organization_controller.dart';
import '../../../data/models/organization_model.dart';

class OrganizationView extends GetView<OrganizationController> {
  const OrganizationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchWorkspaces(),
        color: AppTheme.primary,
        child: Obx(() => _buildBody()),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // --- Components ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        "Select Workspace",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      actions: [Obx(() => _buildTierBadge()), const SizedBox(width: 16)],
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value && controller.organizations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (controller.currentTier.value == 'FREE') const _PromoBanner(),
        const SizedBox(height: 24),
        _buildSectionTitle("Your Workspaces"),
        const SizedBox(height: 16),
        if (controller.organizations.isEmpty)
          _buildEmptyState()
        else
          ...controller.organizations.map(
            (org) => _OrgCard(
              org: org,
              isSelected: controller.selectedOrg.value?.id == org.id,
              onTap: () => controller.selectWorkspace(org),
            ),
          ),
      ],
    );
  }

  Widget _buildTierBadge() {
    final tier = controller.currentTier.value;
    final isFree = tier == 'FREE';

    return Center(
      child: GestureDetector(
        onTap: () => Get.toNamed(Routes.SUBSCRIPTION),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                isFree
                    ? Colors.white.withOpacity(0.05)
                    : Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isFree ? Colors.white24 : Colors.amber.withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFree ? Icons.auto_awesome_outlined : Icons.verified_rounded,
                color: isFree ? Colors.white70 : Colors.amber,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                isFree ? "UPGRADE" : tier,
                style: TextStyle(
                  color: isFree ? Colors.white70 : Colors.amber,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Icon(Icons.business_center_outlined, size: 70, color: Colors.white10),
        const SizedBox(height: 16),
        const Text(
          "No workspaces found.\nCreate one to start managing your balance.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => Get.toNamed('/organization/create'),
      backgroundColor: AppTheme.primary,
      elevation: 4,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        "New Workspace",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// --- Sub-Widgets (Refactored for Performance) ---

class _OrgCard extends StatelessWidget {
  final OrganizationModel org;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrgCard({
    required this.org,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isSelected
                  ? AppTheme.primary.withOpacity(0.5)
                  : Colors.white.withOpacity(0.05),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              org.name[0].toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ),
        title: Text(
          org.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: const Text(
          "Workspace Owner",
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
        trailing:
            isSelected
                ? const Icon(Icons.check_circle, color: AppTheme.primary)
                : const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white10,
                  size: 14,
                ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Unlock Premium Features!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Upgrade to PRO for unlimited workspaces.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Get.toNamed(Routes.SUBSCRIPTION),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "UPGRADE",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
