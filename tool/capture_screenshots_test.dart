// เครื่องมือสร้างภาพหน้าจอสำหรับคู่มือการใช้งาน ไม่ใช่ชุดทดสอบของแอป
//
// วางไว้นอกโฟลเดอร์ test/ เพื่อไม่ให้ `flutter test` ปกติหยิบไปรัน
// เพราะภาพที่วาดออกมาต่างกันเล็กน้อยได้ตามเครื่องที่รัน
//
// วิธีใช้: flutter test tool/capture_screenshots_test.dart --update-goldens
// ภาพจะถูกเขียนลงโฟลเดอร์ screenshots/ ที่รากโปรเจกต์
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_directory/data/contact_repository.dart';
import 'package:my_directory/data/tag_repository.dart';
import 'package:my_directory/models/app_settings.dart';
import 'package:my_directory/models/contact.dart';
import 'package:my_directory/models/contact_tag.dart';
import 'package:my_directory/screens/contact_form_screen.dart';
import 'package:my_directory/screens/home_shell.dart';
import 'package:my_directory/screens/manual_screen.dart';
import 'package:my_directory/screens/settings_screen.dart';
import 'package:my_directory/screens/tags_screen.dart';
import 'package:my_directory/theme/app_theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// ตัวรันเทสต์ไม่มีฟอนต์ติดมาให้ ถ้าไม่โหลดเอง ตัวหนังสือจะกลายเป็นกล่องสี่เหลี่ยมทั้งภาพ
///
/// ต้องโหลดสามชุด เพราะฟอนต์ไทยของ Noto ไม่มีตัวอักษรอังกฤษกับวงเล็บ
/// จึงให้ Roboto รับช่วงต่อผ่าน fontFamilyFallback และไอคอนก็เป็นฟอนต์อีกชุดหนึ่ง
const String _thaiFont =
    '/usr/share/fonts/truetype/noto/NotoSansThai-Regular.ttf';
const String _thaiFontBold =
    '/usr/share/fonts/truetype/noto/NotoSansThai-Bold.ttf';
const String _flutterFonts = '/sdks/flutter/bin/cache/artifacts/material_fonts';

