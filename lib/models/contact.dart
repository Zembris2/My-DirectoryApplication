/// โครงข้อมูลผู้ติดต่อ 1 คน ตรงกับ 1 แถวในตาราง contacts
class Contact {
  const Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// null เมื่อยังไม่เคยบันทึกลงฐานข้อมูล (SQLite จะออกเลขให้เอง)
  final int? id;
  final String name;
  final String phone;
  final String email;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// ตัวอักษรแรกของชื่อ ใช้แสดงในวงกลม avatar
  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  /// แปลงเป็น Map เพื่อส่งให้ sqflite เขียนลงตาราง
  /// SQLite ไม่มีชนิด bool กับ DateTime จึงเก็บเป็น 0/1 และสตริง ISO 8601
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// สร้างจากแถวที่อ่านออกมาจากฐานข้อมูล
  factory Contact.fromMap(Map<String, Object?> map) {
    final now = DateTime.now();
    return Contact(
      id: map['id'] as int?,
      name: (map['name'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? now,
    );
  }

  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
