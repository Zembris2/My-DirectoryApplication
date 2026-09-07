import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// บนมือถือใช้ปลั๊กอินตัวเดียวเสมอ ไม่ต้องเลือกโหมดเหมือนเว็บ
String webDatabaseMode = 'ปลั๊กอิน sqflite';

/// ฝั่งมือถือและเดสก์ท็อป sqflite ตั้งค่า factory ให้เองอยู่แล้ว
/// จึงไม่ต้องทำอะไรเพิ่ม แต่คงฟังก์ชันไว้ให้ main.dart เรียกเหมือนกันทุกแพลตฟอร์ม
Future<void> initDatabaseFactory() async {}

/// บนมือถือต้องระบุที่อยู่ไฟล์ฐานข้อมูลเต็ม ๆ
/// โดยเอามาจากโฟลเดอร์มาตรฐานที่ระบบจัดไว้ให้
Future<String> resolveDatabasePath(String fileName) async {
  final dir = await getDatabasesPath();
  return p.join(dir, fileName);
}
