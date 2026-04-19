import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';

class DeleteDialog {
  static void show({required VoidCallback onConfirm}) {
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
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                onConfirm();
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
}
