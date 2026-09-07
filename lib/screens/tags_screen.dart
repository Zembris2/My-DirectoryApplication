import 'package:flutter/material.dart';

import '../data/tag_repository.dart';
import '../models/contact_tag.dart';
import '../theme/app_theme.dart';
import '../widgets/content_width.dart';
import '../widgets/empty_state.dart';

/// หน้าจัดการกลุ่มผู้ติดต่อ เพิ่ม แก้ไข และลบกลุ่มของตัวเองได้
class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key, required this.onChanged});

  /// แจ้งหน้าอื่นเมื่อรายการกลุ่มเปลี่ยน เพื่อให้แถบกรองและการ์ดวาดใหม่
  final VoidCallback onChanged;

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  final TagRepository _repository = TagRepository();

  List<ContactTag> _tags = ContactTag.all;
  Map<String, int> _counts = const {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tags = await _repository.load();
    final counts = await _repository.countByTag();
    if (!mounted) return;
    setState(() {
      _tags = tags;
      _counts = counts;
      _loading = false;
    });
    widget.onChanged();
  }

  Future<void> _openEditor({ContactTag? existing}) async {
    final result = await showTagEditor(context, existing: existing);
    if (result == null) return;

    await _repository.save(result, previousLabel: existing?.label);
    await _load();
  }

  Future<void> _confirmDelete(ContactTag tag) async {
    final used = _counts[tag.label] ?? 0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Text('ลบกลุ่ม "${tag.label}"'),
        content: Text(
          used == 0
              ? 'กลุ่มนี้ยังไม่มีใครอยู่ ลบได้เลย'
              : 'มี $used รายชื่ออยู่ในกลุ่มนี้ '
                  'คนเหล่านั้นจะถูกย้ายไปกลุ่ม "ทั่วไป" ไม่ได้ถูกลบทิ้ง',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('ลบกลุ่ม'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _repository.delete(tag);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('จัดการกลุ่ม')),
      body: SafeArea(
        child: ContentWidth(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _tags.isEmpty
                  ? const EmptyState(
                      icon: Icons.label_outline,
                      title: 'ยังไม่มีกลุ่ม',
                      message: 'กดปุ่มเพิ่มกลุ่มด้านล่างขวาเพื่อสร้างกลุ่มแรก',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        96,
                      ),
                      itemCount: _tags.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.gap),
                      itemBuilder: (context, index) {
                        final tag = _tags[index];
                        return _TagRow(
                          tag: tag,
                          used: _counts[tag.label] ?? 0,
                          onEdit: () => _openEditor(existing: tag),
                          onDelete:
                              tag.isBuiltin ? null : () => _confirmDelete(tag),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openEditor,
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มกลุ่ม'),
      ),
    );
  }
}

/// หนึ่งแถวในรายการกลุ่ม
class _TagRow extends StatelessWidget {
  const _TagRow({
    required this.tag,
    required this.used,
    required this.onEdit,
    required this.onDelete,
  });

  final ContactTag tag;
  final int used;
  final VoidCallback onEdit;

  /// null เมื่อลบไม่ได้ ปุ่มจะถูกซ่อนไปเลยแทนที่จะขึ้นแล้วกดไม่ได้
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final onDelete = this.onDelete;

    return Card(
      child: ListTile(
        onTap: onEdit,
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.gap),
          decoration: BoxDecoration(
            color: tag.color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppSpacing.gap),
          ),
          child: Icon(tag.icon, color: tag.color, size: 20),
        ),
        title: Text(tag.label, style: Theme.of(context).textTheme.bodyMedium),
        subtitle: Text(
          tag.isBuiltin ? 'กลุ่มพื้นฐาน · $used รายชื่อ' : '$used รายชื่อ',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'แก้ไขกลุ่ม',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined,
                  color: AppColors.textSecondary),
            ),
            if (onDelete != null)
              IconButton(
                tooltip: 'ลบกลุ่ม',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
      ),
    );
  }
}

/// เปิดกล่องสร้างหรือแก้ไขกลุ่ม คืนค่ากลุ่มที่ตั้งไว้ หรือ null เมื่อกดยกเลิก
///
/// แยกเป็นฟังก์ชันเพื่อให้เรียกได้ทั้งจากหน้าจัดการกลุ่ม
/// และจากปุ่มเพิ่มกลุ่มในฟอร์มกรอกรายชื่อ ผู้ใช้จะได้ไม่ต้องออกจากฟอร์มไปสร้างก่อน
Future<ContactTag?> showTagEditor(
  BuildContext context, {
  ContactTag? existing,
}) {
  return showDialog<ContactTag>(
    context: context,
    builder: (_) => _TagEditorDialog(existing: existing),
  );
}

class _TagEditorDialog extends StatefulWidget {
  const _TagEditorDialog({this.existing});

  final ContactTag? existing;

  @override
  State<_TagEditorDialog> createState() => _TagEditorDialogState();
}

class _TagEditorDialogState extends State<_TagEditorDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.existing?.label ?? '');

  late int _colorIndex = widget.existing?.colorIndex ?? 5;
  late int _iconIndex = widget.existing?.iconIndex ?? 0;

  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final label = _controller.text.trim();

    if (label.isEmpty) {
      setState(() => _error = 'กรุณาตั้งชื่อกลุ่ม');
      return;
    }

    // ชื่อกลุ่มคือคีย์ในฐานข้อมูล ถ้าซ้ำกันจะทับกลุ่มเดิมโดยไม่ตั้งใจ
    final duplicate = ContactTag.all.any(
      (tag) => tag.label == label && label != widget.existing?.label,
    );
    if (duplicate) {
      setState(() => _error = 'มีกลุ่มชื่อนี้อยู่แล้ว');
      return;
    }

    Navigator.of(context).pop(
      ContactTag(
        label: label,
        colorIndex: _colorIndex,
        iconIndex: _iconIndex,
        isBuiltin: widget.existing?.isBuiltin ?? false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceHigh,
      title: Text(widget.existing == null ? 'เพิ่มกลุ่มใหม่' : 'แก้ไขกลุ่ม'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 20,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'ชื่อกลุ่ม',
                hintText: 'เช่น ลูกค้า, ทีมกีฬา',
                errorText: _error,
              ),
            ),
            const SizedBox(height: AppSpacing.gap),
            Text('สี', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.gap),
            Wrap(
              spacing: AppSpacing.gap,
              runSpacing: AppSpacing.gap,
              children: [
                for (var i = 0; i < AppColors.tagPalette.length; i++)
                  _Pick(
                    active: _colorIndex == i,
                    onTap: () => setState(() => _colorIndex = i),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.tagPalette[i],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('ไอคอน', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.gap),
            Wrap(
              spacing: AppSpacing.gap,
              runSpacing: AppSpacing.gap,
              children: [
                for (var i = 0; i < ContactTag.iconChoices.length; i++)
                  _Pick(
                    active: _iconIndex == i,
                    onTap: () => setState(() => _iconIndex = i),
                    child: Icon(
                      ContactTag.iconChoices[i],
                      size: 18,
                      color: AppColors.tagPalette[
                          _colorIndex % AppColors.tagPalette.length],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(onPressed: _submit, child: const Text('บันทึก')),
      ],
    );
  }
}

/// ช่องเลือกสีหรือไอคอนหนึ่งช่อง
class _Pick extends StatelessWidget {
  const _Pick({
    required this.active,
    required this.onTap,
    required this.child,
  });

  final bool active;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.gap),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.gap),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.divider,
            width: active ? 2 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}
