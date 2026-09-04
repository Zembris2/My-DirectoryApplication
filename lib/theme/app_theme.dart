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

  static const Color textPrimary = Color(0xFFE8EDF7);
  static const Color textSecondary = Color(0xFFA3B0C7);
  static const Color divider = Color(0xFF2E3A52);
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
      cardTheme: CardTheme(
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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.18),
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
        titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        bodySmall: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
