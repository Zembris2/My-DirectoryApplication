import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../theme/app_theme.dart';
import '../utils/app_transitions.dart';
import '../utils/birthday.dart';
import 'contact_avatar.dart';

/// การ์ดแสดงผู้ติดต่อ 1 คนในหน้ารายการ
///
/// แตะที่การ์ดเพื่อแก้ไข กดค้างเพื่อเปิดเมนูคัดลอก ปุ่มดาวและปุ่มลบ
/// วางห่างกันตามระยะมาตรฐานเพื่อลดโอกาสกดผิดปุ่ม
class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleFavorite,
    required this.onDelete,
    this.showNote = true,
  });

  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  /// ปิดได้จากหน้าตั้งค่า สำหรับคนที่อยากให้การ์ดสั้นที่สุด
  final bool showNote;

  @override
  Widget build(BuildContext context) {
    final birthday = contact.birthday;
    final note = showNote ? contact.note : '';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          // ขีดสีด้านซ้ายบอกกลุ่มของคนนี้ อ่านได้เร็วกว่าการหาป้ายข้อความ
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: contact.tag.color, width: 4),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ContactAvatar(contact: contact),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                contact.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.gap),
                            _TagChip(contact: contact),
                          ],
                        ),
                        // ช่องที่ไม่ได้กรอกไม่ต้องเว้นที่ไว้ การ์ดจะได้ไม่มีบรรทัดว่าง
                        if (contact.phone.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          _InfoLine(
                            icon: Icons.phone_outlined,
                            text: contact.phone,
                          ),
                        ],
                        if (contact.email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          _InfoLine(
                            icon: Icons.mail_outline,
                            text: contact.email,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gap),
                  IconButton(
                    onPressed: onToggleFavorite,
                    tooltip: contact.isFavorite
                        ? 'เอาออกจากรายการโปรด'
                        : 'เพิ่มเข้ารายการโปรด',
                    // สลับไอคอนแบบขยายเข้า บอกว่ากดติดแล้วโดยไม่ต้องมีข้อความ
                    icon: AnimatedSwitcher(
                      duration: AppMotion.fast,
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                      child: Icon(
                        contact.isFavorite ? Icons.star : Icons.star_border,
                        key: ValueKey(contact.isFavorite),
                        color: contact.isFavorite
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    tooltip: 'ลบรายชื่อ',
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
              // แถวล่างขึ้นเฉพาะคนที่มีข้อมูลเสริมจริง ๆ
              // การ์ดของคนที่กรอกแค่ชื่อกับเบอร์จึงยังสั้นเท่าเดิม
              if (birthday != null || note.isNotEmpty || contact.hasSocial) ...[
                const SizedBox(height: AppSpacing.gap),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: AppSpacing.gap),
                Row(
                  children: [
                    if (birthday != null) ...[
                      _BirthdayBadge(birthday: birthday),
                      const SizedBox(width: AppSpacing.gap),
                    ],
                    if (contact.hasSocial) ...[
                      _SocialIcons(contact: contact),
                      const SizedBox(width: AppSpacing.gap),
                    ],
                    if (note.isNotEmpty)
                      Expanded(
                        child: _InfoLine(
                          icon: Icons.sticky_note_2_outlined,
                          text: note,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ไอคอนเล็ก ๆ บอกว่ามีช่องทางออนไลน์ช่องไหนบ้าง
///
/// แสดงแค่ไอคอน ไม่แสดงชื่อบัญชี เพราะการ์ดในรายการควรกวาดตาผ่านได้เร็ว
/// อยากรู้ชื่อบัญชีจริงให้กดค้างแล้วคัดลอก หรือแตะเข้าไปดูในฟอร์ม
class _SocialIcons extends StatelessWidget {
  const _SocialIcons({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final entries = <(IconData, Color)>[
      if (contact.instagram.isNotEmpty) (Icons.camera_alt_outlined, AppColors.pink),
      if (contact.lineId.isNotEmpty) (Icons.chat_bubble_outline, AppColors.success),
      if (contact.facebook.isNotEmpty) (Icons.public, AppColors.primary),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (icon, color) in entries)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: Icon(icon, size: 14, color: color),
          ),
      ],
    );
  }
}

/// ป้ายกลุ่มเล็ก ๆ ท้ายชื่อ
class _TagChip extends StatelessWidget {
  const _TagChip({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final tag = contact.tag;

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.gap, vertical: 2),
      decoration: BoxDecoration(
        color: tag.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSpacing.gap),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tag.icon, size: 11, color: tag.color),
          const SizedBox(width: 3),
          Text(
            tag.label,
            style: TextStyle(
              color: tag.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ป้ายนับถอยหลังวันเกิด เน้นสีเฉพาะตอนใกล้ถึงจริง ๆ
class _BirthdayBadge extends StatelessWidget {
  const _BirthdayBadge({required this.birthday});

  final DateTime birthday;

  @override
  Widget build(BuildContext context) {
    final days = Birthday.daysUntil(birthday);
    final soon = days <= 7;
    final color = soon ? AppColors.accent : AppColors.textSecondary;

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.gap, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: soon ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.gap),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(soon ? Icons.cake : Icons.cake_outlined, size: 12, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            soon
                ? Birthday.countdownLabel(birthday)
                : Birthday.formatThai(birthday),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: soon ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
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
