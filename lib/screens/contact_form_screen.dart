import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/contact.dart';
import '../data/tag_repository.dart';
import '../models/contact_tag.dart';
import '../theme/app_theme.dart';
import '../utils/birthday.dart';
import '../utils/image_tools.dart';
import '../utils/validators.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/content_width.dart';
import 'tags_screen.dart';

/// หน้าฟอร์มสำหรับเพิ่มรายชื่อใหม่ และแก้ไขรายชื่อเดิม
///
/// ใช้หน้าจอเดียวกันทั้งสองกรณี ถ้าส่ง [initial] เข้ามาคือโหมดแก้ไข
/// เมื่อกดบันทึกและข้อมูลผ่านการตรวจสอบ จะส่ง Contact กลับผ่าน Navigator.pop
class ContactFormScreen extends StatefulWidget {
  const ContactFormScreen({
    super.key,
    this.initial,
    this.defaultTag = ContactTag.general,
    this.onDelete,
  });

  final Contact? initial;

  /// กลุ่มที่เลือกไว้ล่วงหน้าเมื่อเพิ่มคนใหม่ มาจากหน้าตั้งค่า
  final ContactTag defaultTag;

  /// ลบคนนี้ทิ้ง เป็น null ตอนเพิ่มคนใหม่เพราะยังไม่มีอะไรให้ลบ
  ///
  /// หน้ารายการเป็นคนถามยืนยันและจัดการเรื่องปุ่มเลิกทำ
  /// หน้านี้แค่ปิดตัวเองแล้วส่งเรื่องต่อ
  final VoidCallback? onDelete;

  bool get isEditing => initial != null;

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _noteController;
  late final TextEditingController _instagramController;
  late final TextEditingController _lineController;
  late final TextEditingController _facebookController;
  late bool _isFavorite;
  late ContactTag _tag;
  late String _avatarEmoji;
  late int _avatarColor;
  Uint8List? _avatarImage;
  DateTime? _birthday;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _phoneController = TextEditingController(text: initial?.phone ?? '');
    _emailController = TextEditingController(text: initial?.email ?? '');
    _noteController = TextEditingController(text: initial?.note ?? '');
    _instagramController =
        TextEditingController(text: initial?.instagram ?? '');
    _lineController = TextEditingController(text: initial?.lineId ?? '');
    _facebookController = TextEditingController(text: initial?.facebook ?? '');
    _isFavorite = initial?.isFavorite ?? false;
    // ผ่าน fromLabel เสมอ เผื่อกลุ่มเดิมของคนนี้ถูกลบไปแล้ว จะได้ตกมาที่กลุ่มที่ยังมีอยู่
    _tag = ContactTag.fromLabel((initial?.tag ?? widget.defaultTag).label);
    _avatarEmoji = initial?.avatarEmoji ?? '';
    _avatarColor = initial?.avatarColor ?? -1;
    _avatarImage = initial?.avatarImage;
    _birthday = initial?.birthday;

