import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../theme/app_theme.dart';

/// การ์ดแสดงผู้ติดต่อ 1 คนในหน้ารายการ
///
/// แตะที่การ์ดเพื่อแก้ไข ปุ่มดาวและปุ่มลบวางห่างกันตามระยะมาตรฐาน
/// เพื่อลดโอกาสกดผิดปุ่ม
class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.18),
                child: Text(
                  contact.initial,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _InfoLine(icon: Icons.phone_outlined, text: contact.phone),
                    const SizedBox(height: 2),
                    _InfoLine(icon: Icons.mail_outline, text: contact.email),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.gap),
              IconButton(
                onPressed: onToggleFavorite,
                tooltip: contact.isFavorite ? 'เอาออกจากรายการโปรด' : 'เพิ่มเข้ารายการโปรด',
                icon: Icon(
                  contact.isFavorite ? Icons.star : Icons.star_border,
                  color: contact.isFavorite ? AppColors.accent : AppColors.textSecondary,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'ลบรายชื่อ',
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
