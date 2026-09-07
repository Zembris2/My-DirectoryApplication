/// แปลงเวลาเป็นข้อความสั้น ๆ แบบ "เมื่อ 3 ชั่วโมงก่อน"
///
/// ผู้ใช้อ่านระยะเวลาที่ผ่านมาเข้าใจเร็วกว่าวันที่เต็ม ๆ เมื่อเป็นของที่เพิ่งเกิด
/// ถ้าเกิน 7 วันไปแล้วค่อยกลับไปบอกเป็นวันที่ เพราะจำนวนวันเริ่มนึกภาพไม่ออก
String timeAgo(DateTime time, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final diff = current.difference(time);

  if (diff.isNegative || diff.inMinutes < 1) {
    return 'เมื่อสักครู่';
  }
  if (diff.inHours < 1) {
    return 'เมื่อ ${diff.inMinutes} นาทีก่อน';
  }
  if (diff.inDays < 1) {
    return 'เมื่อ ${diff.inHours} ชั่วโมงก่อน';
  }
  if (diff.inDays < 7) {
    return 'เมื่อ ${diff.inDays} วันก่อน';
  }
  return '${time.day}/${time.month}/${time.year}';
}
