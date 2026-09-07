import 'contact_tag.dart';

/// ลำดับการเรียงรายชื่อ ย้ายมาไว้ที่นี่เพราะทั้งหน้ารายการและหน้าตั้งค่าต้องใช้
enum ContactSort { newest, name }

/// ค่าตั้งค่าทั้งหมดของแอป
///
/// เก็บลงตาราง settings เป็นคู่คีย์-ค่า ทุกค่าจึงต้องแปลงเป็นข้อความได้
/// และต้องมีค่าเริ่มต้นเสมอ เผื่อเปิดแอปครั้งแรกที่ยังไม่เคยบันทึกอะไรเลย
class AppSettings {
  const AppSettings({
    this.defaultTag = ContactTag.general,
    this.defaultSort = ContactSort.newest,
    this.birthdayWindowDays = 30,
    this.confirmBeforeDelete = true,
    this.showNoteOnCard = true,
  });

  /// กลุ่มที่เลือกไว้ให้ล่วงหน้าเมื่อเปิดฟอร์มเพิ่มคนใหม่
  final ContactTag defaultTag;

  /// การเรียงลำดับที่ใช้ตอนเปิดหน้ารายชื่อครั้งแรก
  final ContactSort defaultSort;

  /// มองไปข้างหน้ากี่วันในการ์ดวันเกิดที่ใกล้ถึง
  final int birthdayWindowDays;

  /// ถามยืนยันก่อนลบหรือไม่ ปิดได้สำหรับคนที่ลบทีละหลายคน
  /// เพราะยังมีปุ่มเลิกทำรับไว้อีกชั้นอยู่แล้ว
  final bool confirmBeforeDelete;

  /// แสดงบันทึกย่อบนการ์ดในหน้ารายการหรือไม่
  final bool showNoteOnCard;

  /// ตัวเลือกของช่วงเตือนวันเกิดที่ให้เลือกในหน้าตั้งค่า
  static const List<int> birthdayWindowChoices = [7, 14, 30, 60];

  AppSettings copyWith({
    ContactTag? defaultTag,
    ContactSort? defaultSort,
    int? birthdayWindowDays,
    bool? confirmBeforeDelete,
    bool? showNoteOnCard,
  }) {
    return AppSettings(
      defaultTag: defaultTag ?? this.defaultTag,
      defaultSort: defaultSort ?? this.defaultSort,
      birthdayWindowDays: birthdayWindowDays ?? this.birthdayWindowDays,
      confirmBeforeDelete: confirmBeforeDelete ?? this.confirmBeforeDelete,
      showNoteOnCard: showNoteOnCard ?? this.showNoteOnCard,
    );
  }

  /// แปลงเป็นคู่คีย์-ค่าสำหรับเขียนลงตาราง
  Map<String, String> toMap() {
    return {
      'default_tag': defaultTag.label,
      'default_sort': defaultSort.name,
      'birthday_window_days': '$birthdayWindowDays',
      'confirm_before_delete': confirmBeforeDelete ? '1' : '0',
      'show_note_on_card': showNoteOnCard ? '1' : '0',
    };
  }

  /// อ่านกลับจากตาราง คีย์ไหนหายไปให้ใช้ค่าเริ่มต้นของคีย์นั้น
  /// จึงเพิ่มค่าตั้งค่าใหม่ได้โดยไม่ต้องย้ายข้อมูลเดิม
  factory AppSettings.fromMap(Map<String, String> map) {
    const fallback = AppSettings();

    return AppSettings(
      defaultTag: ContactTag.fromLabel(map['default_tag']),
      defaultSort: ContactSort.values.firstWhere(
        (sort) => sort.name == map['default_sort'],
        orElse: () => fallback.defaultSort,
      ),
      birthdayWindowDays: int.tryParse(map['birthday_window_days'] ?? '') ??
          fallback.birthdayWindowDays,
      confirmBeforeDelete:
          map['confirm_before_delete'] != '0',
      showNoteOnCard: map['show_note_on_card'] != '0',
    );
  }
}
