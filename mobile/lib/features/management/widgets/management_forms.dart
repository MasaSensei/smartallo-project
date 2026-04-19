import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/base_input.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../controllers/management_controller.dart';
import '../../../data/models/storage_model.dart';
import '../../../data/models/pocket_model.dart';
import '../../../data/models/category_model.dart';

class ManagementForms {
  // --- STORAGE FORM ---
  static void showStorageForm({
    StorageModel? storage,
    required ManagementController controller,
  }) {
    final isEdit = storage != null;
    final formatter = NumberFormat.decimalPattern('id_ID');

    final nameCtrl = TextEditingController(text: isEdit ? storage.name : "");
    final balanceCtrl = TextEditingController(
      text: isEdit ? formatter.format(storage.balance) : "0",
    );
    final rxType = (isEdit ? storage.type : "BANK").obs;

    Get.bottomSheet(
      _sheetWrapper(isEdit ? "Edit Storage" : "New Storage", [
        BaseInput(
          controller: nameCtrl,
          label: "Storage Name",
          hint: "e.g. Bank BCA / Cash",
          icon: Icons.account_balance,
        ),
        const SizedBox(height: 16),
        BaseInput(
          controller: balanceCtrl,
          label: "Current Balance",
          hint: "0",
          icon: Icons.account_balance_wallet,
          keyboardType: TextInputType.number, // Pakai keyboard angka
          inputFormatters: [
            CurrencyInputFormatter(),
          ], // Pakai formatter currency
        ),
        const SizedBox(height: 16),
        const Text(
          "Type",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: [
              _typeChip("BANK", rxType),
              const SizedBox(width: 8),
              _typeChip("E-WALLET", rxType),
              const SizedBox(width: 8),
              _typeChip("CASH", rxType),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _actionButton(isEdit ? "Update" : "Save", () {
          double b =
              double.tryParse(
                balanceCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              0;
          if (isEdit) {
            controller.updateStorage(
              storage.id!,
              nameCtrl.text,
              rxType.value,
              b,
            );
          } else {
            controller.addStorage(nameCtrl.text, rxType.value, b);
          }
        }),
      ]),
      isScrollControlled: true,
    );
  }

  // --- POCKET FORM ---
  static void showPocketForm(
    BuildContext context, {
    PocketModel? pocket,
    required ManagementController controller,
  }) {
    final isEdit = pocket != null;
    final formatter = NumberFormat.decimalPattern('id_ID');

    final nameCtrl = TextEditingController(text: isEdit ? pocket.name : "");
    final balanceCtrl = TextEditingController(
      text: isEdit ? formatter.format(pocket.balance) : "0",
    );

    Get.bottomSheet(
      _sheetWrapper(isEdit ? "Update Pocket" : "New Pocket", [
        BaseInput(
          controller: nameCtrl,
          label: "Pocket Name",
          hint: "e.g. Tabungan Rumah",
          icon: Icons.label_outline,
        ),
        const SizedBox(height: 16),
        BaseInput(
          controller: balanceCtrl,
          label: "Target / Current Balance",
          hint: "0",
          icon: Icons.account_balance_wallet_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
        ),
        const SizedBox(height: 32),
        _actionButton(isEdit ? "Update" : "Create", () {
          double b =
              double.tryParse(
                balanceCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              0;
          if (isEdit) {
            // Sesuai argumen: id, name, allocation, target, balance
            controller.updatePocket(pocket!.id, nameCtrl.text, 0, 0, b);
          } else {
            // Sesuai argumen: name, allocation, target
            controller.addPocket(nameCtrl.text, 0, 0);
          }
        }),
      ]),
      isScrollControlled: true,
    );
  }

  // --- CATEGORY FORM ---
  static void showCategoryForm({
    CategoryModel? category,
    required ManagementController controller,
  }) {
    final isEdit = category != null;
    final nameCtrl = TextEditingController(text: isEdit ? category.name : "");
    final rxType = (isEdit ? (category.type ?? "OUT") : "OUT").toString().obs;

    Get.bottomSheet(
      _sheetWrapper(isEdit ? "Edit Category" : "New Category", [
        BaseInput(
          controller: nameCtrl,
          label: "Category Name",
          hint: "e.g. Food / Salary",
          icon: Icons.category_outlined,
        ),
        const SizedBox(height: 16),
        const Text(
          "Category Type",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: [
              _typeChip("OUT", rxType),
              const SizedBox(width: 8),
              _typeChip("IN", rxType),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _actionButton("Save", () {
          if (isEdit) {
            controller.updateCategory(category.id, nameCtrl.text, rxType.value);
          } else {
            controller.addCategory(nameCtrl.text, rxType.value);
          }
        }),
      ]),
    );
  }

  // --- UI HELPERS ---

  static Widget _typeChip(String label, RxString selectedType) {
    return GestureDetector(
      onTap: () => selectedType.value = label,
      child: Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                selectedType.value == label
                    ? AppTheme.primary
                    : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  selectedType.value == label
                      ? AppTheme.primary
                      : Colors.white10,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color:
                  selectedType.value == label ? Colors.white : Colors.white38,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _actionButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
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
          ),
        ),
      ),
    );
  }

  static Widget _sheetWrapper(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...children,
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
