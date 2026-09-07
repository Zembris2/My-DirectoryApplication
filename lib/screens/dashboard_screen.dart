import 'package:flutter/material.dart';

import '../data/contact_repository.dart';
import '../models/contact.dart';
import '../theme/app_theme.dart';
import '../utils/relative_time.dart';
import '../widgets/birthday_card.dart';
import '../widgets/content_width.dart';
import '../widgets/empty_state.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/more_menu.dart';
import '../widgets/summary_header.dart';
import '../widgets/tag_breakdown_card.dart';
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
    required this.animationEpoch,
    required this.birthdayWindowDays,
    required this.onOpenManual,
    required this.onOpenSettings,
  });

  final ContactRepository repository;
  final int dataVersion;

  /// เปลี่ยนค่าทุกครั้งที่ผู้ใช้เปิดเข้าแท็บนี้ ทำให้การ์ดถูกสร้างใหม่
  /// แล้วเล่นภาพเคลื่อนไหวโผล่เข้าซ้ำ เหมือนเพิ่งเปิดหน้าครั้งแรก
  final int animationEpoch;

  /// ช่วงมองล่วงหน้าของการ์ดวันเกิด ผู้ใช้ปรับได้ในหน้าตั้งค่า
  final int birthdayWindowDays;

  final VoidCallback onOpenManual;
  final VoidCallback onOpenSettings;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DirectoryStats? _stats;

  /// ข้อความผิดพลาดจากฐานข้อมูล ถ้าไม่ว่างจะแสดงแทนตัวเลขสรุป
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataVersion != widget.dataVersion ||
        oldWidget.birthdayWindowDays != widget.birthdayWindowDays) {
      _load();
    }
  }

  Future<void> _load() async {
    // จับข้อผิดพลาดไว้เหมือนหน้ารายชื่อ เพื่อไม่ให้หน้าจอค้างที่วงกลมโหลด
    try {
      final stats = await widget.repository.loadStats(
        birthdayWindowDays: widget.birthdayWindowDays,
      );
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แดชบอร์ด'),
        actions: [
          IconButton(
            tooltip: 'โหลดตัวเลขใหม่',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
          MoreMenu(
            onOpenManual: widget.onOpenManual,
            onOpenSettings: widget.onOpenSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: ContentWidth(
          maxWidth: AppSpacing.maxWideContentWidth,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final error = _error;
    if (error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'เปิดข้อมูลไม่สำเร็จ',
        message: error,
        color: AppColors.danger,
      );
    }

    final stats = _stats;
    if (stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // แสดงการ์ดทุกใบเสมอแม้ยังไม่มีข้อมูล ต่างจากเดิมที่ซ่อนทั้งหน้า
    // เพราะผู้ใช้ควรเห็นตั้งแต่แรกว่าแดชบอร์ดสรุปอะไรให้บ้าง
    return RefreshIndicator(
      onRefresh: _load,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final twoColumn =
              constraints.maxWidth >= AppSpacing.twoColumnBreakpoint;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            children: [
              if (stats.total == 0) ...[
                const _HintBanner(),
                const SizedBox(height: AppSpacing.sm),
              ],
              // จอกว้างแบ่งเป็นสองคอลัมน์ ไม่งั้นการ์ดจะเรียงยาวลงไปจนต้องเลื่อนนาน
              // ทั้งที่พื้นที่ด้านข้างยังว่างอยู่
              if (twoColumn)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Column(children: _staggered(_primaryCards(stats)))),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Column(children: _staggered(_secondaryCards(stats)))),
                  ],
                )
              else
                ..._staggered([..._primaryCards(stats), ..._secondaryCards(stats)]),
            ],
          );
        },
      ),
    );
  }

  /// ห่อการ์ดให้ไล่โผล่ทีละใบ ข้ามช่องว่างระหว่างการ์ดไปเพราะไม่มีอะไรให้ดู
  List<Widget> _staggered(List<Widget> cards) {
    var step = 0;
    return [
      for (final card in cards)
        if (card is SizedBox)
          card
        else
          FadeSlideIn(
            // key ผูกกับรอบการเข้าแท็บ พอค่าเปลี่ยน Flutter จะสร้างใหม่
            // ภาพเคลื่อนไหวจึงเล่นซ้ำทุกครั้งที่กลับเข้ามาดู
            key: ValueKey('${widget.animationEpoch}-$step'),
            delay: Duration(milliseconds: 60 * step++),
            child: card,
          ),
    ];
  }

  /// การ์ดกลุ่มแรก ตัวเลขภาพรวมที่ต้องเห็นก่อน
  List<Widget> _primaryCards(DirectoryStats stats) {
    return [
      SummaryHeader(
        total: stats.total,
        favorites: stats.favorites,
        addedThisWeek: stats.addedThisWeek,
      ),
      const SizedBox(height: AppSpacing.sm),
      WeeklyBarChart(values: stats.perDay),
      const SizedBox(height: AppSpacing.sm),
    ];
  }

  /// การ์ดกลุ่มที่สอง รายละเอียดที่ดูต่อเมื่อสนใจ
  List<Widget> _secondaryCards(DirectoryStats stats) {
    return [
      BirthdayCard(
        contacts: stats.upcomingBirthdays,
        windowDays: widget.birthdayWindowDays,
      ),
      const SizedBox(height: AppSpacing.sm),
      TagBreakdownCard(entries: stats.perTag),
      const SizedBox(height: AppSpacing.sm),
      _RecentCard(recent: stats.recent),
    ];
  }
}

/// คำแนะนำที่ขึ้นเฉพาะตอนยังไม่มีรายชื่อสักคน
class _HintBanner extends StatelessWidget {
  const _HintBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: AppColors.accent),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'ตัวเลขทั้งหมดยังเป็น 0 อยู่ '
                'ลองเพิ่มรายชื่อในแท็บ "รายชื่อ" แล้วกลับมาดูอีกครั้ง',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// การ์ดแสดงรายชื่อที่เพิ่มล่าสุด พร้อมบอกว่าเพิ่มไปนานแค่ไหนแล้ว
class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.recent});

  final List<Contact> recent;

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
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.gap),
                child: Text(
                  'ยังไม่มีรายชื่อในสมุด',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              ...recent.map((contact) => _RecentRow(contact: contact)),
          ],
        ),
      ),
    );
  }
}

/// หนึ่งบรรทัดในการ์ด "เพิ่มล่าสุด"
class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        contact.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (contact.isFavorite) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(Icons.star, size: 13, color: AppColors.accent),
                    ],
                  ],
                ),
                Text(
                  contact.phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.gap),
          Text(
            timeAgo(contact.createdAt),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
