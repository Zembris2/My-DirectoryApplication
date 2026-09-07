import 'package:flutter/material.dart';

/// ธีมกลางของแอป
///
/// เลือกพื้นหลังเป็นน้ำเงินเข้ม (navy) ไม่ใช่ดำสนิท เพราะดำสนิทคู่กับตัวอักษรสีขาว
/// ให้ค่า contrast สูงเกินไปจนอ่านนาน ๆ แล้วล้า ส่วนสีตัวอักษรทุกคู่ในไฟล์นี้
/// ผ่านเกณฑ์ contrast ขั้นต่ำ 4.5:1 ตามมาตรฐาน WCAG AA
class AppColors {
  const AppColors._();

  /// พื้นหลังหลัก
  static const Color background = Color(0xFF0F172A);

  /// ผิวการ์ดชั้นที่ 1 และ 2 ไล่ระดับขึ้นทีละขั้นเพื่อให้เห็นลำดับความลึก
  static const Color surface = Color(0xFF1A2438);
  static const Color surfaceHigh = Color(0xFF243147);

  static const Color primary = Color(0xFF60A5FA);
  static const Color accent = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFF87171);
  static const Color success = Color(0xFF34D399);

  /// สีเสริมสำหรับหัวข้อและป้ายต่าง ๆ ให้หน้าจอมีสีสันมากกว่าฟ้าอย่างเดียว
  /// ทุกสีเลือกความสว่างใกล้เคียงกัน วางคู่กันแล้วจึงไม่มีสีไหนตะโกนกว่าเพื่อน
  static const Color violet = Color(0xFFA78BFA);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color pink = Color(0xFFF472B6);
  static const Color orange = Color(0xFFFB923C);
  static const Color teal = Color(0xFF2DD4BF);

  static const Color textPrimary = Color(0xFFE8EDF7);
  static const Color textSecondary = Color(0xFFA3B0C7);
  static const Color divider = Color(0xFF2E3A52);

  /// จานสีสำหรับกลุ่มผู้ติดต่อ ผู้ใช้เลือกเองได้ตอนสร้างกลุ่มใหม่
  ///
  /// เก็บลงฐานข้อมูลเป็นลำดับในจานสี ไม่ใช่รหัสสีดิบ ๆ
  /// เพราะถ้าวันหลังปรับโทนสีทั้งแอป กลุ่มที่ผู้ใช้สร้างไว้จะเปลี่ยนตามไปด้วย
  static const List<Color> tagPalette = [
    textSecondary,
    danger,
    success,
    primary,
    accent,
    violet,
    cyan,
    pink,
    orange,
    teal,
  ];

  /// สีวงกลม avatar เลือกจากชื่อ ทำให้คนคนเดิมได้สีเดิมทุกครั้งที่เปิดแอป
  /// ช่วยให้กวาดสายตาหาคนในรายการยาว ๆ ได้เร็วกว่าดูตัวอักษรอย่างเดียว
  static const List<Color> avatarPalette = [
    primary,
    success,
    accent,
    danger,
    violet,
    cyan,
    pink,
    orange,
    teal,
  ];

  /// เลือกสีจากผลรวมรหัสตัวอักษรของชื่อ ไม่ใช่การสุ่ม
  /// เพราะต้องได้สีเดิมเสมอแม้ปิดแอปแล้วเปิดใหม่
  static Color avatarColor(String name) {
    if (name.isEmpty) return avatarPalette.first;
    final sum = name.codeUnits.fold<int>(0, (total, unit) => total + unit);
    return avatarPalette[sum % avatarPalette.length];
  }
}

/// ระยะห่างมาตรฐาน ใช้ค่าเดียวกันทั้งแอปเพื่อให้จังหวะการเว้นสม่ำเสมอ
/// ปุ่มที่กดได้ต้องห่างกันอย่างน้อย [gap] เพื่อลดการกดพลาด
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double gap = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double radius = 16;

  /// ความกว้างสูงสุดของเนื้อหา
  ///
  /// บนจอคอมพิวเตอร์ถ้าปล่อยให้การ์ดยืดเต็มจอ บรรทัดจะยาวจนกวาดตาอ่านลำบาก
  /// จึงคุมความกว้างไว้แล้วจัดกลางจอแทน
  static const double maxContentWidth = 840;

  /// จอที่กว้างกว่านี้ถือว่าเป็นจอใหญ่ ให้เปลี่ยนเมนูล่างเป็นเมนูข้าง
  static const double wideBreakpoint = 800;

  /// จอที่แคบกว่านี้ต้องลดจำนวนคอลัมน์ของการ์ดตัวเลขลง ไม่งั้นตัวเลขจะบีบจนอ่านยาก
  static const double narrowBreakpoint = 400;

  /// จอที่กว้างกว่านี้ แถบข้างกางออกโชว์ชื่อเมนูเต็ม ไม่ใช่แค่ไอคอน
  static const double extendedRailBreakpoint = 1080;

  /// จอที่กว้างกว่านี้ จัดเนื้อหาเป็นสองคอลัมน์ได้โดยแต่ละคอลัมน์ยังไม่แคบเกินไป
  static const double twoColumnBreakpoint = 880;

  /// ความกว้างสูงสุดของหน้าที่จัดสองคอลัมน์
  static const double maxWideContentWidth = 1200;
}

/// ไล่สีที่ใช้ซ้ำได้ทั้งแอป
class AppGradients {
  const AppGradients._();

  /// ไล่สีของแถบสรุปด้านบนแดชบอร์ด ไล่จากน้ำเงินไปม่วง
  static const LinearGradient header = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2B4A7E), Color(0xFF4C3D8C)],
  );

  /// ไล่สีอ่อน ๆ จากสีที่ส่งเข้ามา ใช้เป็นพื้นหลังการ์ดให้แต่ละใบมีสีของตัวเอง
  static LinearGradient tint(Color color) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withValues(alpha: 0.20),
        color.withValues(alpha: 0.05),
      ],
    );
  }
}

class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.danger,
      onPrimary: Color(0xFF0B1220),
      onSurface: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.divider,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.violet,
        foregroundColor: Color(0xFF0B1220),
      ),
      chipTheme: const ChipThemeData(
        side: BorderSide(color: AppColors.divider),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.violet.withValues(alpha: 0.24),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        bodySmall: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
