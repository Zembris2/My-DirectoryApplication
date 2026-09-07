import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/content_width.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/manual_card.dart';

/// หน้าคู่มือการใช้งานในตัวแอป
///
/// วางไว้เป็นแท็บหนึ่งเท่ากับหน้าอื่น ผู้ใช้จึงเปิดดูได้ทันทีตอนติดขัด
/// ไม่ต้องออกไปหาเอกสารข้างนอกแล้วกลับเข้ามาใหม่
class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('คู่มือการใช้งาน')),
      body: SafeArea(
        child: ContentWidth(
          maxWidth: AppSpacing.maxWideContentWidth,
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
                  const FadeSlideIn(child: _Intro()),
                  const SizedBox(height: AppSpacing.sm),
                  // จัดสองคอลัมน์เหมือนหน้าแดชบอร์ด บนจอกว้างจะได้ไม่ต้องเลื่อนยาว
                  if (twoColumn)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Column(children: _staggered(_leftCards()))),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: Column(children: _staggered(_rightCards()))),
                      ],
                    )
                  else
                    ..._staggered([..._leftCards(), ..._rightCards()]),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// ห่อการ์ดให้ไล่โผล่ทีละใบ ข้ามช่องว่างระหว่างการ์ด
  List<Widget> _staggered(List<Widget> cards) {
    var step = 0;
    return [
      for (final card in cards)
        if (card is SizedBox)
          card
        else
          FadeSlideIn(
            delay: Duration(milliseconds: 60 * step++),
            child: card,
          ),
    ];
  }

  /// คอลัมน์ซ้าย เรื่องที่ต้องรู้ก่อนเริ่มใช้
  List<Widget> _leftCards() {
    return const [
      _StepsCard(),
      SizedBox(height: AppSpacing.sm),
      _GestureCard(),
      SizedBox(height: AppSpacing.sm),
      _FilterCard(),
      SizedBox(height: AppSpacing.sm),
    ];
  }

  /// คอลัมน์ขวา รายละเอียดที่เปิดดูตอนสงสัย
  List<Widget> _rightCards() {
    return const [
      _FormCard(),
      SizedBox(height: AppSpacing.sm),
      _TagCard(),
      SizedBox(height: AppSpacing.sm),
      _DashboardCard(),
      SizedBox(height: AppSpacing.sm),
      _SettingsCard(),
      SizedBox(height: AppSpacing.sm),
      _StorageCard(),
      SizedBox(height: AppSpacing.sm),
      _TroubleCard(),
    ];
  }
}

