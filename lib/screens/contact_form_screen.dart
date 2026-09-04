import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';

/// หน้าฟอร์มสำหรับเพิ่มรายชื่อใหม่ และแก้ไขรายชื่อเดิม
///
/// ใช้หน้าจอเดียวกันทั้งสองกรณี ถ้าส่ง [initial] เข้ามาคือโหมดแก้ไข
/// เมื่อกดบันทึกและข้อมูลผ่านการตรวจสอบ จะส่ง Contact กลับผ่าน Navigator.pop
class ContactFormScreen extends StatefulWidget {
  const ContactFormScreen({super.key, this.initial});

  final Contact? initial;

  bool get isEditing => initial != null;

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _phoneController = TextEditingController(text: initial?.phone ?? '');
    _emailController = TextEditingController(text: initial?.email ?? '');
    _isFavorite = initial?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    // validate จะสั่งให้ทุก TextFormField ตรวจตัวเองและแสดงข้อความแดงใต้ช่อง
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final initial = widget.initial;

    final contact = Contact(
      id: initial?.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      isFavorite: _isFavorite,
      createdAt: initial?.createdAt ?? now,
      updatedAt: now,
    );

    Navigator.of(context).pop(contact);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'แก้ไขรายชื่อ' : 'เพิ่มรายชื่อ'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'ชื่อ',
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
                  labelText: 'เบอร์โทร',
                  hintText: 'เช่น 0812345678',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: Validators.phone,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                decoration: const InputDecoration(
                  labelText: 'อีเมล',
                  hintText: 'เช่น somchai@mail.com',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: Validators.email,
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: SwitchListTile(
                  value: _isFavorite,
                  onChanged: (value) => setState(() => _isFavorite = value),
                  title: const Text('เพิ่มเข้ารายการโปรด'),
                  secondary: Icon(
                    _isFavorite ? Icons.star : Icons.star_border,
                    color: _isFavorite ? AppColors.accent : AppColors.textSecondary,
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
                label: Text(widget.isEditing ? 'บันทึกการแก้ไข' : 'บันทึกรายชื่อ'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
