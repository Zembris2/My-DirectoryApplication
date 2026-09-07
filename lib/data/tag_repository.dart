import 'package:sqflite/sqflite.dart';

import '../models/contact_tag.dart';
import 'database_helper.dart';

/// อ่านและเขียนกลุ่มผู้ติดต่อ
class TagRepository {
  TagRepository({DatabaseHelper? helper})
      : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  /// อ่านกลุ่มทั้งหมดตามลำดับที่ตั้งไว้ แล้วอัปเดตรายการกลางให้ทั้งแอปใช้ร่วมกัน
  Future<List<ContactTag>> load() async {
    final db = await _helper.database;
    final rows =
        await db.query(DatabaseHelper.tableTags, orderBy: 'sort_order');

    final tags = rows.map(ContactTag.fromMap).toList();
    if (tags.isNotEmpty) ContactTag.all = tags;
    return tags;
  }

  /// เพิ่มหรือแก้ไขกลุ่ม
  ///
  /// [previousLabel] ใส่มาเมื่อเป็นการเปลี่ยนชื่อกลุ่ม เพราะชื่อคือคีย์หลัก
  /// การเปลี่ยนชื่อจึงต้องย้ายแถวเดิมทิ้งและย้ายคนในกลุ่มนั้นตามไปด้วย
  Future<void> save(ContactTag tag, {String? previousLabel}) async {
    final db = await _helper.database;
    final renaming = previousLabel != null && previousLabel != tag.label;

    await db.transaction((txn) async {
      final existing = await txn.query(
        DatabaseHelper.tableTags,
        columns: ['sort_order'],
        where: 'label = ?',
        whereArgs: [previousLabel ?? tag.label],
      );
      final order = existing.isEmpty
          ? await _nextOrder(txn)
          : (existing.first['sort_order'] as int?) ?? 0;

      if (renaming) {
        await txn.delete(
          DatabaseHelper.tableTags,
          where: 'label = ?',
          whereArgs: [previousLabel],
        );
        // ย้ายคนที่อยู่กลุ่มชื่อเดิมมาใช้ชื่อใหม่ ไม่งั้นจะกลายเป็นกลุ่มที่ไม่มีอยู่จริง
        await txn.update(
          DatabaseHelper.tableContacts,
          {'tag': tag.label},
          where: 'tag = ?',
          whereArgs: [previousLabel],
        );
      }

      await txn.insert(
        DatabaseHelper.tableTags,
        tag.toMap(order),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    await load();
  }

  /// ลบกลุ่ม แล้วย้ายคนที่อยู่กลุ่มนั้นไปกลุ่มทั่วไป
  ///
  /// ไม่ลบผู้ติดต่อตามไปด้วยเด็ดขาด เพราะผู้ใช้ตั้งใจจะลบแค่กลุ่ม
  /// การเผลอลบคนทิ้งด้วยคือความเสียหายที่กู้กลับไม่ได้
  Future<void> delete(ContactTag tag) async {
    if (tag.isBuiltin) return;

    final db = await _helper.database;
    await db.transaction((txn) async {
      await txn.delete(
        DatabaseHelper.tableTags,
        where: 'label = ?',
        whereArgs: [tag.label],
      );
      await txn.update(
        DatabaseHelper.tableContacts,
        {'tag': ContactTag.general.label},
        where: 'tag = ?',
        whereArgs: [tag.label],
      );
    });

    await load();
  }

  /// นับจำนวนคนในแต่ละกลุ่ม ใช้เตือนก่อนลบว่ากลุ่มนี้มีคนอยู่กี่คน
  Future<Map<String, int>> countByTag() async {
    final db = await _helper.database;
    final rows = await db.rawQuery(
      'SELECT tag, COUNT(*) AS total FROM ${DatabaseHelper.tableContacts} '
      'GROUP BY tag',
    );

    return {
      for (final row in rows)
        (row['tag'] as String? ?? ''): (row['total'] as int? ?? 0),
    };
  }

  Future<int> _nextOrder(DatabaseExecutor txn) async {
    final rows = await txn.rawQuery(
      'SELECT MAX(sort_order) AS top FROM ${DatabaseHelper.tableTags}',
    );
    return ((rows.first['top'] as int?) ?? 0) + 1;
  }
}
