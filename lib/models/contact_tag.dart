import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// กลุ่มของผู้ติดต่อ ใช้จัดหมวดคนในสมุดให้หาเจอง่ายขึ้นเมื่อรายชื่อเยอะ
///
/// เก็บลงฐานข้อมูลเป็นข้อความภาษาไทยตรง ๆ ไม่ใช่ตัวเลข index
/// เพราะถ้าวันหลังสลับลำดับ enum ข้อมูลเดิมจะไม่เพี้ยนตาม
enum ContactTag {
  general('ทั่วไป', Icons.label_outline, AppColors.textSecondary),
  family('ครอบครัว', Icons.home_outlined, AppColors.danger),
  friend('เพื่อน', Icons.emoji_people_outlined, AppColors.success),
  work('ที่ทำงาน', Icons.work_outline, AppColors.primary),
  study('ที่เรียน', Icons.school_outlined, AppColors.accent);

  const ContactTag(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  /// แปลงข้อความจากฐานข้อมูลกลับเป็น enum
  /// ถ้าเจอค่าที่ไม่รู้จัก (เช่น ข้อมูลเก่าหรือพิมพ์ผิด) ให้ตกมาที่ "ทั่วไป"
  static ContactTag fromLabel(String? label) {
    return ContactTag.values.firstWhere(
      (tag) => tag.label == label,
      orElse: () => ContactTag.general,
    );
  }
}
