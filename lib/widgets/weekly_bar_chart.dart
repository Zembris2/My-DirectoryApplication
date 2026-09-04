import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// กราฟแท่งแสดงจำนวนรายชื่อที่เพิ่มในแต่ละวัน 7 วันย้อนหลัง
///
/// วาดเองด้วย Container ธรรมดา ไม่พึ่งไลบรารีกราฟภายนอก
/// ความสูงของพื้นที่กราฟถูกกำหนดตายตัวและให้ตัวแท่งใช้ Expanded
/// เพื่อไม่ให้ล้นกรอบเมื่อจอเตี้ย
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key, required this.values});

  /// ค่า 7 ช่อง เรียงจากเก่าไปใหม่ ช่องสุดท้ายคือวันนี้
  final List<int> values;

  static const double _chartHeight = 132;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<int>(0, (m, v) => v > m ? v : m);
    final labels = _weekdayLabels();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('เพิ่มรายชื่อ 7 วันล่าสุด',
                style: Theme.of(context).textTheme.titleMedium),
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
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$value',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          // ความสูงสูงสุดของแท่ง = พื้นที่กราฟ ลบที่ของตัวเลขและป้ายวัน
                          SizedBox(
                            height: (_chartHeight - 46) * ratio + 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isToday ? AppColors.primary : AppColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.gap),
                          Text(
                            labels[i],
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
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
