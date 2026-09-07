import 'package:flutter/material.dart';

import '../data/contact_repository.dart';
import '../data/db_factory.dart';
import '../data/settings_repository.dart';
import '../models/app_settings.dart';
import '../utils/app_transitions.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sidebar.dart';
import 'contacts_screen.dart';
import 'dashboard_screen.dart';
import 'manual_screen.dart';
import 'settings_screen.dart';

/// โครงหลักของแอป ทำหน้าที่สลับหน้าจอ 2 แท็บ
///
/// เก็บ repository ไว้ที่นี่ที่เดียวแล้วส่งต่อให้ทั้งสองหน้า
/// เมื่อหน้ารายชื่อมีการเปลี่ยนแปลงข้อมูล จะสั่งให้แดชบอร์ดโหลดตัวเลขใหม่
///
/// จอแคบใช้แถบเมนูล่างแบบมือถือ จอกว้างสลับเป็นเมนูข้าง
/// เพราะบนจอคอมพิวเตอร์ แถบล่างจะอยู่ไกลจากสายตาและเปลืองความสูงโดยเปล่าประโยชน์
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  /// ตัวคุมจังหวะตอนสลับแท็บ เล่นใหม่ทุกครั้งที่เปลี่ยนหน้า
  ///
  /// ใช้วิธีนี้แทน AnimatedSwitcher เพราะต้องคง IndexedStack ไว้
  /// ไม่งั้นหน้ารายชื่อจะถูกสร้างใหม่ ทำให้คำค้นกับตัวกรองที่พิมพ์ไว้หายหมด
  late final AnimationController _pageController = AnimationController(
    vsync: this,
    duration: AppMotion.medium,
    value: 1,
  );

  final ContactRepository _repository = ContactRepository();
  final SettingsRepository _settingsRepository = SettingsRepository();

  /// ค่าตั้งค่าที่ใช้อยู่ เริ่มจากค่าเริ่มต้นก่อน แล้วค่อยทับด้วยค่าที่เคยบันทึกไว้
  /// หน้าจอจึงวาดได้ทันทีโดยไม่ต้องรอฐานข้อมูล
  AppSettings _settings = const AppSettings();

  int _index = 0;

  /// เพิ่มค่าทุกครั้งที่ข้อมูลเปลี่ยน ใช้เป็นสัญญาณให้แดชบอร์ดรีเฟรช
  int _dataVersion = 0;

  /// นับจำนวนครั้งที่เปิดเข้าแท็บ ใช้เป็นสัญญาณให้การ์ดเล่นภาพเคลื่อนไหวใหม่
  ///
  /// จำเป็นเพราะ IndexedStack ไม่ได้สร้างหน้าใหม่ตอนสลับกลับมา
  /// ถ้าไม่มีตัวนับนี้ ภาพเคลื่อนไหวจะเล่นแค่ครั้งแรกครั้งเดียวตลอดอายุแอป
  int _visitEpoch = 0;

  /// จำนวนที่โชว์เป็นป้ายในแถบข้าง null คือยังโหลดไม่เสร็จหรือฐานข้อมูลมีปัญหา
  int? _total;
  int? _favorites;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadCounts();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsRepository.load();
      if (!mounted) return;
      setState(() => _settings = settings);
    } catch (_) {
      // ฐานข้อมูลมีปัญหา ใช้ค่าเริ่มต้นไปก่อน หน้ารายชื่อจะรายงานปัญหาเอง
    }
  }

  /// บันทึกค่าใหม่ทันทีที่ผู้ใช้กด ไม่ต้องมีปุ่มบันทึกให้ต้องจำ
  Future<void> _updateSettings(AppSettings settings) async {
    setState(() => _settings = settings);
    await _settingsRepository.save(settings);
  }

  void _openManual() {
    Navigator.of(context).push(AppMotion.slideRoute(const ManualScreen()));
  }

  void _openSettings() {
    Navigator.of(context).push(
      AppMotion.slideRoute<void>(
        StatefulBuilder(
          // หน้าตั้งค่าต้องวาดใหม่ทุกครั้งที่ค่าเปลี่ยน แต่ตัวค่าจริงเก็บไว้ที่นี่
          // จึงให้ StatefulBuilder สั่งวาดหน้าที่ซ้อนอยู่แทน
          builder: (context, setInner) => SettingsScreen(
            settings: _settings,
            total: _total ?? 0,
            repository: _repository,
            onChanged: (settings) {
              _updateSettings(settings);
              setInner(() {});
            },
            onDataCleared: () {
              _handleDataChanged();
              setInner(() {});
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// เปลี่ยนแท็บพร้อมเล่นภาพเคลื่อนไหว กดแท็บเดิมซ้ำไม่ต้องเล่นใหม่
  void _selectTab(int index) {
    if (index == _index) return;
    setState(() {
      _index = index;
      _visitEpoch++;
    });
    _pageController.forward(from: 0);
  }

  void _handleDataChanged() {
    setState(() => _dataVersion++);
    _loadCounts();
  }

  /// อ่านเฉพาะตัวเลขให้แถบข้าง ไม่ดึงรายชื่อทั้งหมดขึ้นมา
  ///
  /// ถ้าฐานข้อมูลเปิดไม่ได้ ให้ป้ายหายไปเฉย ๆ ไม่ต้องขึ้น error ซ้ำ
  /// เพราะหน้ารายชื่อรายงานปัญหาเดียวกันอยู่แล้ว
  Future<void> _loadCounts() async {
    try {
      final total = await _repository.count();
      final favorites = await _repository.count(favoritesOnly: true);
      if (!mounted) return;
      setState(() {
        _total = total;
        _favorites = favorites;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _total = null;
        _favorites = null;
      });
    }
  }

  static const List<_Destination> _destinations = [
    _Destination(
      'รายชื่อ',
      Icons.contacts_outlined,
      Icons.contacts,
      AppColors.primary,
    ),
    _Destination(
      'แดชบอร์ด',
      Icons.insights_outlined,
      Icons.insights,
      AppColors.violet,
    ),
  ];

  /// ป้ายตัวเลขท้ายเมนูในแถบข้าง แท็บที่ไม่มีตัวเลขให้คืน null
  String? _badgeFor(int index) {
    return switch (index) {
      0 => _total?.toString(),
      1 => _favorites == null ? null : '★ $_favorites',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ContactsScreen(
        repository: _repository,
        onDataChanged: _handleDataChanged,
        dataVersion: _dataVersion,
        settings: _settings,
        onOpenManual: _openManual,
        onOpenSettings: _openSettings,
      ),
      DashboardScreen(
        repository: _repository,
        dataVersion: _dataVersion,
        animationEpoch: _visitEpoch,
        birthdayWindowDays: _settings.birthdayWindowDays,
        onOpenManual: _openManual,
        onOpenSettings: _openSettings,
      ),
    ];

    // จางเข้าพร้อมเลื่อนขึ้นนิดเดียว บอกว่าเนื้อหาเปลี่ยนชุดแล้ว
    // แต่ไม่แรงจนรู้สึกว่าต้องรอ
    final eased = CurvedAnimation(parent: _pageController, curve: AppMotion.curve);
    final stack = IndexedStack(index: _index, children: pages);

    final body = AppMotion.disabled(context)
        ? stack
        : FadeTransition(
            opacity: eased,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(eased),
              child: stack,
            ),
          );

    // LayoutBuilder ให้ความกว้างของพื้นที่จริง ไม่ใช่ขนาดหน้าต่างทั้งบาน
    // จึงยังทำงานถูกต้องถ้าวันหลังเอาหน้านี้ไปวางซ้อนในที่แคบกว่า
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= AppSpacing.wideBreakpoint;

        if (!wide) {
          return Scaffold(
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _selectTab,
              destinations: _destinations
                  .map(
                    (d) => NavigationDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: d.label,
                    ),
                  )
                  .toList(),
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              AppSidebar(
                selectedIndex: _index,
                onSelected: _selectTab,
                extended:
                    constraints.maxWidth >= AppSpacing.extendedRailBreakpoint,
                footer: 'เก็บใน SQLite · $webDatabaseMode',
                items: [
                  for (var i = 0; i < _destinations.length; i++)
                    SidebarItem(
                      label: _destinations[i].label,
                      icon: _destinations[i].icon,
                      selectedIcon: _destinations[i].selectedIcon,
                      color: _destinations[i].color,
                      badge: _badgeFor(i),
                    ),
                ],
              ),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}

/// ปลายทางหนึ่งแท็บ เก็บไว้ชุดเดียวเพื่อไม่ต้องเขียนชื่อกับไอคอนซ้ำสองที่
class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon, this.color);

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// สีประจำแท็บ ใช้ในแถบข้างเพื่อให้แยกออกจากกันได้ด้วยสี ไม่ใช่ตำแหน่งอย่างเดียว
  final Color color;
}
