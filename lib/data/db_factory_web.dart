import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// ชื่อโหมดที่เลือกใช้ได้จริง ไว้แสดงตอนหาสาเหตุปัญหา
String webDatabaseMode = 'ยังไม่ได้เริ่ม';

/// บนเว็บต้องสลับ factory ไปใช้ SQLite เวอร์ชัน WebAssembly
/// ข้อมูลจะถูกเก็บใน IndexedDB ของเบราว์เซอร์ ปิดแท็บแล้วเปิดใหม่ข้อมูลยังอยู่
///
/// แพ็กเกจมี 3 โหมดให้เลือก ไล่จากเร็วที่สุดไปทนทานที่สุด
/// บางสภาพแวดล้อมสร้าง worker ไม่ได้ เช่น หน้าเว็บที่ถูกฝังใน iframe
/// จึงลองทีละโหมดจนกว่าจะเปิดฐานข้อมูลได้จริง แอปจะได้ไม่ล้มทั้งหน้า
Future<void> initDatabaseFactory() async {
  final candidates = <String, DatabaseFactory>{
    'shared worker': databaseFactoryFfiWeb,
    'basic worker': databaseFactoryFfiWebBasicWebWorker,
    'ไม่ใช้ worker': databaseFactoryFfiWebNoWebWorker,
  };

  final failures = <String>[];

  for (final entry in candidates.entries) {
    try {
      // เปิดฐานข้อมูลในหน่วยความจำหนึ่งครั้ง เพื่อพิสูจน์ว่าโหมดนี้ใช้ได้จริง
      // ถ้ารอจนถึงตอนเปิดฐานข้อมูลจริงค่อยพัง จะสลับ factory ไม่ทันแล้ว
      final probe = await entry.value.openDatabase(inMemoryDatabasePath);
      await probe.close();
      databaseFactory = entry.value;
      webDatabaseMode = entry.key;
      return;
    } catch (error) {
      failures.add('${entry.key}: $error');
    }
  }

  // ทุกโหมดใช้ไม่ได้ ตั้งตัวสุดท้ายไว้ให้ error ตอนเปิดจริงอ่านรู้เรื่อง
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
  webDatabaseMode = 'ใช้ไม่ได้ทุกโหมด\n${failures.join('\n')}';
}

/// เบราว์เซอร์ไม่มีระบบไฟล์ให้อ้างอิง จึงใช้ชื่อไฟล์ตรง ๆ เป็นคีย์ใน IndexedDB
/// การเรียก getDatabasesPath() บนเว็บจะได้ค่า null และทำให้เปิดฐานข้อมูลไม่สำเร็จ
Future<String> resolveDatabasePath(String fileName) async => fileName;
