/// ฟังก์ชันตรวจความถูกต้องของข้อมูลที่กรอกในฟอร์ม
///
/// คืนค่า null เมื่อผ่าน และคืนข้อความภาษาไทยเมื่อไม่ผ่าน
/// รูปแบบนี้ต่อกับ TextFormField.validator ได้โดยตรง
class Validators {
  const Validators._();

  static final RegExp _emailPattern = RegExp(
    r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
  );

  static String? name(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'กรุณากรอกชื่อ';
    if (text.length < 2) return 'ชื่อสั้นเกินไป';
    return null;
  }

  /// เบอร์โทรต้องมีตัวเลขอย่างน้อย 9 หลัก
  /// นับเฉพาะตัวเลข จึงพิมพ์ขีดหรือเว้นวรรคคั่นได้
  static String? phone(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'กรุณากรอกเบอร์โทร';
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) return 'เบอร์โทรต้องมีตัวเลขอย่างน้อย 9 หลัก';
    return null;
  }

  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'กรุณากรอกอีเมล';
    if (!_emailPattern.hasMatch(text)) return 'รูปแบบอีเมลไม่ถูกต้อง เช่น name@mail.com';
    return null;
  }
}
