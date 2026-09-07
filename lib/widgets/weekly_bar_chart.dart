import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_transitions.dart';

/// กราฟแท่งแสดงจำนวนรายชื่อที่เพิ่มในแต่ละวัน 7 วันย้อนหลัง
///
/// วาดเองด้วย Container ธรรมดา ไม่พึ่งไลบรารีกราฟภายนอก
/// ความสูงของพื้นที่กราฟถูกกำหนดตายตัวและให้ตัวแท่งใช้ Expanded
/// เพื่อไม่ให้ล้นกรอบเมื่อจอเตี้ย
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key, required this.values});

  /// ค่า 7 ช่อง เรียงจากเก่าไปใหม่ ช่องสุดท้ายคือวันนี้
  final List<int> values;

  static const double _chartHeight = 150;

  /// ที่ที่ต้องกันไว้ให้ตัวเลขด้านบนและป้ายวันด้านล่างของแต่ละแท่ง
  static const double _labelSpace = 52;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<int>(0, (m, v) => v > m ? v : m);
    final weekTotal = values.fold<int>(0, (sum, v) => sum + v);
    final labels = _weekdayLabels();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'เพิ่มรายชื่อ 7 วันล่าสุด',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  'รวม $weekTotal',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: _chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(values.length, (i) {
                  final value = values[i];
                  // สัดส่วนความสูงเทียบกับค่าสูงสุด ถ้ายังไม่มีข้อมูลเลยให้เป็น 0
                  final ratio = maxValue == 0 ? 0.0 : value / maxValue;
                  final isToday = i == values.length - 1;

                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$value',
                            style: TextStyle(
                              // วันที่ยังไม่มีข้อมูลให้จางลง สายตาจะได้พุ่งไปที่วันที่มีค่า
                              color: value == 0
                                  ? AppColors.divider
                                  : AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight:
                                  isToday ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          // ความสูงสูงสุดของแท่ง = พื้นที่กราฟ ลบที่ของตัวเลขและป้ายวัน
                          // บวก 4 ไว้เสมอ เพื่อให้วันที่ค่าเป็น 0 ยังเห็นเป็นขีดบาง ๆ
                          //
                          // แท่งวิ่งขึ้นจากศูนย์ ไล่ทีละแท่งจากซ้ายไปขวา
                          // ให้ความรู้สึกว่าเวลาเดินไปข้างหน้าตรงกับที่กราฟสื่อ
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: ratio),
                            duration: AppMotion.disabled(context)
                                ? Duration.zero
                                : AppMotion.slow + Duration(milliseconds: 60 * i),
                            curve: AppMotion.curve,
                            builder: (context, value, child) => SizedBox(
                              height: (_chartHeight - _labelSpace) * value + 4,
                              child: child,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppColors.primary
                                    : AppColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.gap),
                          Text(
                            labels[i],
                            style: TextStyle(
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight:
                                  isToday ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (weekTotal == 0) ...[
              const SizedBox(height: AppSpacing.gap),
              Text(
                'ยังไม่มีรายชื่อที่เพิ่มในช่วง 7 วันนี้',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// ป้ายชื่อวันย่อภาษาไทย เรียงให้ช่องสุดท้ายตรงกับวันนี้
  List<String> _weekdayLabels() {
    const names = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return names[day.weekday - 1];
    });
  }
}
