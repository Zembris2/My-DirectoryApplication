import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// ข้อความที่แสดงเมื่อยังไม่มีข้อมูล หรือค้นหาแล้วไม่พบ
/// บอกผู้ใช้ให้ชัดว่าทำอะไรต่อได้ ไม่ปล่อยหน้าจอว่างเปล่า
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.color = AppColors.violet,
  });

  final IconData icon;
  final String title;
  final String message;

  /// สีของวงกลมหลังไอคอน เปลี่ยนได้เพื่อสื่ออารมณ์ต่างกัน
  /// เช่น ใช้สีแดงเมื่อเป็นข้อความแจ้งข้อผิดพลาด
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: AppGradients.tint(color),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: color),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.gap),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
