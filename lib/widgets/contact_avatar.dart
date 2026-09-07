import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../theme/app_theme.dart';

/// รูปโปรไฟล์ของผู้ติดต่อหนึ่งคน
///
/// ไล่ลำดับจากที่ผู้ใช้ตั้งใจที่สุดไปหาค่าอัตโนมัติ
/// มีรูปจริงใช้รูป ไม่มีก็ดูอีโมจิ ไม่มีอีกก็ใช้ตัวอักษรแรกของชื่อ
/// ส่วนสีพื้นหลังใช้สีที่เลือกเอง ถ้ายังไม่เคยเลือกจะคำนวณจากชื่อให้อัตโนมัติ
/// คนเดิมจึงได้สีเดิมทุกครั้งโดยไม่ต้องตั้งค่าอะไร
class ContactAvatar extends StatelessWidget {
  const ContactAvatar({
    super.key,
    required this.contact,
    this.radius = 24,
  });

  final Contact contact;
  final double radius;

  /// หาสีของคนนี้ ใช้ร่วมกันหลายที่จึงแยกเป็นเมธอดสถิต
  static Color colorOf(Contact contact) {
    final index = contact.avatarColor;
    if (index < 0) return AppColors.avatarColor(contact.name);
    return AppColors.avatarPalette[index % AppColors.avatarPalette.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = colorOf(contact);
    final emoji = contact.avatarEmoji;

    if (contact.hasImage) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: color.withValues(alpha: 0.18),
        backgroundImage: MemoryImage(contact.avatarImage!),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.18),
      child: emoji.isEmpty
          ? Text(
              contact.initial,
              style: TextStyle(
                color: color,
                fontSize: radius * 0.75,
                fontWeight: FontWeight.w700,
              ),
            )
          // อีโมจิมีสีของตัวเองอยู่แล้ว จึงไม่ต้องกำหนดสีตัวอักษรทับ
          : Text(emoji, style: TextStyle(fontSize: radius * 0.9)),
    );
  }
}
