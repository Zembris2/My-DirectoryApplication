import 'package:flutter/material.dart';

import '../utils/app_transitions.dart';

/// ทำให้ของโผล่เข้ามาด้วยการจางเข้าพร้อมเลื่อนขึ้นเล็กน้อย
///
/// ใส่ [delay] เพิ่มขึ้นทีละนิดในรายการที่เรียงกัน จะได้เอฟเฟกต์ไล่กันเป็นระลอก
/// ซึ่งช่วยให้ตาไล่ลำดับจากบนลงล่างได้เอง ไม่ใช่ทุกอย่างเด้งมาพร้อมกันจนสับสน
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 0.08,
  });

  final Widget child;
  final Duration delay;

  /// ระยะที่เลื่อนขึ้น คิดเป็นสัดส่วนของความสูงตัวเอง
  final double offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.medium,
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
      return;
    }

    // หน่วงก่อนเริ่ม แต่ต้องเช็ก mounted ก่อนสั่งเล่น
    // เพราะผู้ใช้อาจเลื่อนผ่านจนวิดเจ็ตถูกทิ้งไปแล้ว
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.disabled(context)) return widget.child;

    final eased = CurvedAnimation(parent: _controller, curve: AppMotion.curve);

    return FadeTransition(
      opacity: eased,
      child: SlideTransition(
        position: Tween(
          begin: Offset(0, widget.offset),
          end: Offset.zero,
        ).animate(eased),
        child: widget.child,
      ),
    );
  }
}
