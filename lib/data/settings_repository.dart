import 'package:sqflite/sqflite.dart';

import '../models/app_settings.dart';
import 'database_helper.dart';

/// อ่านและเขียนค่าตั้งค่าลงตาราง settings
///
/// เขียนทีละคี่ย์ด้วย ConflictAlgorithm.replace จึงไม่ต้องเช็กก่อนว่าเคยมีหรือยัง
class SettingsRepository {
  SettingsRepository({DatabaseHelper? helper})
      : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  Future<AppSettings> load() async {
    final db = await _helper.database;
    final rows = await db.query(DatabaseHelper.tableSettings);

    final map = <String, String>{
      for (final row in rows)
        (row['key'] as String): (row['value'] as String),
    };

    return AppSettings.fromMap(map);
  }

  Future<void> save(AppSettings settings) async {
    final db = await _helper.database;

    // เขียนทุกคีย์ในชุดเดียวกันด้วย batch เพื่อไม่ให้ค่าครึ่ง ๆ กลาง ๆ
    // ถ้าเกิดปัญหาระหว่างทาง
    final batch = db.batch();
    settings.toMap().forEach((key, value) {
      batch.insert(
        DatabaseHelper.tableSettings,
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit(noResult: true);
  }
}
