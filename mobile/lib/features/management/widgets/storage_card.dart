import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/amount_text.dart'; // Pake Core Widget lo
import '../../../data/models/storage_model.dart';

class StorageCard extends StatelessWidget {
  final StorageModel s;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const StorageCard({
    super.key,
    required this.s,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getIcon(s.type), color: AppTheme.primary),
        ),
        title: Text(
          s.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: AmountText(
            s.balance,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.redAccent,
            size: 22,
          ),
          onPressed: onDelete,
        ),
      ),
    );
  }

  // Helper untuk nentuin icon berdasarkan tipe storage
  IconData _getIcon(String type) {
    switch (type.toUpperCase()) {
      case 'BANK':
        return Icons.account_balance_rounded;
      case 'E-WALLET':
        return Icons.account_balance_wallet_rounded;
      case 'CASH':
        return Icons.payments_rounded;
      default:
        return Icons.savings_rounded;
    }
  }
}
