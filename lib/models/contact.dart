import 'dart:typed_data';

import 'contact_tag.dart';

/// โครงข้อมูลผู้ติดต่อ 1 คน ตรงกับ 1 แถวในตาราง contacts
class Contact {
  const Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.isFavorite = false,
    this.tag = ContactTag.general,
    this.birthday,
    this.note = '',
    this.instagram = '',
    this.lineId = '',
    this.facebook = '',
    this.avatarEmoji = '',
    this.avatarColor = -1,
    this.avatarImage,
    required this.createdAt,
    required this.updatedAt,
  });

  /// null เมื่อยังไม่เคยบันทึกลงฐานข้อมูล (SQLite จะออกเลขให้เอง)
  final int? id;
  final String name;
  final String phone;
  final String email;
  final bool isFavorite;

  /// กลุ่มที่คนนี้อยู่ เช่น ครอบครัว เพื่อน ที่ทำงาน
  final ContactTag tag;

  /// วันเกิด ไม่บังคับกรอก จึงเป็น null ได้
  final DateTime? birthday;

  /// บันทึกย่อ เช่น "รู้จักจากงานสัมมนา" หรือ "แพ้อาหารทะเล"
  final String note;

  /// ช่องทางติดต่อออนไลน์ ไม่บังคับกรอก ว่างไว้ได้ทั้งสามช่อง
  final String instagram;
  final String lineId;
  final String facebook;

  /// อีโมจิที่ใช้แทนรูปโปรไฟล์ ถ้าว่างจะใช้ตัวอักษรแรกของชื่อแทน
  final String avatarEmoji;

  /// ลำดับสีในจานสีของรูปโปรไฟล์ ค่า -1 คือให้คำนวณสีจากชื่อเอง
  final int avatarColor;

  /// รูปโปรไฟล์จริงที่ผู้ใช้เลือกจากเครื่อง ย่อเป็น PNG ด้านละไม่เกิน 256 พิกเซล
  /// null เมื่อยังไม่ได้ใส่รูป
  final Uint8List? avatarImage;

  /// มีรูปจริงหรือไม่ ใช้ตัดสินว่าจะวาดรูปหรือวาดอีโมจิ/ตัวอักษรแทน
  bool get hasImage => avatarImage != null && avatarImage!.isNotEmpty;

  /// มีช่องทางออนไลน์อย่างน้อยหนึ่งช่องหรือไม่ ใช้ตัดสินว่าจะแสดงแถวไอคอนไหม
  bool get hasSocial =>
      instagram.isNotEmpty || lineId.isNotEmpty || facebook.isNotEmpty;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// ตัวอักษรแรกของชื่อ ใช้แสดงในวงกลม avatar
  String get initial =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  /// แปลงเป็น Map เพื่อส่งให้ sqflite เขียนลงตาราง
  /// SQLite ไม่มีชนิด bool กับ DateTime จึงเก็บเป็น 0/1 และสตริง ISO 8601
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'is_favorite': isFavorite ? 1 : 0,
      'tag': tag.label,
      // วันเกิดไม่มีเวลา จึงตัดเก็บแค่ส่วนวันที่ (10 ตัวอักษรแรกของ ISO)
      'birthday': birthday?.toIso8601String().substring(0, 10),
      'note': note,
      'instagram': instagram,
      'line_id': lineId,
      'facebook': facebook,
      'avatar_emoji': avatarEmoji,
      'avatar_color': avatarColor,
      'avatar_image': avatarImage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// สร้างจากแถวที่อ่านออกมาจากฐานข้อมูล
  factory Contact.fromMap(Map<String, Object?> map) {
    final now = DateTime.now();
    final rawBirthday = map['birthday'] as String?;

    return Contact(
      id: map['id'] as int?,
      name: (map['name'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      tag: ContactTag.fromLabel(map['tag'] as String?),
      birthday: (rawBirthday == null || rawBirthday.isEmpty)
          ? null
          : DateTime.tryParse(rawBirthday),
      note: (map['note'] as String?) ?? '',
      instagram: (map['instagram'] as String?) ?? '',
      lineId: (map['line_id'] as String?) ?? '',
      facebook: (map['facebook'] as String?) ?? '',
      avatarEmoji: (map['avatar_emoji'] as String?) ?? '',
      avatarColor: (map['avatar_color'] as int?) ?? -1,
      avatarImage: map['avatar_image'] as Uint8List?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? now,
    );
  }

  /// [clearBirthday] มีไว้เพราะส่ง birthday: null เฉย ๆ จะแปลว่า "ไม่เปลี่ยน"
  /// ทำให้ลบวันเกิดที่เคยกรอกไว้ไม่ได้ ถ้าไม่มีธงตัวนี้
  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    bool? isFavorite,
    ContactTag? tag,
    DateTime? birthday,
    bool clearBirthday = false,
    String? note,
    String? instagram,
    String? lineId,
    String? facebook,
    String? avatarEmoji,
    int? avatarColor,
    Uint8List? avatarImage,
    bool clearAvatarImage = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isFavorite: isFavorite ?? this.isFavorite,
      tag: tag ?? this.tag,
      birthday: clearBirthday ? null : (birthday ?? this.birthday),
      note: note ?? this.note,
      instagram: instagram ?? this.instagram,
      lineId: lineId ?? this.lineId,
      facebook: facebook ?? this.facebook,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      avatarColor: avatarColor ?? this.avatarColor,
      avatarImage:
          clearAvatarImage ? null : (avatarImage ?? this.avatarImage),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