/// หัวเรื่องบนสุด บอกว่าแอปนี้ทำอะไรได้ในหนึ่งย่อหน้า
class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(gradient: AppGradients.header),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book, color: Colors.white, size: 20),
                const SizedBox(width: AppSpacing.gap),
                Text(
                  'สมุดรายชื่อดิจิทัล',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.gap),
            const Text(
              'จดผู้ติดต่อลงฐานข้อมูล SQLite ในเครื่อง เก็บได้มากกว่าชื่อกับเบอร์ '
              'ทั้งกลุ่ม วันเกิดพร้อมนับถอยหลัง และบันทึกย่อที่ค้นหาเจอ '
              'ข้อมูลอยู่ในเครื่องทั้งหมด ไม่ส่งขึ้นเซิร์ฟเวอร์',
              style: TextStyle(color: AppColors.textPrimary, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

/// สามขั้นตอนแรกหลังเปิดแอป
class _StepsCard extends StatelessWidget {
  const _StepsCard();

  @override
  Widget build(BuildContext context) {
    return const ManualCard(
      icon: Icons.play_circle_outline,
      color: AppColors.primary,
      title: 'เริ่มต้นใช้งาน',
      initiallyExpanded: true,
      steps: [
        ManualStep(
          'เพิ่มรายชื่อคนแรก',
          'กดปุ่ม "เพิ่มรายชื่อ" มุมล่างขวา กรอกชื่อ เบอร์ อีเมล เลือกกลุ่ม แล้วกดบันทึก',
        ),
        ManualStep(
          'ติดดาวคนที่ติดต่อบ่อย',
          'แตะรูปดาวบนการ์ด แล้วใช้ปุ่มกรอง "รายการโปรด" เพื่อดูเฉพาะคนกลุ่มนั้น',
        ),
        ManualStep(
          'ดูภาพรวมที่แดชบอร์ด',
          'สลับแท็บไปดูยอดรวม กราฟ 7 วัน วันเกิดที่ใกล้ถึง และสัดส่วนแต่ละกลุ่ม',
        ),
      ],
    );
  }
}

/// ท่าที่ใช้กับการ์ดรายชื่อ
class _GestureCard extends StatelessWidget {
  const _GestureCard();

  @override
  Widget build(BuildContext context) {
    return const ManualCard(
      icon: Icons.touch_app_outlined,
      color: AppColors.violet,
      title: 'ท่าที่ใช้กับการ์ดรายชื่อ',
      rows: [
        ManualRow('แตะ', 'เปิดฟอร์มแก้ไขคนนั้น'),
        ManualRow(
          'กดค้าง',
          'เปิดเมนูคัดลอก — เบอร์ อีเมล หรือข้อมูลทั้งหมดพร้อมวางในแชต',
        ),
        ManualRow('แตะดาว', 'สลับเข้า-ออกรายการโปรด'),
        ManualRow('แตะถังขยะ', 'ลบ โดยถามยืนยันก่อนเสมอ'),
      ],
      note: 'ลบผิดคนกดปุ่ม "เลิกทำ" ในแถบข้อความด้านล่างได้ทันที '
          'รายชื่อจะกลับมาพร้อมรหัสเดิม แต่ต้องกดก่อนแถบหายไป',
    );
  }
}

/// การค้นหาและการกรอง
class _FilterCard extends StatelessWidget {
  const _FilterCard();

  @override
  Widget build(BuildContext context) {
    return const ManualCard(
      icon: Icons.search,
      color: AppColors.cyan,
      title: 'ค้นหาและกรอง',
      rows: [
        ManualRow(
          'ช่องค้นหา',
          'ค้นทันทีทุกตัวอักษร ครอบคลุมชื่อ เบอร์ อีเมล และบันทึกย่อ '
              'จำชื่อไม่ได้ก็หาจากสิ่งที่จำได้',
        ),
        ManualRow(
          'แถบกลุ่ม',
          'เลื่อนแนวนอนเลือกกลุ่ม กดกลุ่มเดิมซ้ำเพื่อยกเลิกการกรอง',
        ),
        ManualRow('รายการโปรด', 'ใช้ร่วมกับช่องค้นหาและแถบกลุ่มได้พร้อมกัน'),
        ManualRow('ปุ่มเรียงลำดับ', 'สลับระหว่างเพิ่มล่าสุด กับเรียงตามชื่อ'),
        ManualRow(
          'ปุ่มคัดลอกทั้งหมด',
          'คัดลอกทุกรายชื่อตามที่กรองอยู่ตอนนั้นเป็นข้อความก้อนเดียว',
        ),
      ],
    );
  }
}

/// กฎการกรอกข้อมูลในฟอร์ม
class _FormCard extends StatelessWidget {
  const _FormCard();

  @override
  Widget build(BuildContext context) {
    return const ManualCard(
      icon: Icons.edit_outlined,
      color: AppColors.success,
      title: 'กรอกข้อมูล',
      rows: [
        ManualRow('ชื่อ', 'ช่องเดียวที่ต้องกรอก อย่างน้อย 2 ตัวอักษร'),
        ManualRow(
          'ช่องทางติดต่อ',
          'เบอร์โทร อีเมล และช่องทางออนไลน์ ไม่บังคับทีละช่อง '
              'แต่ต้องกรอกอย่างน้อยหนึ่งช่อง ไม่งั้นจะติดต่อกลับไม่ได้เลย',
        ),
        ManualRow('กลุ่ม', 'ไม่บังคับ ถ้าไม่เลือกจะเป็น "ทั่วไป"'),
        ManualRow(
          'วันเกิด',
          'ไม่บังคับ เลือกจากปฏิทิน แสดงเป็น พ.ศ. กดกากบาทเพื่อล้างค่า',
        ),
        ManualRow('บันทึกย่อ', 'ไม่บังคับ ยาวได้ 120 ตัวอักษร และค้นหาเจอ'),
        ManualRow(
          'ช่องทางออนไลน์',
          'ไม่บังคับ กรอก Instagram, LINE ID และ Facebook ได้ '
              'ถ้ากรอกไว้จะมีไอคอนเล็ก ๆ ขึ้นบนการ์ด',
        ),
        ManualRow(
          'รูปโปรไฟล์',
          'กดปุ่มเลือกรูปจากเครื่องที่หัวฟอร์ม หรือจะเลือกเป็นอีโมจิแทนก็ได้ '
              'ถ้าไม่เลือกอะไรเลยจะใช้ตัวอักษรแรกของชื่อ',
        ),
      ],
    );
  }
}

/// เรื่องกลุ่มผู้ติดต่อ
class _TagCard extends StatelessWidget {
  const _TagCard();

  @override
  Widget build(BuildContext context) {
    return const ManualCard(
      icon: Icons.label_outline,
      color: AppColors.accent,
      title: 'กลุ่มผู้ติดต่อ',
      rows: [
        ManualRow(
          'มีให้ 5 กลุ่ม',
          'ทั่วไป ครอบครัว เพื่อน ที่ทำงาน ที่เรียน',
        ),
        ManualRow(
          'สร้างกลุ่มเองได้',
          'กดปุ่มเพิ่มกลุ่มในฟอร์ม หรือไปที่ตั้งค่าแล้วเลือกจัดการกลุ่ม '
              'ตั้งชื่อ เลือกสีและไอคอนได้เอง',
        ),
        ManualRow(
          'แก้ไขและลบ',
          'กลุ่มที่สร้างเองลบได้ ส่วน 5 กลุ่มแรกเปลี่ยนสีกับไอคอนได้แต่ลบไม่ได้ '
              'ถ้าลบกลุ่มที่มีคนอยู่ คนเหล่านั้นจะย้ายไปกลุ่มทั่วไป',
        ),
      ],
      note: 'สีของกลุ่มจะปรากฏเป็นขีดสีด้านซ้ายของการ์ดรายชื่อ '
          'และเป็นสีในกราฟสัดส่วนบนแดชบอร์ด',
    );
  }
}

/// การ์ดแต่ละใบบนแดชบอร์ดบอกอะไร
class _DashboardCard extends StatelessWidget {
  const _DashboardCard();

  @override
  Widget build(BuildContext context) {
    return const ManualCard(
      icon: Icons.insights_outlined,
      color: AppColors.teal,
      title: 'แดชบอร์ด',
      rows: [
        ManualRow('แถบสรุป', 'ยอดรวมทั้งสมุด สัดส่วนรายการโปรด และยอดเพิ่มใน 7 วัน'),
        ManualRow('กราฟ 7 วัน', 'แท่งละหนึ่งวัน แท่งขวาสุดคือวันนี้ ทำสีเข้มไว้'),
        ManualRow(
          'วันเกิดใกล้ถึง',
          'เฉพาะคนที่วันเกิดอยู่ภายใน 30 วัน บอกด้วยว่าจะครบกี่ปี',
        ),
        ManualRow('สัดส่วนตามกลุ่ม', 'แถบสีเดียวต่อกัน พร้อมจำนวนและเปอร์เซ็นต์'),
        ManualRow('เพิ่มล่าสุด', 'ห้าคนหลังสุด พร้อมเวลาแบบ "เมื่อ 3 ชั่วโมงก่อน"'),
      ],
      note: 'ดึงหน้าลงเพื่อรีเฟรช หรือกดปุ่มรีเฟรชบนแถบด้านบน '
          'ปกติตัวเลขอัปเดตเองทุกครั้งที่ข้อมูลเปลี่ยนอยู่แล้ว',
    );
  }
}

/// สิ่งที่ปรับได้ในหน้าตั้งค่า
class _SettingsCard extends StatelessWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context) {
    return const ManualCard(
      icon: Icons.settings_outlined,
      color: AppColors.violet,
      title: 'ตั้งค่า',
      rows: [
        ManualRow('กลุ่มที่เลือกไว้ให้', 'กลุ่มที่ติ๊กไว้ล่วงหน้าเมื่อเพิ่มคนใหม่'),
        ManualRow('เรียงลำดับเริ่มต้น', 'หน้ารายชื่อจะเปิดมาด้วยการเรียงแบบนี้'),
        ManualRow(
          'แสดงบันทึกย่อบนการ์ด',
          'ปิดแล้วการ์ดจะสั้นลง เห็นรายชื่อต่อหนึ่งหน้าจอมากขึ้น',
        ),
        ManualRow(
          'ถามยืนยันก่อนลบ',
          'ปิดได้ถ้าต้องลบทีละหลายคน เพราะยังมีปุ่มเลิกทำรับไว้อีกชั้น',
        ),
        ManualRow('การเตือนวันเกิด', 'เลือกได้ว่าจะมองล่วงหน้า 7, 14, 30 หรือ 60 วัน'),
        ManualRow(
          'ล้างรายชื่อทั้งหมด',
          'อยู่ในเขตอันตราย ต้องยืนยันก่อน และกดเลิกทำไม่ได้',
        ),
      ],
      note: 'เปิดหน้าตั้งค่าจากเมนูสามจุดมุมขวาบน ทุกค่ามีผลทันทีที่กด '
          'ไม่มีปุ่มบันทึกให้ต้องจำ และค่าถูกเก็บลงฐานข้อมูลจึงอยู่ถาวร',
    );
  }
}

