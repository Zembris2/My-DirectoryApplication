import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// บนเว็บต้องสลับ factory ไปใช้ SQLite เวอร์ชัน WebAssembly
/// ข้อมูลจะถูกเก็บใน IndexedDB ของเบราว์เซอร์ ปิดแท็บแล้วเปิดใหม่ข้อมูลยังอยู่
Future<void> initDatabaseFactory() async {
  databaseFactory = databaseFactoryFfiWeb;
}
