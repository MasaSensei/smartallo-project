import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/data/models/category_model.dart';
import 'package:mobile/features/management/controllers/management_controller.dart';
import 'package:mobile/features/management/widgets/forms/_form_shared_widgets.dart';
import '../../../../core/widgets/base_input.dart';

class CategoryForm {
  static void show({
    CategoryModel? category,
    required ManagementController controller,
  }) {
    final isEdit = category != null;
    final nameCtrl = TextEditingController(text: isEdit ? category.name : "");
    final rxType = (isEdit ? category.type : "OUT").obs;

    Get.bottomSheet(
      FormSharedWidgets.sheetWrapper(
        title: isEdit ? "Edit Category" : "New Category",
        children: [
          BaseInput(
            controller: nameCtrl,
            label: "Category Name",
            icon: Icons.category_outlined,
            hint: "e.g. Food, Salary, etc.",
          ),
          const SizedBox(height: 16),
          const Text(
            "Category Type",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FormSharedWidgets.typeChip("OUT", rxType),
              const SizedBox(width: 8),
              FormSharedWidgets.typeChip("IN", rxType),
            ],
          ),
          const SizedBox(height: 32),
          FormSharedWidgets.actionButton("Save", () {
            if (isEdit) {
              controller.updateCategory(
                category.id,
                nameCtrl.text,
                rxType.value,
              );
            } else {
              controller.addCategory(nameCtrl.text, rxType.value);
            }
          }),
        ],
      ),
    );
  }
}
