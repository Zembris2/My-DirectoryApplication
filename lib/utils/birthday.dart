/// ฟังก์ชันคำนวณเรื่องวันเกิด แยกออกมาไว้ที่เดียวเพราะทั้งหน้ารายการ
/// และหน้าแดชบอร์ดต้องใช้ตรรกะชุดเดียวกัน
class Birthday {
  const Birthday._();

  /// เหลืออีกกี่วันถึงวันเกิดรอบถัดไป (0 = วันนี้)
  ///
  /// เทียบเฉพาะวันกับเดือน ไม่สนใจปีเกิด ถ้าวันเกิดปีนี้ผ่านไปแล้ว
  /// จะนับต่อไปเป็นวันเกิดของปีหน้าแทน
  static int daysUntil(DateTime birthday, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);

    var next = DateTime(today.year, birthday.month, birthday.day);
    if (next.isBefore(today)) {
      next = DateTime(today.year + 1, birthday.month, birthday.day);
    }

    return next.difference(today).inDays;
  }

  /// อายุที่จะครบในวันเกิดรอบถัดไป
  static int ageOnNextBirthday(DateTime birthday, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final thisYear = DateTime(today.year, birthday.month, birthday.day);
    final year = thisYear.isBefore(today) ? today.year + 1 : today.year;
    return year - birthday.year;
  }

  /// ข้อความสั้นบอกว่าใกล้วันเกิดแค่ไหน ใช้แสดงบนป้ายในการ์ด
  static String countdownLabel(DateTime birthday, {DateTime? now}) {
    final days = daysUntil(birthday, now: now);
    if (days == 0) return 'วันเกิดวันนี้';
    if (days == 1) return 'วันเกิดพรุ่งนี้';
    return 'อีก $days วัน';
  }

  /// วันที่แบบไทยย่อ พร้อมปี พ.ศ. เช่น "5 ก.ย. 2569"
  static String formatThai(DateTime date) {
    const months = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }
}
