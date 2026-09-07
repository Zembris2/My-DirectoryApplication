import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_transitions.dart';

/// แถบสรุปใหญ่ด้านบนสุดของแดชบอร์ด
///
/// วางตัวเลขรวมไว้ใหญ่ที่สุดในหน้า เพราะเป็นค่าที่ผู้ใช้อยากรู้ก่อนเสมอ
/// แล้วต่อด้วยแถบสัดส่วนรายการโปรด เพื่อให้เห็นภาพรวมได้โดยไม่ต้องอ่านตัวเลข
class SummaryHeader extends StatelessWidget {
  const SummaryHeader({
    super.key,
    required this.total,
    required this.favorites,
    required this.addedThisWeek,
  });

  final int total;
  final int favorites;
  final int addedThisWeek;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : favorites / total;
    final percent = (ratio * 100).round();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        // ไล่สีน้ำเงินไปม่วง ให้แถบสรุปเด่นกว่าการ์ดใบอื่นในหน้าเดียวกัน
        decoration: const BoxDecoration(gradient: AppGradients.header),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'รายชื่อในสมุดทั้งหมด',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          // ตัวเลขวิ่งขึ้นจากศูนย์ ดึงสายตามาที่ค่าที่สำคัญที่สุดในหน้า
                          // ใช้ปัดเศษเป็นจำนวนเต็มเสมอ จะได้ไม่เห็นทศนิยมวูบวาบ
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: total.toDouble()),
                            duration: AppMotion.disabled(context)
                                ? Duration.zero
                                : AppMotion.slow,
                            curve: AppMotion.curve,
                            builder: (context, value, _) => Text(
                              '${value.round()}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                height: 1.05,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.gap),
                          Text(
                            'รายชื่อ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _WeekBadge(addedThisWeek: addedThisWeek),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: AppColors.accent),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'รายการโปรด $favorites จาก $total',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.gap),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              // วิ่งจากศูนย์ไปหาค่าจริง ทำให้เห็นว่าสัดส่วนนี้ยาวแค่ไหน
              // ชัดกว่าการโผล่มาเป็นแถบนิ่ง ๆ ทันที
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: ratio),
                duration: AppMotion.disabled(context)
                    ? Duration.zero
                    : AppMotion.slow,
                curve: AppMotion.curve,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ป้ายมุมขวาบน บอกจำนวนที่เพิ่มในรอบ 7 วัน
class _WeekBadge extends StatelessWidget {
  const _WeekBadge({required this.addedThisWeek});

  final int addedThisWeek;

  @override
  Widget build(BuildContext context) {
    final active = addedThisWeek > 0;
    final color = active ? AppColors.success : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.gap,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.trending_up : Icons.remove,
            size: 14,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '+$addedThisWeek ใน 7 วัน',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
