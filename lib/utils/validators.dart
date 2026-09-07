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

  /// เบอร์โทรไม่บังคับกรอก แต่ถ้ากรอกต้องมีตัวเลขอย่างน้อย 9 หลัก
  ///
  /// นับเฉพาะตัวเลข จึงพิมพ์ขีดหรือเว้นวรรคคั่นได้
  /// ที่ปล่อยว่างได้เพราะบางคนเรารู้จักผ่านช่องทางออนไลน์อย่างเดียว
  /// ไม่เคยมีเบอร์ของเขาเลย การบังคับกรอกจะทำให้ต้องใส่เลขมั่ว ๆ ลงไปแทน
  static String? phone(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) return 'เบอร์โทรต้องมีตัวเลขอย่างน้อย 9 หลัก';
    return null;
  }

  /// อีเมลไม่บังคับกรอก แต่ถ้ากรอกต้องอยู่ในรูปแบบที่ถูกต้อง
  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    if (!_emailPattern.hasMatch(text)) {
      return 'รูปแบบอีเมลไม่ถูกต้อง เช่น name@mail.com';
    }
    return null;
  }

  /// ต้องมีช่องทางติดต่ออย่างน้อยหนึ่งช่อง
  ///
  /// ปล่อยให้แต่ละช่องว่างได้ก็จริง แต่ถ้าว่างหมดทุกช่อง รายชื่อนั้นจะไม่มีประโยชน์
  /// เพราะติดต่อกลับไม่ได้เลย จึงตรวจรวมกันอีกชั้นตอนกดบันทึก
  static String? anyContact(List<String> channels) {
    final hasAny = channels.any((value) => value.trim().isNotEmpty);
    if (hasAny) return null;
    return 'ต้องกรอกช่องทางติดต่ออย่างน้อยหนึ่งช่อง '
        'เช่น เบอร์โทร อีเมล หรือช่องทางออนไลน์';
  }
}
