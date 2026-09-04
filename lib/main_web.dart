/// จุดเริ่มต้นสำหรับรันบนเว็บ (flutter run -d chrome -t lib/main_web.dart)
/// ใช้โค้ดชุดเดียวกับ main.dart ทั้งหมด ต่างกันแค่ database factory
/// ที่ถูกสลับให้อัตโนมัติใน data/db_factory.dart
library;

import 'main.dart' as app;

Future<void> main() => app.main();
