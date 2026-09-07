import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../theme/app_theme.dart';
import '../utils/app_transitions.dart';
import 'contact_avatar.dart';

/// ตัวเลือกรูปโปรไฟล์ เลือกรูปจริงจากเครื่อง หรือใช้อีโมจิกับสีก็ได้
///
/// รูปจริงถูกย่อเหลือด้านละไม่เกิน 256 พิกเซลก่อนเก็บ ไฟล์ฐานข้อมูลจึงไม่บวม
/// ส่วนอีโมจิกับสีเก็บไว้ให้เลือกด้วย เพราะบางคนไม่มีรูปของอีกฝ่ายอยู่ในเครื่อง
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    required this.preview,
    required this.onEmojiChanged,
    required this.onColorChanged,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  /// ผู้ติดต่อรุ่นทดลองที่ถือค่าที่กำลังเลือกอยู่ ใช้แสดงตัวอย่างด้านซ้าย
  final Contact preview;

  final ValueChanged<String> onEmojiChanged;

  /// -1 หมายถึงกลับไปใช้สีที่คำนวณจากชื่อ
  final ValueChanged<int> onColorChanged;

  /// เปิดคลังรูปให้เลือกไฟล์ หน้าฟอร์มเป็นคนจัดการเรื่องย่อรูปและสิทธิ์
  final VoidCallback onPickImage;

  final VoidCallback onRemoveImage;

  /// อีโมจิให้เลือก คัดมาเฉพาะที่สื่อถึงคนหรือความสัมพันธ์
  static const List<String> emojiChoices = [
    '', '😀', '😎', '🤓', '🥰', '😺', '🐶', '🦊',
    '🐼', '🌟', '🌸', '🍀', '⚽', '🎧', '📚', '💼',
    '🎨', '🍜', '☕', '🚀',
  ];

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
                ContactAvatar(contact: preview, radius: 28),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'รูปโปรไฟล์',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        preview.hasImage
                            ? 'ใช้รูปจากเครื่อง'
                            : preview.avatarEmoji.isEmpty
                                ? 'ยังไม่ได้เลือกรูป ใช้ตัวอักษรแรกของชื่อแทน'
                                : 'ใช้อีโมจิที่เลือกไว้',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickImage,
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: Text(
                      preview.hasImage ? 'เปลี่ยนรูป' : 'เลือกรูปจากเครื่อง',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.divider),
                      minimumSize: const Size.fromHeight(44),
                    ),
                  ),
                ),
                if (preview.hasImage) ...[
                  const SizedBox(width: AppSpacing.gap),
                  IconButton(
                    tooltip: 'เอารูปออก',
                    onPressed: onRemoveImage,
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.danger),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              // บอกไว้ตรง ๆ ว่าอีกสองอย่างข้างล่างจะไม่มีผลถ้าใส่รูปจริงไว้
              preview.hasImage
                  ? 'อีโมจิและสีด้านล่างจะกลับมาใช้เมื่อเอารูปออก'
                  : 'หรือเลือกอีโมจิแทนก็ได้',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.gap),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: emojiChoices.map((emoji) {
                  final active = emoji == preview.avatarEmoji;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.gap),
                    child: _Swatch(
                      active: active,
                      onTap: () => onEmojiChanged(emoji),
                      child: emoji.isEmpty
                          ? const Icon(
                              Icons.text_fields,
                              size: 18,
                              color: AppColors.textSecondary,
                            )
                          : Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('สีพื้นหลัง', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.gap),
            Wrap(
              spacing: AppSpacing.gap,
              runSpacing: AppSpacing.gap,
              children: [
                _Swatch(
                  active: preview.avatarColor < 0,
                  onTap: () => onColorChanged(-1),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                for (var i = 0; i < AppColors.avatarPalette.length; i++)
                  _Swatch(
                    active: preview.avatarColor == i,
                    onTap: () => onColorChanged(i),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.avatarPalette[i],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ปุ่มสี่เหลี่ยมหนึ่งช่องในตัวเลือก ขอบจะเข้มขึ้นเมื่อถูกเลือก
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.active,
    required this.onTap,
    required this.child,
  });

  final bool active;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        // ขอบหนาขึ้นและพื้นสว่างขึ้นแบบไล่ ตอบสนองทันทีที่แตะ
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.curve,
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.18)
                : AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.divider,
              width: active ? 2 : 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
