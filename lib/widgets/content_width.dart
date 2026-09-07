import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// คุมความกว้างของเนื้อหาแล้วจัดไว้กลางจอ
///
/// บนมือถือจะไม่มีผลอะไรเลยเพราะจอแคบกว่าค่าที่กำหนดอยู่แล้ว
/// แต่บนเว็บหรือแท็บเล็ต ถ้าปล่อยให้การ์ดยืดเต็มจอ ชื่อกับเบอร์จะถูกดันไปคนละฝั่ง
/// จนต้องกวาดตาไกลเกินไป
class ContentWidth extends StatelessWidget {
  const ContentWidth({
    super.key,
    required this.child,
    this.maxWidth = AppSpacing.maxContentWidth,
  });

  final Widget child;

  /// หน้าที่จัดเนื้อหาเป็นสองคอลัมน์ต้องการที่มากกว่าหน้าฟอร์มที่อ่านเป็นบรรทัดเดียว
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