    // ตัวอย่างรูปโปรไฟล์ต้องเปลี่ยนตามชื่อที่พิมพ์ ตอนที่ยังไม่ได้เลือกอีโมจิ
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    _instagramController.dispose();
    _lineController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  /// เปิดปฏิทินให้เลือกวันเกิด
  ///
  /// จำกัดไม่ให้เลือกวันในอนาคต เพราะไม่มีใครเกิดวันข้างหน้า
  /// ถ้าเคยเลือกไว้แล้วจะเปิดที่วันเดิม แต่ถ้ายังไม่เคยเลือก
  /// จะเปิดหน้าเลือก "ปี" ก่อนเลย ไม่เดาปีให้ผู้ใช้
  /// เพราะการเดาปีทำให้เผลอกดตกลงแล้วได้ปีที่ไม่ใช่ของจริงติดไปกับข้อมูล
  Future<void> _pickBirthday() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? today,
      initialDatePickerMode:
          _birthday == null ? DatePickerMode.year : DatePickerMode.day,
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: 'เลือกวันเกิด',
      cancelText: 'ยกเลิก',
      confirmText: 'ตกลง',
    );

    if (picked == null) return;
    setState(() => _birthday = picked);
  }

  /// เปิดคลังรูปแล้วย่อรูปที่เลือกก่อนเก็บไว้ในหน่วยความจำ
  ///
  /// ให้ image_picker ย่อมาชั้นหนึ่งตั้งแต่ตอนอ่านไฟล์ เพื่อไม่ให้รูปจากกล้อง
  /// ความละเอียดสูงกินหน่วยความจำทั้งใบ แล้วค่อยย่อซ้ำเป็น PNG ขนาดมาตรฐาน
  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 720,
        maxHeight: 720,
        imageQuality: 85,
      );
      if (picked == null) return;

      final shrunk = await ImageTools.shrinkToPng(await picked.readAsBytes());
      if (!mounted || shrunk == null) return;
      setState(() => _avatarImage = shrunk);
    } catch (error) {
      // เลือกรูปไม่สำเร็จไม่ใช่เรื่องคอขาดบาดตาย บอกแล้วให้กรอกอย่างอื่นต่อได้
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('เลือกรูปไม่สำเร็จ: $error')));
    }
  }

  /// สร้างกลุ่มใหม่จากในฟอร์มเลย แล้วเลือกกลุ่มนั้นให้ทันที
  ///
  /// ทำที่นี่ได้เพราะถ้าต้องออกไปสร้างที่หน้าตั้งค่าก่อน
  /// ผู้ใช้จะเสียข้อมูลที่กรอกค้างไว้ในฟอร์ม
  Future<void> _createTag() async {
    final created = await showTagEditor(context);
    if (created == null) return;

    await TagRepository().save(created);
    if (!mounted) return;
    setState(() => _tag = created);
  }

  void _save() {
    // validate จะสั่งให้ทุก TextFormField ตรวจตัวเองและแสดงข้อความแดงใต้ช่อง
    if (!_formKey.currentState!.validate()) return;

    // เบอร์กับอีเมลไม่บังคับทีละช่อง แต่ต้องมีช่องทางติดต่ออย่างน้อยหนึ่งช่อง
    // ตรวจตรงนี้เพราะเป็นเงื่อนไขข้ามหลายช่อง ตัวตรวจของแต่ละช่องทำแทนไม่ได้
    final missing = Validators.anyContact([
      _phoneController.text,
      _emailController.text,
      _instagramController.text,
      _lineController.text,
      _facebookController.text,
    ]);
    if (missing != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(missing)));
      return;
    }

    final now = DateTime.now();
    final initial = widget.initial;

    final contact = Contact(
      id: initial?.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      isFavorite: _isFavorite,
      tag: _tag,
      birthday: _birthday,
      note: _noteController.text.trim(),
      instagram: _instagramController.text.trim(),
      lineId: _lineController.text.trim(),
      facebook: _facebookController.text.trim(),
      avatarEmoji: _avatarEmoji,
      avatarColor: _avatarColor,
      avatarImage: _avatarImage,
      createdAt: initial?.createdAt ?? now,
      updatedAt: now,
    );

    Navigator.of(context).pop(contact);
  }

  /// ผู้ติดต่อรุ่นทดลองที่สะท้อนสิ่งที่กำลังกรอกอยู่ ใช้แสดงตัวอย่างรูปโปรไฟล์
  Contact get _preview {
    final now = DateTime.now();
    return Contact(
      name: _nameController.text,
      phone: '',
      email: '',
      avatarEmoji: _avatarEmoji,
      avatarColor: _avatarColor,
      avatarImage: _avatarImage,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    final onDelete = widget.onDelete;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'แก้ไขรายชื่อ' : 'เพิ่มรายชื่อ'),
        actions: [
          if (onDelete != null)
            IconButton(
              tooltip: 'ลบรายชื่อนี้',
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: ContentWidth(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                AvatarPicker(
                  preview: _preview,
                  onEmojiChanged: (emoji) =>
                      setState(() => _avatarEmoji = emoji),
                  onColorChanged: (index) =>
                      setState(() => _avatarColor = index),
                  onPickImage: _pickImage,
                  onRemoveImage: () => setState(() => _avatarImage = null),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อ (ต้องกรอก)',
                    hintText: 'เช่น สมชาย ใจดี',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: Validators.name,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'เบอร์โทร (ไม่บังคับ)',
                    hintText: 'เช่น 0812345678',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: Validators.phone,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'อีเมล (ไม่บังคับ)',
                    hintText: 'เช่น somchai@mail.com',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'ช่องทางออนไลน์ (ไม่บังคับ)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.gap),
                TextFormField(
                  controller: _instagramController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Instagram',
                    hintText: 'เช่น somchai.jd',
                    prefixIcon: Icon(Icons.camera_alt_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _lineController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'LINE ID',
                    hintText: 'เช่น somchai2543',
                    prefixIcon: Icon(Icons.chat_bubble_outline),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _facebookController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Facebook',
                    hintText: 'ชื่อโปรไฟล์หรือลิงก์',
                    prefixIcon: Icon(Icons.public),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _TagPicker(
                  selected: _tag,
                  onChanged: (tag) => setState(() => _tag = tag),
                  onCreate: _createTag,
                ),
                const SizedBox(height: AppSpacing.md),
                _BirthdayField(
                  birthday: _birthday,
                  onPick: _pickBirthday,
                  onClear: () => setState(() => _birthday = null),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  maxLength: 120,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'บันทึกย่อ (ไม่บังคับ)',
                    hintText: 'เช่น รู้จักจากงานสัมมนา ชอบกาแฟดำ',
                    prefixIcon: Icon(Icons.sticky_note_2_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.gap),
                Card(
                  child: SwitchListTile(
                    value: _isFavorite,
                    onChanged: (value) => setState(() => _isFavorite = value),
                    title: const Text('เพิ่มเข้ารายการโปรด'),
                    secondary: Icon(
                      _isFavorite ? Icons.star : Icons.star_border,
                      color: _isFavorite
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                      widget.isEditing ? 'บันทึกการแก้ไข' : 'บันทึกรายชื่อ'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
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

/// แถวเลือกกลุ่มแบบกดเลือกได้ทีละอัน
///
/// ใช้ปุ่มให้เลือกแทนช่องพิมพ์ เพราะกลุ่มมีไม่กี่แบบ และการพิมพ์เองจะทำให้
/// เกิดกลุ่มสะกดต่างกันเล็กน้อยจนกรองไม่เจอ
class _TagPicker extends StatelessWidget {
  const _TagPicker({
    required this.selected,
    required this.onChanged,
    required this.onCreate,
  });

  final ContactTag selected;
  final ValueChanged<ContactTag> onChanged;

  /// เปิดกล่องสร้างกลุ่มใหม่โดยไม่ต้องออกจากฟอร์ม
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('กลุ่ม', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.gap),
        Wrap(
          spacing: AppSpacing.gap,
          runSpacing: AppSpacing.gap,
          children: [
            ...ContactTag.all.map((tag) {
              final active = tag == selected;
              return ChoiceChip(
                selected: active,
                onSelected: (_) => onChanged(tag),
                avatar: Icon(
                  tag.icon,
                  size: 16,
                  color: active ? tag.color : AppColors.textSecondary,
                ),
                label: Text(tag.label),
                backgroundColor: AppColors.surface,
                selectedColor: tag.color.withValues(alpha: 0.18),
                side: BorderSide(
                  color: active ? tag.color : AppColors.divider,
                ),
                labelStyle: TextStyle(
                  color: active ? tag.color : AppColors.textPrimary,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
                showCheckmark: false,
              );
            }),
            // ปุ่มสร้างกลุ่มใหม่ วางท้ายสุดเพราะใช้ไม่บ่อยเท่าการเลือกกลุ่มที่มีอยู่
            ActionChip(
              onPressed: onCreate,
              avatar: const Icon(Icons.add, size: 16, color: AppColors.primary),
              label: const Text('เพิ่มกลุ่ม'),
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.divider),
              labelStyle: const TextStyle(color: AppColors.primary),
            ),
          ],
        ),
      ],
    );
  }
}

/// ช่องวันเกิด กดแล้วเปิดปฏิทิน พร้อมปุ่มล้างค่าเมื่อกรอกผิด
class _BirthdayField extends StatelessWidget {
  const _BirthdayField({
    required this.birthday,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? birthday;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final birthday = this.birthday;

    return Card(
      child: ListTile(
        onTap: onPick,
        leading: Icon(
          birthday == null ? Icons.cake_outlined : Icons.cake,
          color: birthday == null ? AppColors.textSecondary : AppColors.accent,
        ),
        title: Text(
          birthday == null
              ? 'วันเกิด (ไม่บังคับ)'
              : Birthday.formatThai(birthday),
          style: TextStyle(
            color: birthday == null
                ? AppColors.textSecondary
                : AppColors.textPrimary,
          ),
        ),
        subtitle: birthday == null
            ? null
            : Text(
                'อายุ ${Birthday.ageOnNextBirthday(birthday) - 1} ปี '
                '· ${Birthday.countdownLabel(birthday)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
        trailing: birthday == null
            ? const Icon(Icons.chevron_right, color: AppColors.textSecondary)
            : IconButton(
                tooltip: 'ล้างวันเกิด',
                onPressed: onClear,
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
      ),
    );
  }
}
