import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// เมนูดึงลงมุมขวาบน รวมหน้าที่เปิดนาน ๆ ครั้งไว้ด้วยกัน
///
/// แยกคู่มือกับตั้งค่าออกจากแถบเมนูหลัก เพราะสองหน้านี้เปิดไม่บ่อย
/// ถ้าใส่เป็นแท็บจะเบียดที่ของหน้าที่ใช้ทุกวันโดยไม่จำเป็น
class MoreMenu extends StatelessWidget {
  const MoreMenu({
    super.key,
    required this.onOpenManual,
    required this.onOpenSettings,
  });

  final VoidCallback onOpenManual;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'เมนูเพิ่มเติม',
      icon: const Icon(Icons.more_vert),
      color: AppColors.surfaceHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      onSelected: (value) {
        if (value == 0) {
          onOpenManual();
        } else {
          onOpenSettings();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 0,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.menu_book_outlined, color: AppColors.teal),
            title: Text('คู่มือการใช้งาน'),
            subtitle: Text('วิธีใช้ทุกฟีเจอร์ และวิธีแก้ปัญหา'),
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.settings_outlined, color: AppColors.violet),
            title: Text('ตั้งค่า'),
            subtitle: Text('ค่าเริ่มต้น การแสดงผล และข้อมูลระบบ'),
          ),
        ),
      ],
    );
  }
}