/// ที่เก็บข้อมูล
class _StorageCard extends StatelessWidget {
  const _StorageCard();

  @override
  Widget build(BuildContext context) {
    return const ManualCard(
      icon: Icons.lock_outline,
      color: AppColors.orange,
      title: 'ข้อมูลของคุณอยู่ที่ไหน',
      rows: [
        ManualRow(
          'อยู่ในเครื่องคุณเท่านั้น',
          'ไม่มีการส่งข้อมูลขึ้นอินเทอร์เน็ต และใช้งานได้โดยไม่ต้องต่อเน็ต',
        ),
        ManualRow(
          'ปิดแอปแล้วข้อมูลยังอยู่',
          'บนมือถือข้อมูลจะอยู่จนกว่าจะถอนแอปออก',
        ),
        ManualRow(
          'ถ้าใช้ผ่านเบราว์เซอร์',
          'ข้อมูลผูกกับที่อยู่เว็บที่ใช้เปิด เปลี่ยนที่อยู่หรือเปลี่ยนเบราว์เซอร์'
              'จะเห็นเป็นสมุดเปล่า ข้อมูลไม่ได้หาย แค่คนละที่เก็บกัน',
        ),
      ],
      note: 'อยากเก็บสำรองไว้ ให้กดปุ่มคัดลอกทั้งหมดในหน้ารายชื่อ '
          'แล้ววางเก็บไว้ในโน้ตหรือส่งเข้าแชตตัวเอง',
    );
  }
}

