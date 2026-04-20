import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/base_input.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import 'package:mobile/features/management/widgets/forms/_form_shared_widgets.dart';
import 'package:mobile/data/models/storage_model.dart';
import 'package:mobile/features/management/controllers/management_controller.dart';

class StorageForm {
  static void show({
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
      FormSharedWidgets.sheetWrapper(
        title: isEdit ? "Edit Storage" : "New Storage",
        children: [
          BaseInput(
            controller: nameCtrl,
            label: "Storage Name",
            icon: Icons.account_balance,
            hint: "e.g. BCA, Cash, OVO, etc.",
          ),
          const SizedBox(height: 16),
          BaseInput(
            controller: balanceCtrl,
            label: "Current Balance",
            icon: Icons.account_balance_wallet,
            keyboardType: TextInputType.number,
            hint: "0",
            inputFormatters: [CurrencyInputFormatter()],
          ),
          const SizedBox(height: 16),
          const Text(
            "Type",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FormSharedWidgets.typeChip("BANK", rxType),
              const SizedBox(width: 8),
              FormSharedWidgets.typeChip("E-WALLET", rxType),
              const SizedBox(width: 8),
              FormSharedWidgets.typeChip("CASH", rxType),
            ],
          ),
          const SizedBox(height: 32),
          FormSharedWidgets.actionButton(isEdit ? "Update" : "Save", () {
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
        ],
      ),
      isScrollControlled: true,
    );
  }
}
