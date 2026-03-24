import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/amount_text.dart';

class TransactionTile extends StatelessWidget {
  final String title;
  final double amount;
  final String type;
  final String date;

  const TransactionTile({
    super.key,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isOut = type == 'OUT';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            isOut
                ? AppTheme.danger.withOpacity(0.1)
                : AppTheme.success.withOpacity(0.1),
        child: Icon(
          isOut ? Icons.arrow_outward_rounded : Icons.south_west_rounded,
          color: isOut ? AppTheme.danger : AppTheme.success,
          size: 20,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        date,
        style: const TextStyle(fontSize: 12, color: Colors.white54),
      ),
      trailing: AmountText(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isOut ? AppTheme.danger : AppTheme.success,
        ),
      ),
    );
  }
}
