import '../models/app_settings.dart';
import '../models/contact.dart';
import '../models/contact_tag.dart';
import '../utils/birthday.dart';
import 'database_helper.dart';

/// ตัวเลขสรุปสำหรับหน้าแดชบอร์ด
class DirectoryStats {
  const DirectoryStats({
    required this.total,
    required this.favorites,
    required this.addedThisWeek,
    required this.perDay,
    required this.recent,
    required this.perTag,
    required this.upcomingBirthdays,
  });

  final int total;
  final int favorites;
  final int addedThisWeek;

  /// จำนวนรายชื่อที่เพิ่มในแต่ละวัน 7 วันย้อนหลัง เรียงจากเก่าไปใหม่
  final List<int> perDay;

  /// 5 รายชื่อล่าสุด
  final List<Contact> recent;

  /// จำนวนคนในแต่ละกลุ่ม เรียงจากมากไปน้อย เอาเฉพาะกลุ่มที่มีคนจริง
  final List<MapEntry<ContactTag, int>> perTag;

  /// คนที่ใกล้ถึงวันเกิดภายใน 30 วัน เรียงจากใกล้ที่สุด
  final List<Contact> upcomingBirthdays;
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
    ContactTag? tag,
    ContactSort sort = ContactSort.newest,
  }) async {
    final db = await _helper.database;

    final where = <String>[];
    final args = <Object?>[];

    final keyword = query.trim();
    if (keyword.isNotEmpty) {
      // ค้นบันทึกย่อด้วย จะได้หาคนจากสิ่งที่จำได้ เช่น "เจอที่งานสัมมนา"
      where.add('(name LIKE ? OR phone LIKE ? OR email LIKE ? OR note LIKE ?)');
      final pattern = '%$keyword%';
      args.addAll([pattern, pattern, pattern, pattern]);
    }
    if (favoritesOnly) {
      where.add('is_favorite = 1');
    }
    if (tag != null) {
      where.add('tag = ?');
      args.add(tag.label);
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

  /// นับจำนวนรายชื่อโดยไม่ต้องอ่านทุกแถวขึ้นมา
  ///
  /// แถบข้างต้องการแค่ตัวเลข การดึงทั้งตารางมานับใน Dart จะเปลืองเกินจำเป็น
  /// จึงให้ SQLite นับให้ด้วย COUNT(*) แล้วส่งกลับมาแถวเดียว
  Future<int> count({bool favoritesOnly = false}) async {
    final db = await _helper.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM ${DatabaseHelper.tableContacts}'
      '${favoritesOnly ? ' WHERE is_favorite = 1' : ''}',
    );
    return (rows.first['total'] as int?) ?? 0;
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

  /// ลบหลายคนพร้อมกันในคำสั่งเดียว
  ///
  /// สร้างเครื่องหมายคำถามให้เท่าจำนวนรหัสที่ส่งมา แล้วผูกค่าทีละตัว
  /// ไม่ได้ต่อรหัสเข้าไปในข้อความคำสั่งตรง ๆ เพื่อกันข้อมูลแปลกปลอม
  Future<int> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return 0;

    final db = await _helper.database;
    final placeholders = List.filled(ids.length, '?').join(', ');
    return db.delete(
      DatabaseHelper.tableContacts,
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  /// เขียนหลายคนกลับคืนพร้อมกัน ใช้ตอนกดเลิกทำหลังลบหลายรายการ
  Future<void> insertMany(List<Contact> contacts) async {
    final db = await _helper.database;

    final batch = db.batch();
    for (final contact in contacts) {
      batch.insert(DatabaseHelper.tableContacts, contact.toMap());
    }
    await batch.commit(noResult: true);
  }

  /// ลบทุกรายชื่อในสมุด ใช้จากหน้าตั้งค่าเท่านั้นและต้องยืนยันก่อนเสมอ
  /// คืนจำนวนแถวที่ลบไป เพื่อเอาไปบอกผู้ใช้ว่าลบไปกี่คน
  Future<int> deleteAll() async {
    final db = await _helper.database;
    return db.delete(DatabaseHelper.tableContacts);
  }

  /// รวบรวมตัวเลขทั้งหมดที่หน้าแดชบอร์ดต้องใช้ในการอ่านฐานข้อมูลรอบเดียว
  ///
  /// [birthdayWindowDays] คือช่วงที่นับว่า "ใกล้ถึง" ผู้ใช้ปรับได้ในหน้าตั้งค่า
  Future<DirectoryStats> loadStats({int birthdayWindowDays = 30}) async {
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

    final recent = await getContacts(sort: ContactSort.newest);

    final tagCounts = <ContactTag, int>{};
    for (final contact in all) {
      tagCounts.update(contact.tag, (v) => v + 1, ifAbsent: () => 1);
    }
    final perTag = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // เอาเฉพาะคนที่กรอกวันเกิดไว้ และวันเกิดรอบถัดไปอยู่ภายใน 30 วัน
    final upcoming = all.where((c) => c.birthday != null).toList()
      ..removeWhere(
          (c) => Birthday.daysUntil(c.birthday!) > birthdayWindowDays)
      ..sort((a, b) => Birthday.daysUntil(a.birthday!)
          .compareTo(Birthday.daysUntil(b.birthday!)));

    return DirectoryStats(
      total: all.length,
      favorites: all.where((c) => c.isFavorite).length,
      addedThisWeek: perDay.fold(0, (sum, n) => sum + n),
      perDay: perDay,
      recent: recent.take(5).toList(),
      perTag: perTag,
      upcomingBirthdays: upcoming.take(5).toList(),
    );
  }
}
