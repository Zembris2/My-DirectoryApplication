import 'package:sqflite/sqflite.dart';

import 'db_factory.dart';

/// จัดการการเปิดฐานข้อมูลและการอัปเกรดโครงสร้างตาราง
///
/// เก็บ instance เดียวไว้ใช้ทั้งแอป (singleton) เพราะการเปิดไฟล์ฐานข้อมูลซ้ำ ๆ
/// ทุกครั้งที่ query จะช้าและอาจชนกันเอง
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String tableContacts = 'contacts';

  /// ตารางเก็บค่าตั้งค่าของแอปแบบคีย์-ค่า
  ///
  /// ใช้ตารางแทนที่จะพึ่งแพ็กเกจเก็บค่านอกฐานข้อมูล เพราะข้อมูลทุกอย่างของแอป
  /// จะได้อยู่ในไฟล์เดียวกัน สำรองหรือย้ายเครื่องทีเดียวจบ
  static const String tableSettings = 'settings';

  /// เวอร์ชัน 1 มี 4 คอลัมน์ (id, name, phone, email)
  /// เวอร์ชัน 2 เพิ่ม is_favorite, created_at, updated_at รวมเป็น 7 คอลัมน์
  /// เวอร์ชัน 3 เพิ่ม tag, birthday, note รวมเป็น 10 คอลัมน์
  /// เวอร์ชัน 4 เพิ่มช่องทางติดต่อออนไลน์ กับรูปโปรไฟล์ และเพิ่มตาราง settings
  /// เวอร์ชัน 5 เพิ่ม avatar_image สำหรับรูปโปรไฟล์จริงที่ผู้ใช้เลือกจากเครื่อง
  static const int _dbVersion = 5;

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final path = await resolveDatabasePath('my_directory.db');
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableContacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        tag TEXT NOT NULL DEFAULT 'ทั่วไป',
        birthday TEXT,
        note TEXT NOT NULL DEFAULT '',
        instagram TEXT NOT NULL DEFAULT '',
        line_id TEXT NOT NULL DEFAULT '',
        facebook TEXT NOT NULL DEFAULT '',
        avatar_emoji TEXT NOT NULL DEFAULT '',
        avatar_color INTEGER NOT NULL DEFAULT -1,
        avatar_image BLOB,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await _createSettings(db);
  }

  Future<void> _createSettings(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableSettings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  /// อัปเกรดโครงสร้างโดยไม่ลบตารางเดิม
  ///
  /// ใช้ ALTER TABLE เพิ่มคอลัมน์ทีละตัว รายชื่อที่ผู้ใช้บันทึกไว้ตอนเวอร์ชันเก่า
  /// จึงยังอยู่ครบ ส่วนแถวเดิมที่ยังไม่มีค่าวันที่ จะเติมเวลาปัจจุบันให้
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final now = DateTime.now().toIso8601String();
      await db.execute(
        'ALTER TABLE $tableContacts ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        "ALTER TABLE $tableContacts ADD COLUMN created_at TEXT NOT NULL DEFAULT ''",
      );
      await db.execute(
        "ALTER TABLE $tableContacts ADD COLUMN updated_at TEXT NOT NULL DEFAULT ''",
      );
      await db.update(
        tableContacts,
        {'created_at': now, 'updated_at': now},
        where: "created_at = '' OR created_at IS NULL",
      );
    }

    if (oldVersion < 3) {
      // แถวเดิมยังไม่เคยเลือกกลุ่ม จึงตั้งค่าเริ่มต้นเป็น "ทั่วไป" ให้ทุกคน
      await db.execute(
        "ALTER TABLE $tableContacts ADD COLUMN tag TEXT NOT NULL DEFAULT 'ทั่วไป'",
      );
      // วันเกิดไม่บังคับกรอก จึงปล่อยให้เป็น NULL ได้ ต่างจากคอลัมน์อื่น
      await db.execute(
        'ALTER TABLE $tableContacts ADD COLUMN birthday TEXT',
      );
      await db.execute(
        "ALTER TABLE $tableContacts ADD COLUMN note TEXT NOT NULL DEFAULT ''",
      );
    }

    if (oldVersion < 4) {
      // ช่องทางออนไลน์ทั้งสามไม่บังคับกรอก ตั้งค่าเริ่มต้นเป็นข้อความว่าง
      // แถวเดิมจึงไม่ต้องแก้อะไรเลย
      for (final column in ['instagram', 'line_id', 'facebook']) {
        await db.execute(
          "ALTER TABLE $tableContacts ADD COLUMN $column TEXT NOT NULL DEFAULT ''",
        );
      }
      await db.execute(
        "ALTER TABLE $tableContacts ADD COLUMN avatar_emoji TEXT NOT NULL DEFAULT ''",
      );
      // -1 แปลว่ายังไม่ได้เลือกสีเอง ให้คำนวณสีจากชื่อเหมือนเดิม
      await db.execute(
        'ALTER TABLE $tableContacts ADD COLUMN avatar_color INTEGER NOT NULL DEFAULT -1',
      );
      await _createSettings(db);
    }

    if (oldVersion < 5) {
      // เก็บไฟล์รูปเป็น BLOB ในแถวเดียวกับคนคนนั้น ย่อขนาดมาก่อนแล้วตั้งแต่ตอนเลือก
      // จึงไม่ทำให้ไฟล์ฐานข้อมูลบวมจนช้า และปล่อยว่างได้เพราะไม่บังคับใส่รูป
      await db.execute(
        'ALTER TABLE $tableContacts ADD COLUMN avatar_image BLOB',
      );
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
