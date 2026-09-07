import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_transitions.dart';

/// หนึ่งเมนูในแถบข้าง
class SidebarItem {
  const SidebarItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.color,
    this.badge,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// สีประจำเมนู ใช้ทั้งไอคอนตอนเลือกและแถบไฮไลต์
  final Color color;

  /// ตัวเลขมุมขวาของเมนู เช่น จำนวนรายชื่อ ถ้าไม่มีให้เป็น null
  final String? badge;
}

/// แถบเมนูข้างสำหรับจอกว้าง
///
/// เขียนเองแทน NavigationRail สำเร็จรูป เพราะต้องการ 3 อย่างที่ตัวสำเร็จรูปทำไม่ได้
/// คือหัวแถบที่บอกชื่อแอป ป้ายตัวเลขท้ายเมนู และแถบสีของเมนูที่เลือกอยู่
///
/// [extended] จริงเมื่อจอกว้างพอจะโชว์ชื่อเมนู ถ้าแคบกว่านั้นเหลือแต่ไอคอน
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.extended,
    required this.footer,
  });

  final List<SidebarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool extended;

  /// ข้อความบรรทัดล่างสุด ใช้บอกที่เก็บข้อมูล
  final String footer;

  @override
  Widget build(BuildContext context) {
    // ยืดหดตามความกว้างหน้าต่างแบบค่อยเป็นค่อยไป
    // ถ้ากระโดดทันทีจะเหมือนหน้าจอกระตุกตอนลากขอบหน้าต่าง
    return AnimatedContainer(
      duration: AppMotion.medium,
      curve: AppMotion.curve,
      width: extended ? 232 : 84,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Brand(extended: extended),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppSpacing.sm),
            ...List.generate(items.length, (index) {
              return _SidebarTile(
                item: items[index],
                active: index == selectedIndex,
                extended: extended,
                onTap: () => onSelected(index),
              );
            }),
            const Spacer(),
            if (extended) ...[
              const Divider(height: 1, color: AppColors.divider),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    const Icon(
                      Icons.storage_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.gap),
                    Expanded(
                      child: Text(
                        footer,
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
}

/// หัวแถบข้าง โลโก้กับชื่อแอป
class _Brand extends StatelessWidget {
  const _Brand({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppGradients.header,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: const Icon(Icons.contacts, color: Colors.white, size: 22),
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: extended
          ? Row(
              children: [
                logo,
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'สมุดรายชื่อ',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'ดิจิทัล',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(child: logo),
    );
  }
}

/// ปุ่มเมนูหนึ่งอันในแถบข้าง
class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.active,
    required this.extended,
    required this.onTap,
  });

  final SidebarItem item;
  final bool active;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? item.color : AppColors.textSecondary;
    final badge = item.badge;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.curve,
        decoration: BoxDecoration(
          color:
              active ? item.color.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: extended ? AppSpacing.sm : 0,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: extended
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  // แถบสีด้านซ้ายบอกว่าเมนูไหนถูกเลือกอยู่ เห็นชัดกว่าสีไอคอนอย่างเดียว
                  if (extended)
                    AnimatedContainer(
                      duration: AppMotion.fast,
                      curve: AppMotion.curve,
                      width: 3,
                      height: active ? 20 : 8,
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: active ? item.color : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  Icon(
                    active ? item.selectedIcon : item.icon,
                    color: color,
                    size: 22,
                  ),
                  if (extended) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: active ? item.color : AppColors.textPrimary,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (badge != null) _Badge(text: badge, color: color),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ป้ายตัวเลขท้ายเมนู
class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.gap, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppSpacing.gap),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
