import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/contact_repository.dart';
import '../models/app_settings.dart';
import '../models/contact.dart';
import '../models/contact_tag.dart';
import '../theme/app_theme.dart';
import '../utils/app_transitions.dart';
import '../utils/birthday.dart';
import '../widgets/contact_card.dart';
import '../widgets/content_width.dart';
import '../widgets/empty_state.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/more_menu.dart';
import '../widgets/tag_filter_bar.dart';
import 'contact_form_screen.dart';

/// หน้ารายการรายชื่อทั้งหมด
///
/// รวมงานหลักไว้ที่นี่ ค้นหา กรองรายการโปรด กรองตามกลุ่ม เรียงลำดับ
/// เปิดฟอร์มเพิ่ม/แก้ไข ลบพร้อมกล่องยืนยันและปุ่มเลิกทำ
/// และเมนูคัดลอกข้อมูลเมื่อกดการ์ดค้าง
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({
    super.key,
    required this.repository,
    required this.onDataChanged,
    required this.dataVersion,
    required this.settings,
    required this.onOpenManual,
    required this.onOpenSettings,
  });

  /// เปิดหน้าคู่มือและหน้าตั้งค่าจากเมนูดึงลง หน้าแม่เป็นคนพาไป
  final VoidCallback onOpenManual;
  final VoidCallback onOpenSettings;

  final ContactRepository repository;

  /// ค่าตั้งค่าปัจจุบัน ใช้กำหนดการเรียงเริ่มต้น การถามยืนยันก่อนลบ
  /// และการแสดงบันทึกย่อบนการ์ด
  final AppSettings settings;

  /// แจ้งหน้าแม่เมื่อข้อมูลเปลี่ยน เพื่อให้แดชบอร์ดโหลดตัวเลขใหม่
  final VoidCallback onDataChanged;

  /// เพิ่มค่าทุกครั้งที่ข้อมูลเปลี่ยน รวมถึงตอนที่หน้าอื่นเป็นคนเปลี่ยน
  /// เช่น กดล้างข้อมูลทั้งหมดจากหน้าตั้งค่า หน้านี้จะได้โหลดรายการใหม่ตาม
  final int dataVersion;

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Contact> _contacts = [];
  bool _loading = true;
  bool _favoritesOnly = false;
  ContactTag? _tagFilter;
  late ContactSort _sort;

  /// ข้อความผิดพลาดจากฐานข้อมูล ถ้าไม่ว่างจะแสดงแทนรายการ
  String? _error;

  /// รหัสของคนที่ถูกติ๊กเลือกไว้ในโหมดเลือกหลายรายการ
  ///
  /// เก็บเป็นรหัส ไม่ใช่ตัว Contact เพราะรายการอาจถูกโหลดใหม่ระหว่างเลือกอยู่
  /// เช่นตอนพิมพ์ค้นหา ถ้าเก็บทั้งดวงไว้จะกลายเป็นข้อมูลเก่าค้าง
  final Set<int> _selectedIds = {};

  bool _selectionMode = false;

  @override
  void initState() {
    super.initState();
    _sort = widget.settings.defaultSort;
    _load();
  }

  @override
  void didUpdateWidget(covariant ContactsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // เปลี่ยนการเรียงเริ่มต้นในหน้าตั้งค่าแล้วต้องเห็นผลทันที
    // แต่ไม่ทับค่าที่ผู้ใช้เพิ่งกดสลับเองในหน้านี้
    if (oldWidget.settings.defaultSort != widget.settings.defaultSort) {
      _sort = widget.settings.defaultSort;
      _load();
      return;
    }

    // ข้อมูลถูกเปลี่ยนจากหน้าอื่น ต้องอ่านใหม่ ไม่งั้นจะยังโชว์รายการเก่าค้างอยู่
    if (oldWidget.dataVersion != widget.dataVersion) {
      _load();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// อ่านข้อมูลใหม่จากฐานข้อมูลตามเงื่อนไขที่เลือกอยู่
  Future<void> _load() async {
    // ถ้ากลุ่มที่ใช้กรองอยู่ถูกลบไปจากหน้าจัดการกลุ่ม ต้องเลิกกรอง
    // ไม่งั้นรายการจะว่างเปล่าโดยผู้ใช้ไม่รู้ว่าเพราะอะไร
    if (_tagFilter != null && !ContactTag.all.contains(_tagFilter)) {
      _tagFilter = null;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    // ถ้าฐานข้อมูลเปิดไม่ได้ ต้องจับไว้เอง ไม่งั้นวงกลมโหลดจะหมุนค้างตลอดไป
    // โดยผู้ใช้ไม่รู้เลยว่าเกิดอะไรขึ้น
    try {
      final result = await widget.repository.getContacts(
        query: _searchController.text,
        favoritesOnly: _favoritesOnly,
        tag: _tagFilter,
        sort: _sort,
      );
      if (!mounted) return;
      setState(() {
        _contacts = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  void _notify(String message, {SnackBarAction? action}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  void _enterSelection(Contact contact) {
    setState(() {
      _selectionMode = true;
      _selectedIds
        ..clear()
        ..add(contact.id!);
    });
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelected(Contact contact) {
    setState(() {
      final id = contact.id!;
      if (!_selectedIds.remove(id)) _selectedIds.add(id);
      // เอาออกจนไม่เหลือใครแล้ว ให้ออกจากโหมดเลือกเลย
      // จะได้ไม่ต้องกดปิดอีกทีทั้งที่ไม่มีอะไรให้ทำต่อ
      if (_selectedIds.isEmpty) _selectionMode = false;
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(_contacts.map((contact) => contact.id!));
    });
  }

  /// คนที่ถูกเลือกอยู่ เรียงตามลำดับที่เห็นบนหน้าจอ
  List<Contact> get _selectedContacts =>
      _contacts.where((contact) => _selectedIds.contains(contact.id)).toList();

  Future<void> _copySelected() async {
    final chosen = _selectedContacts;
    if (chosen.isEmpty) return;

    await _copy(chosen.map(_asText).join('\n\n'), 'รายชื่อ ${chosen.length} คน');
    _exitSelection();
  }

  /// ลบหลายคนพร้อมกัน ถามยืนยันเสมอไม่ว่าจะตั้งค่าไว้อย่างไร
  /// เพราะการลบทีละหลายคนพลาดแล้วเสียหายกว่าการลบทีละคนมาก
  Future<void> _deleteSelected() async {
    final chosen = _selectedContacts;
    if (chosen.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Text('ลบ ${chosen.length} รายชื่อ'),
        content: Text(
          'จะลบ ${chosen.map((c) => c.name).take(3).join(', ')}'
          '${chosen.length > 3 ? ' และอีก ${chosen.length - 3} คน' : ''} '
          'ออกจากสมุด',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await widget.repository.deleteMany(chosen.map((c) => c.id!).toList());
    _exitSelection();
    _notify(
      'ลบ ${chosen.length} รายชื่อแล้ว',
      action: SnackBarAction(
        label: 'เลิกทำ',
        onPressed: () async {
          await widget.repository.insertMany(chosen);
          widget.onDataChanged();
          await _load();
        },
      ),
    );
    widget.onDataChanged();
    await _load();
  }

  Future<void> _openForm({Contact? contact}) async {
    final result = await Navigator.of(context).push<Contact>(
      AppMotion.slideRoute(
        ContactFormScreen(
          initial: contact,
          defaultTag: widget.settings.defaultTag,
          // ปุ่มลบอยู่ในหน้ารายละเอียด ไม่ได้อยู่บนการ์ดในรายการแล้ว
          onDelete: contact == null ? null : () => _confirmDelete(contact),
        ),
      ),
    );
    if (result == null) return;

    if (result.id == null) {
      await widget.repository.insert(result);
      _notify('บันทึก "${result.name}" แล้ว');
    } else {
      await widget.repository.update(result);
      _notify('แก้ไข "${result.name}" แล้ว');
    }

    widget.onDataChanged();
    await _load();
  }

  /// ถามยืนยันก่อนลบ กันกดพลาดแล้วข้อมูลหายถาวร
  ///
  /// ปิดการถามได้จากหน้าตั้งค่า เพราะยังมีปุ่มเลิกทำรับไว้อีกชั้น
  Future<void> _confirmDelete(Contact contact) async {
    if (!widget.settings.confirmBeforeDelete) {
      await _delete(contact);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: const Text('ยืนยันการลบ'),
        content: Text('ต้องการลบ "${contact.name}" ออกจากสมุดรายชื่อหรือไม่'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _delete(contact);
  }

  /// ลบจริงพร้อมเปิดทางให้เลิกทำ แยกออกมาเพราะเรียกได้สองทาง
  /// ทั้งแบบถามยืนยันก่อนและแบบลบทันที
  Future<void> _delete(Contact contact) async {
    await widget.repository.delete(contact.id!);
    // เก็บข้อมูลทั้งแถวไว้ในตัวแปร จึงเขียนกลับคืนได้ทั้งดวงรวมถึง id เดิม
    // ถ้าผู้ใช้เพิ่งรู้ตัวว่ากดผิด
    _notify(
      'ลบ "${contact.name}" แล้ว',
      action: SnackBarAction(
        label: 'เลิกทำ',
        onPressed: () async {
          await widget.repository.insert(contact);
          widget.onDataChanged();
          await _load();
        },
      ),
    );
    widget.onDataChanged();
    await _load();
  }

  Future<void> _toggleFavorite(Contact contact) async {
    await widget.repository.toggleFavorite(contact);
    widget.onDataChanged();
    await _load();
  }

  Future<void> _copy(String text, String what) async {
    await Clipboard.setData(ClipboardData(text: text));
    _notify('คัดลอก$whatแล้ว');
  }

  /// รวมข้อมูลของคนหนึ่งคนเป็นข้อความบรรทัดเดียวจบ พร้อมวางในแชต
  String _asText(Contact contact) {
    final lines = <String>[
      contact.name,
      if (contact.phone.isNotEmpty) 'โทร: ${contact.phone}',
      if (contact.email.isNotEmpty) 'อีเมล: ${contact.email}',
      'กลุ่ม: ${contact.tag.label}',
      if (contact.instagram.isNotEmpty) 'IG: ${contact.instagram}',
      if (contact.lineId.isNotEmpty) 'LINE: ${contact.lineId}',
      if (contact.facebook.isNotEmpty) 'Facebook: ${contact.facebook}',
      if (contact.birthday != null)
        'วันเกิด: ${Birthday.formatThai(contact.birthday!)}',
      if (contact.note.isNotEmpty) 'บันทึก: ${contact.note}',
    ];
    return lines.join('\n');
  }

  /// เมนูที่ขึ้นเมื่อกดการ์ดค้าง
  Future<void> _showActions(Contact contact) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radius),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                contact.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.phone_outlined, color: AppColors.primary),
              title: const Text('คัดลอกเบอร์โทร'),
              subtitle: Text(contact.phone),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _copy(contact.phone, 'เบอร์โทร');
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline, color: AppColors.primary),
              title: const Text('คัดลอกอีเมล'),
              subtitle: Text(contact.email),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _copy(contact.email, 'อีเมล');
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_all, color: AppColors.primary),
              title: const Text('คัดลอกข้อมูลทั้งหมด'),
              subtitle: const Text('พร้อมวางในแชตได้เลย'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _copy(_asText(contact), 'ข้อมูลของ "${contact.name}"');
              },
            ),
            ListTile(
              leading: const Icon(Icons.checklist, color: AppColors.violet),
              title: const Text('เลือกหลายรายการ'),
              subtitle: const Text('เพื่อคัดลอกหรือลบพร้อมกันหลายคน'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _enterSelection(contact);
              },
            ),
            const SizedBox(height: AppSpacing.gap),
          ],
        ),
      ),
    );
  }

  /// คัดลอกทั้งสมุดตามที่กรองอยู่ตอนนี้ ใช้ส่งต่อให้คนอื่นทีเดียว
  Future<void> _copyAll() async {
    if (_contacts.isEmpty) {
      _notify('ยังไม่มีรายชื่อให้คัดลอก');
      return;
    }
    final text = _contacts.map(_asText).join('\n\n');
    await _copy(text, 'รายชื่อ ${_contacts.length} คน');
  }

  @override
  Widget build(BuildContext context) {
    if (_selectionMode) return _buildSelectionScaffold();

    return Scaffold(
      appBar: AppBar(
        title: const Text('สมุดรายชื่อ'),
        actions: [
          IconButton(
            tooltip: 'เลือกหลายรายการ',
            onPressed: _contacts.isEmpty
                ? null
                : () => setState(() => _selectionMode = true),
            icon: const Icon(Icons.checklist),
          ),
          IconButton(
            tooltip: 'คัดลอกรายชื่อที่แสดงอยู่ทั้งหมด',
            onPressed: _copyAll,
            icon: const Icon(Icons.copy_all_outlined),
          ),
          IconButton(
            tooltip: _sort == ContactSort.newest
                ? 'กำลังเรียงตามใหม่สุด'
                : 'กำลังเรียงตามชื่อ',
            onPressed: () {
              setState(() {
                _sort = _sort == ContactSort.newest
                    ? ContactSort.name
                    : ContactSort.newest;
              });
              _load();
            },
            icon: Icon(
              _sort == ContactSort.newest
                  ? Icons.access_time
                  : Icons.sort_by_alpha,
            ),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.gap,
                ),
                child: TextField(
                  controller: _searchController,
                  // ค้นทันทีทุกตัวอักษรที่พิมพ์ ไม่ต้องกดปุ่มค้นหา
                  onChanged: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: 'ค้นหาชื่อ เบอร์ อีเมล หรือบันทึกย่อ',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _load();
                            },
                          ),
                  ),
                ),
              ),
              TagFilterBar(
                selected: _tagFilter,
                onChanged: (tag) {
                  setState(() => _tagFilter = tag);
                  _load();
                },
              ),
              const SizedBox(height: AppSpacing.gap),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    FilterChip(
                      selected: _favoritesOnly,
                      onSelected: (value) {
                        setState(() => _favoritesOnly = value);
                        _load();
                      },
                      avatar: Icon(
                        _favoritesOnly ? Icons.star : Icons.star_border,
                        size: 18,
                        color: _favoritesOnly
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                      label: const Text('รายการโปรด'),
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.surfaceHigh,
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    const Spacer(),
                    Text(
                      '${_contacts.length} รายชื่อ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.gap),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.person_add_alt),
        label: const Text('เพิ่มรายชื่อ'),
      ),
    );
  }

  /// หน้าจอตอนอยู่ในโหมดเลือกหลายรายการ
  ///
  /// ใช้แถบด้านบนคนละชุดไปเลย แทนที่จะเอาปุ่มไปยัดรวมกับแถบปกติ
  /// ผู้ใช้จะได้เห็นชัดว่ากำลังอยู่คนละโหมด และไม่กดปุ่มผิดกัน
  Widget _buildSelectionScaffold() {
    final count = _selectedIds.length;
    final all = count == _contacts.length && _contacts.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'ออกจากโหมดเลือก',
          onPressed: _exitSelection,
          icon: const Icon(Icons.close),
        ),
        title: Text(count == 0 ? 'แตะเพื่อเลือก' : 'เลือกแล้ว $count คน'),
        actions: [
          IconButton(
            tooltip: all ? 'ยกเลิกการเลือกทั้งหมด' : 'เลือกทั้งหมด',
            onPressed: all ? () => setState(_selectedIds.clear) : _selectAll,
            icon: Icon(all ? Icons.deselect : Icons.select_all),
          ),
          IconButton(
            tooltip: 'คัดลอกที่เลือก',
            onPressed: count == 0 ? null : _copySelected,
            icon: const Icon(Icons.copy_all_outlined),
          ),
          IconButton(
            tooltip: 'ลบที่เลือก',
            onPressed: count == 0 ? null : _deleteSelected,
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: ContentWidth(
          maxWidth: AppSpacing.maxWideContentWidth,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.gap),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = _error;
    if (error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'เปิดข้อมูลไม่สำเร็จ',
        message: 'ลองปิดแล้วเปิดแอปใหม่อีกครั้ง '
            'ถ้ายังไม่หายให้แจ้งข้อความด้านล่างนี้กับผู้ดูแล\n\n$error',
        color: AppColors.danger,
      );
    }

    if (_contacts.isEmpty) {
      final filtering =
          _searchController.text.trim().isNotEmpty || _tagFilter != null;
      return EmptyState(
        icon: filtering ? Icons.search_off : Icons.contacts_outlined,
        title: filtering ? 'ไม่พบรายชื่อที่ค้นหา' : 'ยังไม่มีรายชื่อ',
        message: filtering
            ? 'ลองพิมพ์คำอื่น เปลี่ยนกลุ่ม หรือล้างช่องค้นหา'
            : 'กดปุ่ม "เพิ่มรายชื่อ" ด้านล่างขวาเพื่อบันทึกคนแรก',
      );
    }

    // จอกว้างจัดการ์ดเป็นสองคอลัมน์ ได้เห็นรายชื่อต่อหนึ่งหน้าจอมากขึ้นเท่าตัว
    // ส่วนจอมือถือยังเรียงคอลัมน์เดียวเหมือนเดิม
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= AppSpacing.twoColumnBreakpoint ? 2 : 1;

        const padding = EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          96, // เว้นที่ให้ปุ่มลอยไม่ทับการ์ดใบสุดท้าย
        );

        if (columns == 1) {
          return ListView.separated(
            padding: padding,
            itemCount: _contacts.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => _animated(index, _contacts[index]),
          );
        }

        final cardWidth = (constraints.maxWidth -
                padding.horizontal -
                AppSpacing.sm * (columns - 1)) /
            columns;

        return SingleChildScrollView(
          padding: padding,
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < _contacts.length; i++)
                SizedBox(
                  width: cardWidth,
                  child: _animated(i, _contacts[i]),
                ),
            ],
          ),
        );
      },
    );
  }

  /// ห่อการ์ดด้วยภาพเคลื่อนไหวโผล่เข้า ไล่ทีละใบจากบนลงล่าง
  ///
  /// จำกัดการหน่วงไว้ไม่เกินใบที่แปด ถ้าปล่อยให้ไล่ไปเรื่อย ๆ
  /// คนที่มีรายชื่อร้อยคนจะต้องนั่งรอการ์ดใบท้าย ๆ นานเกินเหตุ
  /// ใส่ key ตามรหัสของคน เพื่อให้ Flutter รู้ว่าการ์ดใบไหนคือใบเดิม
  /// ตอนกรองรายการ การ์ดที่ยังอยู่จึงไม่เล่นภาพเคลื่อนไหวซ้ำ
  Widget _animated(int index, Contact contact) {
    return FadeSlideIn(
      key: ValueKey(contact.id),
      delay: Duration(milliseconds: 30 * (index > 8 ? 8 : index)),
      child: _card(contact),
    );
  }

  Widget _card(Contact contact) {
    return ContactCard(
      contact: contact,
      showNote: widget.settings.showNoteOnCard,
      selectionMode: _selectionMode,
      selected: _selectedIds.contains(contact.id),
      // อยู่ในโหมดเลือกแล้ว การแตะคือการติ๊ก ไม่ใช่การเปิดหน้ารายละเอียด
      onTap: () => _selectionMode
          ? _toggleSelected(contact)
          : _openForm(contact: contact),
      // กดค้างเข้าโหมดเลือกได้เลย เป็นท่าที่คนคุ้นจากแอปอื่นอยู่แล้ว
      onLongPress: () => _selectionMode
          ? _toggleSelected(contact)
          : _showActions(contact),
      onToggleFavorite: () => _toggleFavorite(contact),
    );
  }
}
