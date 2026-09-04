/// เลือก database factory ให้เหมาะกับแพลตฟอร์มตอนคอมไพล์
///
/// - มือถือ / เดสก์ท็อป ใช้ sqflite ตัวปกติ (db_factory_io.dart)
/// - เว็บ ใช้ sqflite_common_ffi_web ที่รัน SQLite ผ่าน WebAssembly
///
/// การใช้ conditional export ทำให้โค้ดฝั่งเว็บไม่ถูกคอมไพล์ตอน build มือถือ
/// และกลับกัน จึงไม่ต้องแยกไฟล์ main คนละชุด
export 'db_factory_io.dart' if (dart.library.js_interop) 'db_factory_web.dart';
