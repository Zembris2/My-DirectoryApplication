import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// จัดการการเปิดฐานข้อมูลและการอัปเกรดโครงสร้างตาราง
///
/// เก็บ instance เดียวไว้ใช้ทั้งแอป (singleton) เพราะการเปิดไฟล์ฐานข้อมูลซ้ำ ๆ
/// ทุกครั้งที่ query จะช้าและอาจชนกันเอง
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String tableContacts = 'contacts';

  /// เวอร์ชัน 1 มี 4 คอลัมน์ (id, name, phone, email)
  /// เวอร์ชัน 2 เพิ่ม is_favorite, created_at, updated_at รวมเป็น 7 คอลัมน์
  static const int _dbVersion = 2;

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      p.join(dbPath, 'my_directory.db'),
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
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
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
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
