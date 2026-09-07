import 'package:flutter/material.dart';

import '../models/contact_tag.dart';
import '../theme/app_theme.dart';
import '../utils/app_transitions.dart';

/// สัดส่วนคนในแต่ละกลุ่ม แสดงเป็นแถบเดียวต่อกันคล้ายกราฟแท่งซ้อน
///
/// ใช้แถบเดียวแทนหลายแถบ เพราะสิ่งที่อยากให้เห็นคือ "สัดส่วนของทั้งสมุด"
/// ไม่ใช่การเทียบกลุ่มต่อกลุ่ม
class TagBreakdownCard extends StatelessWidget {
  const TagBreakdownCard({super.key, required this.entries});

  /// จำนวนคนในแต่ละกลุ่ม เรียงจากมากไปน้อยมาแล้ว
  final List<MapEntry<ContactTag, int>> entries;

  @override
  Widget build(BuildContext context) {
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'สัดส่วนตามกลุ่ม',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (total == 0)
              Text(
                'ยังไม่มีข้อมูลกลุ่ม',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.xs),
                child: SizedBox(
                  height: 12,
                  // ยืดออกจากซ้ายไปขวา ตรงกับลำดับที่ตาอ่านแถบนี้
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: AppMotion.disabled(context)
                        ? Duration.zero
                        : AppMotion.slow,
                    curve: AppMotion.curve,
                    builder: (context, value, child) => Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: value.clamp(0.001, 1),
                      child: child,
                    ),
                    child: Row(
                    children: entries
                        .map(
                          (entry) => Expanded(
                            // flex ต้องเป็นจำนวนเต็ม จึงใช้จำนวนคนเป็นน้ำหนักตรง ๆ
                            flex: entry.value,
                            child: Container(color: entry.key.color),
                          ),
                        )
                        .toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.gap,
                children: entries
                    .map((entry) => _Legend(entry: entry, total: total))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// คำอธิบายสีหนึ่งรายการใต้แถบ
class _Legend extends StatelessWidget {
  const _Legend({required this.entry, required this.total});

  final MapEntry<ContactTag, int> entry;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = (entry.value / total * 100).round();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: entry.key.color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '${entry.key.label} ${entry.value} ($percent%)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
