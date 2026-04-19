import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CategoryItem extends StatelessWidget {
  final dynamic category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryItem({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.white10,
          child: Icon(Icons.tag, color: AppTheme.primary),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
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
        ),
      ),
    );
  }
}
