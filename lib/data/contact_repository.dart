import '../models/contact.dart';
import 'database_helper.dart';

/// ลำดับการเรียงรายชื่อที่ผู้ใช้สลับได้จากหน้ารายการ
enum ContactSort { newest, name }

/// ตัวเลขสรุปสำหรับหน้าแดชบอร์ด
class DirectoryStats {
  const DirectoryStats({
    required this.total,
    required this.favorites,
    required this.addedThisWeek,
    required this.perDay,
    required this.topInitials,
    required this.recent,
  });

  final int total;
  final int favorites;
  final int addedThisWeek;

  /// จำนวนรายชื่อที่เพิ่มในแต่ละวัน 7 วันย้อนหลัง เรียงจากเก่าไปใหม่
  final List<int> perDay;

  /// อักษรขึ้นต้นที่พบบ่อย เรียงจากมากไปน้อย
  final List<MapEntry<String, int>> topInitials;

  /// 3 รายชื่อล่าสุด
  final List<Contact> recent;
}

/// ชั้นกลางระหว่างหน้าจอกับฐานข้อมูล
///
/// หน้าจอเรียกเมธอดในคลาสนี้อย่างเดียว ไม่ต้องรู้จัก SQL เลย
/// ถ้าวันหลังเปลี่ยนไปใช้ฐานข้อมูลอื่น แก้แค่ไฟล์นี้ไฟล์เดียว
class ContactRepository {
  ContactRepository({DatabaseHelper? helper})
      : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  /// ดึงรายชื่อตามเงื่อนไขค้นหา / กรองรายการโปรด / การเรียงลำดับ
  ///
  /// ใช้ LIKE ค้นทั้งชื่อ เบอร์ และอีเมลในคำสั่งเดียว และผูกค่าด้วย ? เสมอ
  /// เพื่อกัน SQL injection จากข้อความที่ผู้ใช้พิมพ์
  Future<List<Contact>> getContacts({
    String query = '',
    bool favoritesOnly = false,
    ContactSort sort = ContactSort.newest,
  }) async {
    final db = await _helper.database;

    final where = <String>[];
    final args = <Object?>[];

    final keyword = query.trim();
    if (keyword.isNotEmpty) {
      where.add('(name LIKE ? OR phone LIKE ? OR email LIKE ?)');
      final pattern = '%$keyword%';
      args.addAll([pattern, pattern, pattern]);
    }
    if (favoritesOnly) {
      where.add('is_favorite = 1');
    }

    final rows = await db.query(
      DatabaseHelper.tableContacts,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: switch (sort) {
        ContactSort.newest => 'datetime(created_at) DESC, id DESC',
        ContactSort.name => 'name COLLATE NOCASE ASC',
      },
    );

    return rows.map(Contact.fromMap).toList();
  }

  Future<int> insert(Contact contact) async {
    final db = await _helper.database;
    return db.insert(DatabaseHelper.tableContacts, contact.toMap());
  }

  Future<int> update(Contact contact) async {
    final db = await _helper.database;
    return db.update(
      DatabaseHelper.tableContacts,
      contact.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _helper.database;
    return db.delete(
      DatabaseHelper.tableContacts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleFavorite(Contact contact) async {
    return update(contact.copyWith(isFavorite: !contact.isFavorite));
  }

  /// รวบรวมตัวเลขทั้งหมดที่หน้าแดชบอร์ดต้องใช้ในการอ่านฐานข้อมูลรอบเดียว
  Future<DirectoryStats> loadStats() async {
    final all = await getContacts();

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    // นับจำนวนต่อวันย้อนหลัง 7 วัน ช่องสุดท้ายคือวันนี้
    final perDay = List<int>.filled(7, 0);
    for (final contact in all) {
      final created = contact.createdAt;
      final day = DateTime(created.year, created.month, created.day);
      final diff = startOfToday.difference(day).inDays;
      if (diff >= 0 && diff < 7) {
        perDay[6 - diff]++;
      }
    }

    final counts = <String, int>{};
    for (final contact in all) {
      counts.update(contact.initial, (v) => v + 1, ifAbsent: () => 1);
    }
    final topInitials = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final recent = await getContacts(sort: ContactSort.newest);

    return DirectoryStats(
      total: all.length,
      favorites: all.where((c) => c.isFavorite).length,
      addedThisWeek: perDay.fold(0, (sum, n) => sum + n),
      perDay: perDay,
      topInitials: topInitials.take(5).toList(),
      recent: recent.take(3).toList(),
    );
  }
}
