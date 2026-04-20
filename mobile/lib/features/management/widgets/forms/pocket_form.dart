import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/base_input.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import 'package:mobile/data/models/pocket_model.dart';
import 'package:mobile/features/management/controllers/management_controller.dart';
import '_form_shared_widgets.dart';

class PocketForm {
  static void show({
    PocketModel? pocket,
    required ManagementController controller,
  }) {
    final isEdit = pocket != null;
    final formatter = NumberFormat.decimalPattern('id_ID');

    // --- CONTROLLERS ---
    final nameCtrl = TextEditingController(text: isEdit ? pocket.name : "");

    // Balance Controller (Supaya bisa edit saldo manual)
    final balanceCtrl = TextEditingController(
      text: isEdit ? formatter.format(pocket.balance) : "0",
    );

    final targetCtrl = TextEditingController(
      text:
          (isEdit && pocket.targetAmount > 0)
              ? formatter.format(pocket.targetAmount)
              : "0",
    );

    final allocationCtrl = TextEditingController(
      text:
          isEdit ? pocket.allocationRule.toString().replaceAll('.0', '') : "0",
    );

    final rxIsMain = (isEdit ? pocket.isMain : false).obs;

    Get.bottomSheet(
      FormSharedWidgets.sheetWrapper(
        title: isEdit ? "Update Pocket" : "New Pocket",
        children: [
          // 1. Nama Pocket
          BaseInput(
            controller: nameCtrl,
            label: "Pocket Name",
            icon: Icons.label_outline,
            hint: "e.g. Dana Darurat",
          ),
          const SizedBox(height: 16),

          // 2. Current Balance (Muncul di Edit maupun New)
          BaseInput(
            controller: balanceCtrl,
            label: "Current Balance",
            icon: Icons.account_balance_wallet_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            hint: "0",
          ),
          const SizedBox(height: 16),

          // 3. Row: Allocation Rule & Target Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: BaseInput(
                  controller: allocationCtrl,
                  label: "Allocation (%)",
                  icon: Icons.pie_chart_outline,
                  keyboardType: TextInputType.number,
                  hint: "0",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: BaseInput(
                  controller: targetCtrl,
                  label: "Target Amount",
                  icon: Icons.track_changes,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  hint: "0",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4. Is Main Switch
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      rxIsMain.value
                          ? AppTheme.primary.withOpacity(0.5)
                          : Colors.white10,
                ),
              ),
              child: SwitchListTile(
                title: const Text(
                  "Main Pocket",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  "Receives remaining income overflow",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
                value: rxIsMain.value,
                activeColor: AppTheme.primary,
                onChanged: (val) => rxIsMain.value = val,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 5. Action Button
          FormSharedWidgets.actionButton(
            isEdit ? "Update Pocket" : "Create Pocket",
            () {
              // Parsing aman
              double currentBalance =
                  double.tryParse(
                    balanceCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
                  ) ??
                  0;
              double target =
                  double.tryParse(
                    targetCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
                  ) ??
                  0;
              double allocation = double.tryParse(allocationCtrl.text) ?? 0;

              if (isEdit) {
                // Update: 6 Arguments
                controller.updatePocket(
                  pocket.id,
                  nameCtrl.text,
                  allocation,
                  target,
                  currentBalance,
                  rxIsMain.value,
                );
              } else {
                // Add: 4 Arguments
                controller.addPocket(
                  nameCtrl.text,
                  allocation,
                  target,
                  rxIsMain.value,
                );
              }
            },
          ),
        ],
      ),
      isScrollControlled: true,
    );
  }
}
