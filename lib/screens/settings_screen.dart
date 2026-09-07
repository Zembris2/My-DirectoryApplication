import 'package:flutter/material.dart';

import '../data/contact_repository.dart';
import '../data/db_factory.dart';
import '../models/app_settings.dart';
import '../models/contact_tag.dart';
import '../theme/app_theme.dart';
import '../widgets/content_width.dart';

/// หน้าตั้งค่าของแอป
///
/// ทุกตัวเลือกมีผลทันทีที่กด ไม่มีปุ่มบันทึกให้ต้องจำ
/// ค่าถูกเขียนลงตาราง settings ในฐานข้อมูลเดียวกับรายชื่อ เปิดแอปใหม่จึงยังอยู่
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onChanged,
    required this.repository,
    required this.total,
    required this.onDataCleared,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings> onChanged;
  final ContactRepository repository;

  /// จำนวนรายชื่อทั้งหมด ใช้แสดงในส่วนข้อมูลระบบและในข้อความยืนยันการล้างข้อมูล
  final int total;

  final VoidCallback onDataCleared;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// จำนวนรายชื่อที่หน้านี้เห็น เก็บไว้เองเพราะหน้าแม่ไม่ได้สั่งวาดหน้านี้ใหม่
  /// ตอนตัวเลขเปลี่ยน ถ้าอ่านจาก widget ตรง ๆ ปุ่มล้างข้อมูลจะค้างสถานะเดิม
  late int _total = widget.total;

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: const Text('ล้างข้อมูลทั้งหมด'),
        content: Text(
          'จะลบรายชื่อทั้ง $_total คนออกจากสมุดถาวร '
          'การลบครั้งนี้กดเลิกทำไม่ได้ ต้องการทำต่อหรือไม่',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('ล้างข้อมูล'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final removed = await widget.repository.deleteAll();
    widget.onDataCleared();
    if (!mounted) return;

    // อัปเดตตัวเลขในหน้านี้เอง ปุ่มจะได้กลายเป็นสีเทาทันทีเมื่อไม่เหลือใครแล้ว
    setState(() => _total = 0);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('ล้างข้อมูลแล้ว $removed รายชื่อ')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่า')),
      body: SafeArea(
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _Group(
                icon: Icons.person_add_alt,
                color: AppColors.primary,
                title: 'เมื่อเพิ่มรายชื่อใหม่',
                children: [
                  _ChoiceRow<ContactTag>(
                    label: 'กลุ่มที่เลือกไว้ให้',
                    value: widget.settings.defaultTag,
                    choices: {
                      for (final tag in ContactTag.values) tag: tag.label,
                    },
                    onChanged: (tag) =>
                        widget.onChanged(
                            widget.settings.copyWith(defaultTag: tag)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _Group(
                icon: Icons.contacts_outlined,
                color: AppColors.violet,
                title: 'หน้ารายชื่อ',
                children: [
                  _ChoiceRow<ContactSort>(
                    label: 'เรียงลำดับเริ่มต้น',
                    value: widget.settings.defaultSort,
                    choices: const {
                      ContactSort.newest: 'เพิ่มล่าสุด',
                      ContactSort.name: 'ตามชื่อ',
                    },
                    onChanged: (sort) =>
                        widget.onChanged(
                            widget.settings.copyWith(defaultSort: sort)),
                  ),
                  _SwitchRow(
                    label: 'แสดงบันทึกย่อบนการ์ด',
                    detail: 'ปิดแล้วการ์ดจะสั้นลง เห็นรายชื่อต่อหน้าจอมากขึ้น',
                    value: widget.settings.showNoteOnCard,
                    onChanged: (value) =>
                        widget.onChanged(
                            widget.settings.copyWith(showNoteOnCard: value)),
                  ),
                  _SwitchRow(
                    label: 'ถามยืนยันก่อนลบ',
                    detail: 'ปิดได้ เพราะยังมีปุ่มเลิกทำรับไว้อีกชั้นหนึ่ง',
                    value: widget.settings.confirmBeforeDelete,
                    onChanged: (value) =>
                        widget.onChanged(widget.settings
                            .copyWith(confirmBeforeDelete: value)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _Group(
                icon: Icons.cake_outlined,
                color: AppColors.accent,
                title: 'การเตือนวันเกิด',
                children: [
                  _ChoiceRow<int>(
                    label: 'มองล่วงหน้ากี่วัน',
                    value: widget.settings.birthdayWindowDays,
                    choices: {
                      for (final days in AppSettings.birthdayWindowChoices)
                        days: '$days วัน',
                    },
                    onChanged: (days) =>
                        widget.onChanged(widget.settings
                            .copyWith(birthdayWindowDays: days)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _Group(
                icon: Icons.storage_outlined,
                color: AppColors.teal,
                title: 'ข้อมูลระบบ',
                children: [
                  _InfoRow(label: 'รายชื่อในสมุด', value: '$_total คน'),
                  const _InfoRow(label: 'เวอร์ชันฐานข้อมูล', value: '5'),
                  _InfoRow(label: 'โหมดฐานข้อมูล', value: webDatabaseMode),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _Group(
                icon: Icons.warning_amber_outlined,
                color: AppColors.danger,
                title: 'เขตอันตราย',
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.gap),
                    child: Text(
                      'ก่อนล้างข้อมูล แนะนำให้กดปุ่มคัดลอกทั้งหมดในหน้ารายชื่อ '
                      'เพื่อเก็บข้อความสำรองไว้ก่อน',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _total == 0 ? null : _confirmClear,
                    icon: const Icon(Icons.delete_forever_outlined),
                    label: const Text('ล้างรายชื่อทั้งหมด'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// กล่องจัดกลุ่มการตั้งค่าหนึ่งหมวด
class _Group extends StatelessWidget {
  const _Group({
    required this.icon,
    required this.color,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final Color color;
  final String title;
  final List<Widget> children;

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
                Icon(icon, size: 18, color: color),
                const SizedBox(width: AppSpacing.gap),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// แถวเลือกหนึ่งค่าจากหลายตัวเลือก แสดงเป็นปุ่มให้กดเลือกเลย
/// ไม่ใช้เมนูดึงลง เพราะตัวเลือกมีไม่กี่อันและเห็นทั้งหมดพร้อมกันดีกว่า
class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.value,
    required this.choices,
    required this.onChanged,
  });

  final String label;
  final T value;
  final Map<T, String> choices;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.gap),
          Wrap(
            spacing: AppSpacing.gap,
            runSpacing: AppSpacing.gap,
            children: choices.entries.map((entry) {
              final active = entry.key == value;
              return ChoiceChip(
                selected: active,
                onSelected: (_) => onChanged(entry.key),
                label: Text(entry.value),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary.withValues(alpha: 0.18),
                side: BorderSide(
                  color: active ? AppColors.primary : AppColors.divider,
                ),
                labelStyle: TextStyle(
                  color: active ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// แถวสวิตช์เปิด-ปิด พร้อมคำอธิบายว่าปิดแล้วจะเป็นอย่างไร
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.detail,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String detail;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(detail, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

/// แถวข้อมูลอ่านอย่างเดียว
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.gap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
