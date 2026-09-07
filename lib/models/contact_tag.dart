import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// กลุ่มของผู้ติดต่อ ใช้จัดหมวดคนในสมุดให้หาเจอง่ายขึ้นเมื่อรายชื่อเยอะ
///
/// มี 5 กลุ่มมาให้ตั้งแต่แรก และผู้ใช้สร้างกลุ่มของตัวเองเพิ่มได้
/// กลุ่มทั้งหมดเก็บอยู่ในตาราง tags ส่วนตัวผู้ติดต่อเก็บแค่ "ชื่อกลุ่ม" เป็นข้อความ
/// ทำให้เปลี่ยนสีหรือไอคอนของกลุ่มได้โดยไม่ต้องแตะข้อมูลผู้ติดต่อเลยสักแถว
@immutable
class ContactTag {
  const ContactTag({
    required this.label,
    required this.colorIndex,
    required this.iconIndex,
    this.isBuiltin = false,
  });

  final String label;

  /// ลำดับในจานสีและชุดไอคอน เก็บเป็นตัวเลขเพื่อให้ปรับโทนทั้งแอปได้ทีหลัง
  final int colorIndex;
  final int iconIndex;

  /// กลุ่มที่มีมาให้ตั้งแต่แรก ลบไม่ได้ แต่เปลี่ยนสีกับไอคอนได้
  final bool isBuiltin;

  Color get color =>
      AppColors.tagPalette[colorIndex % AppColors.tagPalette.length];

  IconData get icon => iconChoices[iconIndex % iconChoices.length];

  /// ไอคอนให้เลือกตอนสร้างกลุ่ม
  ///
  /// ต้องเป็นรายการตายตัวแบบ const เพื่อให้ตอนสร้างไฟล์ติดตั้งตัดไอคอนที่ไม่ได้ใช้ทิ้งได้
  /// ถ้าปล่อยให้ระบุไอคอนอิสระ ไฟล์แอปจะใหญ่ขึ้นเพราะต้องพกฟอนต์ไอคอนไปทั้งชุด
  static const List<IconData> iconChoices = [
    Icons.label_outline,
    Icons.home_outlined,
    Icons.emoji_people_outlined,
    Icons.work_outline,
    Icons.school_outlined,
    Icons.favorite_border,
    Icons.star_border,
    Icons.sports_soccer,
    Icons.music_note_outlined,
    Icons.restaurant_outlined,
    Icons.flight_takeoff_outlined,
    Icons.pets_outlined,
    Icons.local_hospital_outlined,
    Icons.shopping_bag_outlined,
  ];

  /// กลุ่มสำรองเมื่อหาชื่อกลุ่มไม่เจอ เช่น ผู้ใช้เพิ่งลบกลุ่มนั้นไป
  static const ContactTag general = ContactTag(
    label: 'ทั่วไป',
    colorIndex: 0,
    iconIndex: 0,
    isBuiltin: true,
  );

  /// กลุ่มที่ใส่ให้ตั้งแต่ติดตั้งครั้งแรก
  static const List<ContactTag> defaults = [
    general,
    ContactTag(label: 'ครอบครัว', colorIndex: 1, iconIndex: 1, isBuiltin: true),
    ContactTag(label: 'เพื่อน', colorIndex: 2, iconIndex: 2, isBuiltin: true),
    ContactTag(label: 'ที่ทำงาน', colorIndex: 3, iconIndex: 3, isBuiltin: true),
    ContactTag(label: 'ที่เรียน', colorIndex: 4, iconIndex: 4, isBuiltin: true),
  ];

  /// รายการกลุ่มที่ใช้อยู่จริงตอนนี้ โหลดจากฐานข้อมูลตอนเปิดแอป
  ///
  /// เก็บไว้เป็นตัวแปรกลางเพราะการ์ดรายชื่อทุกใบต้องใช้หาสีของกลุ่ม
  /// ถ้าส่งรายการกลุ่มไล่ลงไปทีละชั้นจะต้องแก้ทุกวิดเจ็ตที่คั่นกลางโดยไม่ได้ใช้เอง
  static List<ContactTag> all = defaults;

  /// แปลงชื่อกลุ่มเป็นข้อมูลกลุ่ม ถ้าไม่เจอให้ตกมาที่ "ทั่วไป"
  static ContactTag fromLabel(String? label) {
    return all.firstWhere(
      (tag) => tag.label == label,
      orElse: () => general,
    );
  }

  Map<String, Object?> toMap(int sortOrder) {
    return {
      'label': label,
      'color_index': colorIndex,
      'icon_index': iconIndex,
      'sort_order': sortOrder,
      'is_builtin': isBuiltin ? 1 : 0,
    };
  }

  factory ContactTag.fromMap(Map<String, Object?> map) {
    return ContactTag(
      label: (map['label'] as String?) ?? '',
      colorIndex: (map['color_index'] as int?) ?? 0,
      iconIndex: (map['icon_index'] as int?) ?? 0,
      isBuiltin: (map['is_builtin'] as int? ?? 0) == 1,
    );
  }

  ContactTag copyWith({String? label, int? colorIndex, int? iconIndex}) {
    return ContactTag(
      label: label ?? this.label,
      colorIndex: colorIndex ?? this.colorIndex,
      iconIndex: iconIndex ?? this.iconIndex,
      isBuiltin: isBuiltin,
    );
  }

  /// เทียบกันด้วยชื่อกลุ่มอย่างเดียว เพราะชื่อคือคีย์ในฐานข้อมูล
  /// จำเป็นตอนใช้กลุ่มเป็นคีย์ของ Map ในการนับจำนวนคนต่อกลุ่ม
  @override
  bool operator ==(Object other) => other is ContactTag && other.label == label;

  @override
  int get hashCode => label.hashCode;
}
