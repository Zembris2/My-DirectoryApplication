import 'package:flutter_test/flutter_test.dart';
import 'package:my_directory/utils/birthday.dart';

/// ทดสอบการนับถอยหลังวันเกิด
/// ส่ง now เข้าไปเองทุกเคส ผลลัพธ์จะได้ไม่เปลี่ยนตามวันที่รันเทสต์
void main() {
  final now = DateTime(2026, 9, 4);

  group('Birthday.daysUntil', () {
    test('วันเกิดตรงกับวันนี้ต้องได้ 0', () {
      expect(Birthday.daysUntil(DateTime(1998, 9, 4), now: now), 0);
    });
    test('วันเกิดพรุ่งนี้ต้องได้ 1', () {
      expect(Birthday.daysUntil(DateTime(1998, 9, 5), now: now), 1);
    });
    test('วันเกิดที่ผ่านไปแล้วต้องนับไปถึงปีหน้า', () {
      // 4 ก.ย. 2026 ถึง 3 ก.ย. 2027 คือ 364 วัน เพราะระหว่างนั้นไม่มีปีอธิกสุรทิน
      expect(Birthday.daysUntil(DateTime(1998, 9, 3), now: now), 364);
    });
  });

  group('Birthday.ageOnNextBirthday', () {
    test('วันเกิดวันนี้ต้องได้อายุที่ครบพอดีในวันนี้', () {
      expect(Birthday.ageOnNextBirthday(DateTime(1998, 9, 4), now: now), 28);
    });
    test('วันเกิดที่ผ่านไปแล้วต้องนับอายุของปีหน้า', () {
      expect(Birthday.ageOnNextBirthday(DateTime(1998, 9, 3), now: now), 29);
    });
  });

  group('Birthday.countdownLabel', () {
    test('วันนี้ต้องบอกว่าวันเกิดวันนี้', () {
      expect(
        Birthday.countdownLabel(DateTime(1998, 9, 4), now: now),
        'วันเกิดวันนี้',
      );
    });
    test('อีกหลายวันต้องบอกจำนวนวัน', () {
      expect(
        Birthday.countdownLabel(DateTime(1998, 9, 14), now: now),
        'อีก 10 วัน',
      );
    });
  });

  group('Birthday.formatThai', () {
    test('ต้องแสดงเดือนย่อไทยและปี พ.ศ.', () {
      expect(Birthday.formatThai(DateTime(1998, 9, 4)), '4 ก.ย. 2541');
    });
  });
}
