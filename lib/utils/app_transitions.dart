import 'package:flutter/material.dart';

/// การเปลี่ยนหน้าและจังหวะเวลาที่ใช้ร่วมกันทั้งแอป
///
/// รวมไว้ที่เดียวเพื่อให้ทุกหน้าขยับด้วยความเร็วและเส้นโค้งเดียวกัน
/// ถ้าแต่ละที่ตั้งเองจะรู้สึกเหมือนคนละแอปมาต่อกัน
class AppMotion {
  const AppMotion._();

  /// สั้นสำหรับสิ่งที่ตอบสนองการกด เช่น ปุ่มเปลี่ยนสี
  static const Duration fast = Duration(milliseconds: 180);

  /// กลางสำหรับการเปลี่ยนหน้าและการ์ดโผล่เข้ามา
  static const Duration medium = Duration(milliseconds: 280);

  /// ยาวสำหรับกราฟที่ต้องค่อย ๆ วิ่งขึ้นให้ตาตามทัน
  static const Duration slow = Duration(milliseconds: 650);

  /// ออกตัวเร็วแล้วค่อย ๆ หยุด ให้ความรู้สึกว่ามีน้ำหนักจริง
  static const Curve curve = Curves.easeOutCubic;

  /// ผู้ใช้บางคนตั้งระบบให้ปิดภาพเคลื่อนไหว เพราะเวียนหัวหรือแพ้การขยับ
  /// ทุกที่ที่มี animation ต้องเช็กค่านี้ก่อนเสมอ
  static bool disabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// เส้นทางเปิดหน้าใหม่ เลื่อนเข้ามาจากขวาพร้อมจางเข้า
  ///
  /// ทิศทางบอกความสัมพันธ์ของหน้า หน้าใหม่มาจากขวาแปลว่าลึกเข้าไปอีกชั้น
  /// กดย้อนกลับก็จะเลื่อนออกไปทางเดิม ผู้ใช้จึงไม่หลงว่าตัวเองอยู่ตรงไหน
  static Route<T> slideRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: medium,
      reverseTransitionDuration: fast,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondary, child) {
        if (disabled(context)) return child;

        final eased = CurvedAnimation(parent: animation, curve: curve);
        return FadeTransition(
          opacity: eased,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(eased),
            child: child,
          ),
        );
      },
    );
  }
}