void main() {
  late ThemeData theme;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    await (FontLoader('AppThai')
          ..addFont(_readFont(_thaiFont))
          ..addFont(_readFont(_thaiFontBold)))
        .load();
    await (FontLoader('AppLatin')
          ..addFont(_readFont('$_flutterFonts/Roboto-Regular.ttf'))
          ..addFont(_readFont('$_flutterFonts/Roboto-Bold.ttf')))
        .load();
    // DejaVu มีสัญลักษณ์อย่างดาว ★ ที่ทั้งฟอนต์ไทยและ Roboto ไม่มี
    await (FontLoader('AppSymbol')
          ..addFont(_readFont('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf')))
        .load();
    await (FontLoader('AppEmoji')
          ..addFont(
              _readFont('/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(_readFont('$_flutterFonts/MaterialIcons-Regular.otf')))
        .load();

    theme = _withFonts(AppTheme.dark);

    await _seed();
  });

  testWidgets('หน้ารายชื่อ และแดชบอร์ด', (tester) async {
    await _resize(tester, const Size(1280, 860));
    await tester.pumpWidget(_app(theme, const HomeShell()));
    await _settle(tester);

    await _shoot(tester, '01-หน้ารายชื่อ');

    await tester.tap(find.text('แดชบอร์ด').last);
    await _settle(tester);
    await _shoot(tester, '02-แดชบอร์ด');
  });

  testWidgets('หน้ารายชื่อบนจอมือถือ', (tester) async {
    await _resize(tester, const Size(430, 860));
    await tester.pumpWidget(_app(theme, const HomeShell()));
    await _settle(tester);
    await _shoot(tester, '03-จอมือถือ');
  });

  testWidgets('โหมดเลือกหลายรายการ', (tester) async {
    await _resize(tester, const Size(1100, 700));
    await tester.pumpWidget(_app(theme, const HomeShell()));
    await _settle(tester);

    await tester.tap(find.byTooltip('เลือกหลายรายการ'));
    await _settle(tester);
    await tester.tap(find.text('สมชาย ใจดี'));
    await tester.tap(find.text('ณิชา พงษ์ไพศาล'));
    await _settle(tester);
    await _shoot(tester, '08-เลือกหลายรายการ');
  });

  testWidgets('ฟอร์มเพิ่มรายชื่อ', (tester) async {
    await _resize(tester, const Size(900, 1240));
    await tester.pumpWidget(_app(theme, const ContactFormScreen()));
    await _settle(tester);
    await _shoot(tester, '04-ฟอร์มเพิ่มรายชื่อ');
  });

  testWidgets('หน้าจัดการกลุ่ม', (tester) async {
    await _resize(tester, const Size(900, 560));
    await tester.pumpWidget(_app(theme, TagsScreen(onChanged: () {})));
    await _settle(tester);
    await _shoot(tester, '05-จัดการกลุ่ม');
  });

  testWidgets('หน้าตั้งค่า', (tester) async {
    await _resize(tester, const Size(900, 1180));
    await tester.pumpWidget(
      _app(
        theme,
        SettingsScreen(
          settings: const AppSettings(),
          onChanged: (_) {},
          repository: ContactRepository(),
          total: 8,
          onDataCleared: () {},
          onManageTags: () {},
        ),
      ),
    );
    await _settle(tester);
    await _shoot(tester, '06-ตั้งค่า');
  });

  testWidgets('หน้าคู่มือในแอป', (tester) async {
    await _resize(tester, const Size(900, 820));
    await tester.pumpWidget(_app(theme, const ManualScreen()));
    await _settle(tester);
    await _shoot(tester, '07-คู่มือในแอป');
  });
}

/// ยัดฟอนต์เข้าไปในทุกจุดของธีมที่กำหนดสไตล์ตัวหนังสือไว้เอง
///
/// textTheme อย่างเดียวไม่พอ เพราะหัวข้อแถบบน ป้ายในช่องกรอก และป้ายเมนูล่าง
/// ต่างก็มี TextStyle ของตัวเองที่ไม่ได้สืบทอดมาจาก textTheme
ThemeData _withFonts(ThemeData base) {
  TextStyle f(TextStyle? style) => (style ?? const TextStyle()).copyWith(
        fontFamily: 'AppThai',
        fontFamilyFallback: const ['AppLatin', 'AppSymbol', 'AppEmoji'],
      );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: 'AppThai',
      fontFamilyFallback: const ['AppLatin', 'AppSymbol', 'AppEmoji'],
    ),
    primaryTextTheme: base.primaryTextTheme.apply(
      fontFamily: 'AppThai',
      fontFamilyFallback: const ['AppLatin', 'AppSymbol', 'AppEmoji'],
    ),
    appBarTheme: base.appBarTheme.copyWith(
      titleTextStyle: f(base.appBarTheme.titleTextStyle),
      toolbarTextStyle: f(base.appBarTheme.toolbarTextStyle),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      hintStyle: f(base.inputDecorationTheme.hintStyle),
      labelStyle: f(base.inputDecorationTheme.labelStyle),
      floatingLabelStyle: f(base.inputDecorationTheme.floatingLabelStyle),
      errorStyle: f(base.inputDecorationTheme.errorStyle),
      helperStyle: f(base.inputDecorationTheme.helperStyle),
      counterStyle: f(base.inputDecorationTheme.counterStyle),
    ),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      labelTextStyle: WidgetStatePropertyAll(
        f(base.navigationBarTheme.labelTextStyle?.resolve({})),
      ),
    ),
    navigationRailTheme: base.navigationRailTheme.copyWith(
      selectedLabelTextStyle:
          f(base.navigationRailTheme.selectedLabelTextStyle),
      unselectedLabelTextStyle:
          f(base.navigationRailTheme.unselectedLabelTextStyle),
    ),
    snackBarTheme: base.snackBarTheme.copyWith(
      contentTextStyle: f(base.snackBarTheme.contentTextStyle),
    ),
    chipTheme: base.chipTheme.copyWith(labelStyle: f(base.chipTheme.labelStyle)),
    dialogTheme: base.dialogTheme.copyWith(
      titleTextStyle: f(base.dialogTheme.titleTextStyle),
      contentTextStyle: f(base.dialogTheme.contentTextStyle),
    ),
  );
}

