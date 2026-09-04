import 'package:flutter/material.dart';

import '../data/contact_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_bar_chart.dart';

/// หน้าสรุปภาพรวมของสมุดรายชื่อ
///
/// โหลดตัวเลขใหม่ทุกครั้งที่ [dataVersion] เปลี่ยน ซึ่งหน้าแม่จะเพิ่มค่าให้
/// เมื่อมีการเพิ่ม แก้ไข หรือลบรายชื่อ
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.repository,
    required this.dataVersion,
  });

  final ContactRepository repository;
  final int dataVersion;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DirectoryStats? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataVersion != widget.dataVersion) {
      _load();
    }
  }

  Future<void> _load() async {
    final stats = await widget.repository.loadStats();
    if (!mounted) return;
    setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;

    return Scaffold(
      appBar: AppBar(title: const Text('แดชบอร์ด')),
      body: SafeArea(
        child: stats == null
            ? const Center(child: CircularProgressIndicator())
            : stats.total == 0
                ? const EmptyState(
                    icon: Icons.insights_outlined,
                    title: 'ยังไม่มีข้อมูลให้สรุป',
                    message: 'เพิ่มรายชื่อในแท็บ "รายชื่อ" แล้วกลับมาดูอีกครั้ง',
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: StatCard(
                                label: 'รายชื่อทั้งหมด',
                                value: stats.total,
                                icon: Icons.groups_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: StatCard(
                                label: 'รายการโปรด',
                                value: stats.favorites,
                                icon: Icons.star_border,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: StatCard(
                                label: 'เพิ่มใน 7 วัน',
                                value: stats.addedThisWeek,
                                icon: Icons.trending_up,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        WeeklyBarChart(values: stats.perDay),
                        const SizedBox(height: AppSpacing.sm),
                        _InitialsCard(entries: stats.topInitials),
                        const SizedBox(height: AppSpacing.sm),
                        _RecentCard(stats: stats),
                      ],
                    ),
                  ),
      ),
    );
  }
}

/// การ์ดแสดงอักษรขึ้นต้นชื่อที่พบบ่อยที่สุด
class _InitialsCard extends StatelessWidget {
  const _InitialsCard({required this.entries});

  final List<MapEntry<String, int>> entries;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('อักษรขึ้นต้นที่พบบ่อย',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.gap,
              runSpacing: AppSpacing.gap,
              children: entries
                  .map(
                    (entry) => Chip(
                      backgroundColor: AppColors.surfaceHigh,
                      side: const BorderSide(color: AppColors.divider),
                      label: Text('${entry.key}  ·  ${entry.value}'),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// การ์ดแสดง 3 รายชื่อที่เพิ่มล่าสุด
class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.stats});

  final DirectoryStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('เพิ่มล่าสุด', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.gap),
            ...stats.recent.map(
              (contact) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.gap),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.18),
                      child: Text(
                        contact.initial,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        contact.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      contact.phone,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
