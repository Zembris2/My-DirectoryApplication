import 'package:flutter/material.dart';

import 'data/db_factory.dart';
import 'screens/home_shell.dart';
import 'theme/app_theme.dart';

/// จุดเริ่มต้นของแอป
/// เตรียม database factory ให้พร้อมก่อน แล้วค่อยเปิดหน้าจอแรก
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabaseFactory();
  runApp(const MyDirectoryApp());
}

class MyDirectoryApp extends StatelessWidget {
  const MyDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'สมุดรายชื่อดิจิทัล',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeShell(),
    );
  }
}
