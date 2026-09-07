import 'package:flutter/material.dart';

import '../models/contact_tag.dart';
import '../theme/app_theme.dart';
import '../utils/app_transitions.dart';

/// แถบกรองตามกลุ่ม เลื่อนแนวนอนได้เพราะกลุ่มอาจมีมากกว่าความกว้างจอ
///
/// [selected] เป็น null แปลว่าเลือก "ทุกกลุ่ม" ไม่ได้กรองอะไรเลย
class TagFilterBar extends StatelessWidget {
  const TagFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ContactTag? selected;
  final ValueChanged<ContactTag?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          _TagButton(
            label: 'ทุกกลุ่ม',
            icon: Icons.apps,
            color: AppColors.textSecondary,
            active: selected == null,
            onTap: () => onChanged(null),
          ),
          ...ContactTag.values.map(
            (tag) => _TagButton(
              label: tag.label,
              icon: tag.icon,
              color: tag.color,
              active: selected == tag,
              // กดกลุ่มที่เลือกอยู่ซ้ำ = ยกเลิกการกรอง ผู้ใช้ไม่ต้องหาปุ่มล้าง
              onTap: () => onChanged(selected == tag ? null : tag),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagButton extends StatelessWidget {
  const _TagButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.gap),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          // ไล่สีพื้นกับสีขอบตอนสลับกลุ่ม ทำให้เห็นว่าปุ่มไหนเพิ่งเปลี่ยนสถานะ
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.curve,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: active ? color.withValues(alpha: 0.18) : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(
                color: active ? color : AppColors.divider,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: active ? color : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: TextStyle(
                    color: active ? color : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
