import 'package:flutter/material.dart';

import '../data/contact_repository.dart';
import 'contacts_screen.dart';
import 'dashboard_screen.dart';

/// โครงหลักของแอป ทำหน้าที่สลับหน้าจอผ่านแถบเมนูล่าง 2 แท็บ
///
/// เก็บ repository ไว้ที่นี่ที่เดียวแล้วส่งต่อให้ทั้งสองหน้า
/// เมื่อหน้ารายชื่อมีการเปลี่ยนแปลงข้อมูล จะสั่งให้แดชบอร์ดโหลดตัวเลขใหม่
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final ContactRepository _repository = ContactRepository();

  int _index = 0;

  /// เพิ่มค่าทุกครั้งที่ข้อมูลเปลี่ยน ใช้เป็นสัญญาณให้แดชบอร์ดรีเฟรช
  int _dataVersion = 0;

  void _handleDataChanged() {
    setState(() => _dataVersion++);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ContactsScreen(
        repository: _repository,
        onDataChanged: _handleDataChanged,
      ),
      DashboardScreen(
        repository: _repository,
        dataVersion: _dataVersion,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
            label: 'รายชื่อ',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'แดชบอร์ด',
          ),
        ],
      ),
    );
  }
}
