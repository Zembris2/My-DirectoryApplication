import 'package:flutter_test/flutter_test.dart';
import 'package:my_directory/utils/validators.dart';

/// ทดสอบตัวตรวจความถูกต้องของข้อมูลในฟอร์ม
/// เลือกทดสอบส่วนนี้เพราะเป็นตรรกะล้วน ไม่ต้องเปิดฐานข้อมูลจริง
void main() {
  group('Validators.name', () {
    test('ชื่อว่างต้องไม่ผ่าน', () {
      expect(Validators.name(''), isNotNull);
    });
    test('ชื่อตัวเดียวต้องไม่ผ่าน', () {
      expect(Validators.name('ก'), isNotNull);
    });
    test('ชื่อปกติต้องผ่าน', () {
      expect(Validators.name('สมชาย ใจดี'), isNull);
    });
  });

  group('Validators.phone', () {
    test('เบอร์สั้นกว่า 9 หลักต้องไม่ผ่าน', () {
      expect(Validators.phone('081234'), isNotNull);
    });
    test('เบอร์ 10 หลักต้องผ่าน', () {
      expect(Validators.phone('0812345678'), isNull);
    });
    test('มีขีดคั่นแต่ตัวเลขครบต้องผ่าน', () {
      expect(Validators.phone('081-234-5678'), isNull);
    });
  });

  group('Validators.email', () {
    test('อีเมลไม่มี @ ต้องไม่ผ่าน', () {
      expect(Validators.email('somchai.mail.com'), isNotNull);
    });
    test('อีเมลไม่มีโดเมนต้องไม่ผ่าน', () {
      expect(Validators.email('somchai@mail'), isNotNull);
    });
    test('อีเมลถูกรูปแบบต้องผ่าน', () {
      expect(Validators.email('somchai@mail.com'), isNull);
    });
  });
}
