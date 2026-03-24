import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../../../core/theme/app_theme.dart';

class AddTransactionSheet extends GetView<DashboardController> {
  const AddTransactionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Logic Warna & Label Dinamis
      final bool isIncome = controller.isIncome.value;
      final Color activeColor = isIncome ? AppTheme.success : AppTheme.danger;
      final String pocketLabel =
          isIncome ? "Simpan ke Mana?" : "Pakai Kantong Mana?";
      final String categoryLabel =
          isIncome ? "Sumber Pendapatan" : "Keperluan / Kategori";
      final String buttonText =
          isIncome ? "Simpan Tabungan" : "Catat Pengeluaran";

      return Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 28,
              right: 28,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- TAB SELECTOR (Nabung vs Keluar) ---
                Container(
                  height: 50,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildTab("Nabung", true, AppTheme.success),
                      _buildTab("Keluar", false, AppTheme.danger),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // --- INPUT NOMINAL ---
                TextField(
                  controller: controller.amountController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: activeColor,
                  ),
                  decoration: InputDecoration(
                    prefixText: "Rp ",
                    hintText: "0",
                    hintStyle: const TextStyle(color: Colors.white10),
                    border: InputBorder.none,
                  ),
                ),
                const Divider(color: Colors.white10, height: 40),

                // --- DROPDOWN KANTONG (DINAMIS) ---
                _buildLabel(pocketLabel),
                _buildSmartDropdown(
                  label: "Kantong",
                  value: controller.selectedPocket.value,
                  items: controller.rxPocketOptions,
                  onChanged: (val) => controller.selectedPocket.value = val!,
                  onAddNew: (val) => controller.addCustomPocket(val),
                ),
                const SizedBox(height: 20),

                // --- DROPDOWN KATEGORI (DINAMIS) ---
                _buildLabel(categoryLabel),
                _buildSmartDropdown(
                  label: "Kategori",
                  value: controller.selectedCategory.value,
                  items: controller.rxCategoryOptions,
                  onChanged: (val) => controller.selectedCategory.value = val!,
                  onAddNew: (val) => controller.addCustomCategory(val),
                ),
                const SizedBox(height: 40),

                // --- BUTTON SIMPAN ---
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activeColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => controller.saveTransaction(),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // --- REUSABLE COMPONENTS ---

  Widget _buildSmartDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required Function(String) onAddNew,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isEmpty ? null : value,
          isExpanded: true,
          dropdownColor: AppTheme.cardDark,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white38),
          items: [
            ...items.map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: const TextStyle(color: Colors.white)),
              ),
            ),
            DropdownMenuItem(
              value: "ADD_NEW",
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Tambah $label Baru",
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onChanged: (val) {
            if (val == "ADD_NEW") {
              _showAddDialog(label, onAddNew);
            } else {
              onChanged(val);
            }
          },
        ),
      ),
    );
  }

  void _showAddDialog(String label, Function(String) onSave) {
    TextEditingController textController = TextEditingController();
    Get.defaultDialog(
      title: "Tambah $label",
      backgroundColor: AppTheme.cardDark,
      titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      content: TextField(
        controller: textController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Nama $label baru...",
          hintStyle: const TextStyle(color: Colors.white24),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white10),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppTheme.primary),
          ),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Batal", style: TextStyle(color: Colors.white54)),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
        onPressed: () {
          if (textController.text.trim().isNotEmpty) {
            onSave(textController.text.trim());
            Get.back();
          }
        },
        child: const Text("Simpan", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTab(String label, bool value, Color color) {
    bool isSelected = controller.isIncome.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.isIncome.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