Future<ByteData> _readFont(String path) async {
  final bytes = await File(path).readAsBytes();
  return ByteData.view(Uint8List.fromList(bytes).buffer);
}

Widget _app(ThemeData theme, Widget home) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    home: home,
  );
}

/// ตั้งขนาดจอจำลอง แล้วคืนค่าเดิมให้อัตโนมัติเมื่อจบเทสต์
Future<void> _resize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

/// รอให้งานอ่านฐานข้อมูลเสร็จจริงก่อน แล้วค่อยรอให้ภาพเคลื่อนไหวหยุด
///
/// pumpAndSettle เพียงอย่างเดียวไม่พอ เพราะมันหมุนนาฬิกาจำลอง
/// ไม่ได้ปล่อยให้งานที่รออยู่ข้างนอกอย่างการอ่าน SQLite ทำงานจนจบ
/// วงกลมโหลดจึงหมุนไม่มีวันหยุดและเทสต์จะค้าง
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

Future<void> _shoot(WidgetTester tester, String name) async {
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../screenshots/$name.png'),
  );
}

/// ใส่ข้อมูลตัวอย่างให้ภาพหน้าจอมีของให้ดู ไม่ใช่หน้าจอว่าง ๆ
Future<void> _seed() async {
  final repository = ContactRepository();
  await repository.deleteAll();
  await TagRepository().load();

  final now = DateTime.now();
  ContactTag tagOf(String label) => ContactTag.fromLabel(label);

  final people = <Contact>[
    Contact(
      name: 'สมชาย ใจดี',
      phone: '0812345678',
      email: 'somchai@example.com',
      tag: tagOf('ครอบครัว'),
      isFavorite: true,
      birthday: DateTime(1975, now.month, now.day + 3),
      note: 'พ่อ ชอบกาแฟดำ',
      lineId: 'somchai.jd',
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
    Contact(
      name: 'ณิชา พงษ์ไพศาล',
      phone: '0899876543',
      email: 'nicha@example.com',
      tag: tagOf('เพื่อน'),
      isFavorite: true,
      birthday: DateTime(2006, 4, 12),
      note: 'เพื่อนสนิทสมัยมัธยม',
      instagram: 'nicha.pw',
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 2)),
    ),
    Contact(
      name: 'อาจารย์วิชัย สอนดี',
      phone: '021234567',
      email: 'wichai@school.ac.th',
      tag: tagOf('ที่เรียน'),
      note: 'อาจารย์ที่ปรึกษาโครงงาน',
      createdAt: now.subtract(const Duration(days: 3)),
      updatedAt: now.subtract(const Duration(days: 3)),
    ),
    Contact(
      name: 'ร้านกาแฟหน้าปากซอย',
      phone: '0645551122',
      email: '',
      tag: tagOf('ทั่วไป'),
      note: 'สั่งล่วงหน้าได้ เปิด 07:00',
      facebook: 'cafe.soi',
      createdAt: now.subtract(const Duration(days: 4)),
      updatedAt: now.subtract(const Duration(days: 4)),
    ),
    Contact(
      name: 'พี่ตูน ฝ่ายบุคคล',
      phone: '0877001234',
      email: 'toon.hr@company.co.th',
      tag: tagOf('ที่ทำงาน'),
      birthday: DateTime(1990, now.month, now.day + 10),
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(days: 5)),
    ),
    Contact(
      name: 'หมอฟัน คลินิกใกล้บ้าน',
      phone: '0955443322',
      email: '',
      tag: tagOf('ทั่วไป'),
      note: 'นัดขูดหินปูนทุก 6 เดือน',
      createdAt: now.subtract(const Duration(days: 6)),
      updatedAt: now.subtract(const Duration(days: 6)),
    ),
  ];

  for (final person in people) {
    await repository.insert(person);
  }
}
