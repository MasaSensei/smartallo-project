import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/amount_text.dart';

class PocketCard extends StatelessWidget {
  final dynamic p;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PocketCard({
    super.key,
    required this.p,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    double balance = double.tryParse(p.balance.toString()) ?? 0;
    double target = double.tryParse(p.target_amount?.toString() ?? "0") ?? 0;
    double progress = (target > 0) ? (balance / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(20),
            title: Row(
              children: [
                Text(
                  p.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                if (p.allocation_rule > 0) _buildBadge("${p.allocation_rule}%"),
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
            trailing: _buildActions(),
          ),
          if (target > 0) _buildProgressSection(progress, target),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppTheme.primary, fontSize: 12),
      ),
    );
  }

  Widget _buildProgressSection(double progress, double target) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Target: ${target.toInt()}",
                style: const TextStyle(color: Colors.white38, fontSize: 12),
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
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_note_rounded, color: Colors.white38),
          onPressed: onEdit,
        ),
        IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppTheme.danger,
          ),
          onPressed: onDelete,
        ),
      ],
    );
  }
}