/// ปัญหาที่พบบ่อย กดเพื่อกางดูวิธีแก้
class _TroubleCard extends StatelessWidget {
  const _TroubleCard();

  @override
  Widget build(BuildContext context) {
    return const ManualCard(
      icon: Icons.help_outline,
      color: AppColors.danger,
      title: 'แก้ปัญหาที่พบบ่อย',
      faqs: [
        ManualFaq(
          'เพิ่มรายชื่อแล้วแต่ไม่ขึ้นในรายการ',
          'ตรวจว่ามีการกรองค้างอยู่หรือเปล่า ทั้งช่องค้นหา แถบกลุ่ม และปุ่มรายการโปรด '
              'ล้างทั้งสามอย่างแล้วรายชื่อจะกลับมาครบ',
        ),
        ManualFaq(
          'รายชื่อที่เคยกรอกไว้หายไปหมด',
          'ถ้าใช้บนเบราว์เซอร์ ให้ตรวจว่าเปิดจากที่อยู่เดิมหรือไม่ '
              'เพราะข้อมูลผูกกับที่อยู่เว็บ เปลี่ยนพอร์ตแล้วจะเห็นเป็นสมุดเปล่า',
        ),
        ManualFaq(
          'กดบันทึกแล้วไม่มีอะไรเกิดขึ้น',
          'เลื่อนดูช่องกรอกด้านบน จะมีข้อความสีแดงบอกว่าช่องไหนยังไม่ผ่าน '
              'หรือถ้ายังไม่ได้กรอกช่องทางติดต่อเลยสักช่อง จะมีข้อความขึ้นด้านล่าง',
        ),
        ManualFaq(
          'แก้ข้อมูลแล้วแดชบอร์ดยังเป็นตัวเลขเดิม',
          'ดึงหน้าแดชบอร์ดลงเพื่อรีเฟรช หรือกดปุ่มรีเฟรชมุมขวาบน',
        ),
      ],
    );
  }
}
