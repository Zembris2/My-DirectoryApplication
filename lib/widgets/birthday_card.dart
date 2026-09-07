import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../theme/app_theme.dart';
import '../utils/birthday.dart';

/// การ์ดเตือนวันเกิดที่ใกล้จะถึงในหน้าแดชบอร์ด
///
/// นี่คือเหตุผลที่สมุดรายชื่อควรเก็บวันเกิด ไม่ใช่แค่เก็บไว้เฉย ๆ
/// แต่เอามาเตือนล่วงหน้าให้ทันเตรียมคำอวยพร
class BirthdayCard extends StatelessWidget {
  const BirthdayCard({
    super.key,
    required this.contacts,
    this.windowDays = 30,
  });

  /// คนที่วันเกิดรอบถัดไปอยู่ในช่วงที่ตั้งไว้ เรียงจากใกล้ที่สุดมาแล้ว
  final List<Contact> contacts;

  /// ช่วงที่นับว่าใกล้ถึง ปรับได้จากหน้าตั้งค่า
  final int windowDays;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.cake, size: 18, color: AppColors.accent),
                const SizedBox(width: AppSpacing.gap),
                Expanded(
                  child: Text(
                    'วันเกิดที่ใกล้ถึง',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  'ใน $windowDays วัน',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (contacts.isEmpty)
              Text(
                'ยังไม่มีใครที่ใกล้วันเกิด '
                'ลองกรอกวันเกิดให้คนในสมุดเพื่อให้แอปเตือนล่วงหน้า',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ...contacts.map((contact) => _BirthdayRow(contact: contact)),
          ],
        ),
      ),
    );
  }
}

/// หนึ่งบรรทัดในการ์ดวันเกิด
class _BirthdayRow extends StatelessWidget {
  const _BirthdayRow({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final birthday = contact.birthday!;
    final days = Birthday.daysUntil(birthday);
    final today = days == 0;
    final avatarColor = AppColors.avatarColor(contact.name);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.gap),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: avatarColor.withValues(alpha: 0.18),
            child: Text(
              contact.initial,
              style: TextStyle(
                color: avatarColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  contact.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${Birthday.formatThai(birthday)} '
                  '· จะครบ ${Birthday.ageOnNextBirthday(birthday)} ปี',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.gap),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.gap,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              // วันเกิดวันนี้ใช้สีทึบให้เด่นกว่าคนอื่นชัดเจน
              color: today
                  ? AppColors.accent
                  : AppColors.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppSpacing.gap),
            ),
            child: Text(
              Birthday.countdownLabel(birthday),
              style: TextStyle(
                color: today ? const Color(0xFF0B1220) : AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
