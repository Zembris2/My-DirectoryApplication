import 'package:flutter/material.dart';

import '../data/contact_repository.dart';
import '../models/contact.dart';
import '../theme/app_theme.dart';
import '../widgets/contact_card.dart';
import '../widgets/empty_state.dart';
import 'contact_form_screen.dart';

/// หน้ารายการรายชื่อทั้งหมด
///
/// รวมงานหลัก 5 อย่างไว้ที่นี่ ค้นหา กรองรายการโปรด เรียงลำดับ
/// เปิดฟอร์มเพิ่ม/แก้ไข และลบพร้อมกล่องยืนยัน
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({
    super.key,
    required this.repository,
    required this.onDataChanged,
  });

  final ContactRepository repository;

  /// แจ้งหน้าแม่เมื่อข้อมูลเปลี่ยน เพื่อให้แดชบอร์ดโหลดตัวเลขใหม่
  final VoidCallback onDataChanged;

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Contact> _contacts = [];
  bool _loading = true;
  bool _favoritesOnly = false;
  ContactSort _sort = ContactSort.newest;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// อ่านข้อมูลใหม่จากฐานข้อมูลตามเงื่อนไขที่เลือกอยู่
  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await widget.repository.getContacts(
      query: _searchController.text,
      favoritesOnly: _favoritesOnly,
      sort: _sort,
    );
    if (!mounted) return;
    setState(() {
      _contacts = result;
      _loading = false;
    });
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openForm({Contact? contact}) async {
    final result = await Navigator.of(context).push<Contact>(
      MaterialPageRoute(
        builder: (_) => ContactFormScreen(initial: contact),
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

  /// ถามยืนยันก่อนลบเสมอ กันกดพลาดแล้วข้อมูลหายถาวร
  Future<void> _confirmDelete(Contact contact) async {
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

    await widget.repository.delete(contact.id!);
    _notify('ลบ "${contact.name}" แล้ว');
    widget.onDataChanged();
    await _load();
  }

  Future<void> _toggleFavorite(Contact contact) async {
    await widget.repository.toggleFavorite(contact);
    widget.onDataChanged();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมุดรายชื่อ'),
        actions: [
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
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
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
                  hintText: 'ค้นหาชื่อ เบอร์ หรืออีเมล',
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
                      color: _favoritesOnly ? AppColors.accent : AppColors.textSecondary,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.person_add_alt),
        label: const Text('เพิ่มรายชื่อ'),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_contacts.isEmpty) {
      final searching = _searchController.text.trim().isNotEmpty;
      return EmptyState(
        icon: searching ? Icons.search_off : Icons.contacts_outlined,
        title: searching ? 'ไม่พบรายชื่อที่ค้นหา' : 'ยังไม่มีรายชื่อ',
        message: searching
            ? 'ลองพิมพ์คำอื่น หรือล้างช่องค้นหา'
            : 'กดปุ่ม "เพิ่มรายชื่อ" ด้านล่างขวาเพื่อบันทึกคนแรก',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        96, // เว้นที่ให้ปุ่มลอยไม่ทับการ์ดใบสุดท้าย
      ),
      itemCount: _contacts.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return ContactCard(
          contact: contact,
          onTap: () => _openForm(contact: contact),
          onToggleFavorite: () => _toggleFavorite(contact),
          onDelete: () => _confirmDelete(contact),
        );
      },
    );
  }
}
