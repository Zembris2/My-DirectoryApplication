import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// หนึ่งขั้นตอนในคู่มือ ใช้กับเนื้อหาที่ต้องทำเรียงตามลำดับจริง ๆ
class ManualStep {
  const ManualStep(this.title, this.detail);

  final String title;
  final String detail;
}

/// หนึ่งบรรทัดแบบหัวข้อ-คำอธิบาย ใช้กับเนื้อหาที่ไม่มีลำดับ
class ManualRow {
  const ManualRow(this.term, this.detail);

  final String term;
  final String detail;
}

/// หนึ่งคำถามที่พบบ่อย กดแล้วกางคำตอบ
class ManualFaq {
  const ManualFaq(this.question, this.answer);

  final String question;
  final String answer;
}

/// การ์ดหัวข้อหนึ่งเรื่องในหน้าคู่มือ
///
/// รับเนื้อหาได้ 3 แบบ แล้วแสดงคนละหน้าตากัน เพราะรูปแบบการจัดวางควรบอกความหมาย
/// อะไรที่เรียงเป็นลำดับใช้เลขกำกับ อะไรที่เป็นรายการเฉย ๆ ไม่ต้องมีเลขให้เข้าใจผิด
/// ส่วนคำถามที่พบบ่อยพับเก็บไว้ก่อน จะได้ไม่กินที่ตอนยังไม่มีปัญหา
class ManualCard extends StatelessWidget {
  const ManualCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.steps = const [],
    this.rows = const [],
    this.faqs = const [],
    this.note,
    this.initiallyExpanded = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final List<ManualStep> steps;
  final List<ManualRow> rows;
  final List<ManualFaq> faqs;

  /// ข้อความปิดท้ายในกรอบสี ใช้กับเรื่องที่คนพลาดกันบ่อย
  final String? note;

  /// กางไว้ตั้งแต่เปิดหน้าหรือไม่ ปกติกางเฉพาะหัวข้อแรก
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // ตัดเส้นคั่นเริ่มต้นของ ExpansionTile ออก ให้ขอบการ์ดเป็นตัวคั่นแทน
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: color,
          collapsedIconColor: AppColors.textSecondary,
          leading: Container(
            padding: const EdgeInsets.all(AppSpacing.gap),
            decoration: BoxDecoration(
              gradient: AppGradients.tint(color),
              borderRadius: BorderRadius.circular(AppSpacing.gap),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            _summary,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          children: [
            for (var i = 0; i < steps.length; i++)
              _StepTile(index: i + 1, step: steps[i], color: color),
            for (final row in rows) _RowTile(row: row, color: color),
            for (final faq in faqs) _FaqTile(faq: faq),
            if (note != null) ...[
              const SizedBox(height: AppSpacing.gap),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: AppGradients.tint(color),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 15, color: color),
                    const SizedBox(width: AppSpacing.gap),
                    Expanded(
                      child: Text(
                        note!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// บรรทัดใต้หัวข้อ บอกว่าข้างในมีกี่รายการ ผู้ใช้จะได้เดาได้ว่าคุ้มจะกางไหม
  String get _summary {
    if (steps.isNotEmpty) return '${steps.length} ขั้นตอน';
    if (faqs.isNotEmpty) return '${faqs.length} คำถาม';
    return '${rows.length} หัวข้อ';
  }
}

/// ขั้นตอนหนึ่งข้อ พร้อมเลขกำกับในวงกลม
class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.index,
    required this.step,
    required this.color,
  });

  final int index;
  final ManualStep step;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(step.title,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(step.detail,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// บรรทัดหัวข้อ-คำอธิบาย มีจุดสีนำหน้าแทนเลข
class _RowTile extends StatelessWidget {
  const _RowTile({required this.row, required this.color});

  final ManualRow row;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            // เว้นระยะบนให้จุดตรงกับบรรทัดแรกของข้อความพอดี
            margin: const EdgeInsets.only(top: 7, right: AppSpacing.sm),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(row.term, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(row.detail,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// คำถามที่พับเก็บไว้ กดแล้วกางคำตอบ
class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});

  final ManualFaq faq;

  @override
  Widget build(BuildContext context) {
    return Theme(
      // ตัดเส้นคั่นเริ่มต้นของ ExpansionTile ออก ให้เข้ากับการ์ดที่ไม่มีเส้นแบ่ง
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: AppSpacing.gap),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        iconColor: AppColors.textSecondary,
        collapsedIconColor: AppColors.textSecondary,
        title: Text(faq.question, style: Theme.of(context).textTheme.bodyMedium),
        children: [
          Text(faq.answer, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
