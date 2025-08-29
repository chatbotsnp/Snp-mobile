import 'package:flutter/material.dart';
import 'dart:math';
import 'employee_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _svc = EmployeeService();
  List<Employee> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    _items = await _svc.loadAll();
    _items.sort((a, b) => a.name.compareTo(b.name));
    setState(() => _loading = false);
  }

  Future<void> _add() async {
    final res = await showDialog<Employee>(
      context: context,
      builder: (_) => const _EmployeeDialog(),
    );
    if (res == null) return;
    await _svc.add(res);
    await _reload();
  }

  Future<void> _remove(Employee e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa nhân viên?'),
        content: Text('Bạn chắc chắn muốn xóa "${e.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok == true) {
      await _svc.remove(e.id);
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản trị nhân viên')),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.person_add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final e = _items[i];
                  return ListTile(
                    leading: CircleAvatar(child: Text(e.name.isNotEmpty ? e.name[0] : '?')),
                    title: Text(e.name),
                    subtitle: Text('Mã: ${e.code} · Phòng: ${e.dept}${e.isAdmin ? " · Admin" : ""}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _remove(e),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _EmployeeDialog extends StatefulWidget {
  const _EmployeeDialog();

  @override
  State<_EmployeeDialog> createState() => _EmployeeDialogState();
}

class _EmployeeDialogState extends State<_EmployeeDialog> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _dept = TextEditingController();
  bool _isAdmin = false;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _dept.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm nhân viên'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Họ tên'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _code,
            decoration: const InputDecoration(labelText: 'Mã đăng nhập'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _dept,
            decoration: const InputDecoration(labelText: 'Phòng ban'),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _isAdmin,
            onChanged: (v) => setState(() => _isAdmin = v ?? false),
            title: const Text('Quyền quản trị (Admin)'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        FilledButton(
          onPressed: () {
            if (_name.text.trim().isEmpty || _code.text.trim().isEmpty) return;
            final id = 'emp-${Random().nextInt(900000) + 100000}';
            Navigator.pop(
              context,
              Employee(
                id: id,
                name: _name.text.trim(),
                code: _code.text.trim(),
                dept: _dept.text.trim(),
                isAdmin: _isAdmin,
                isActive: true,
              ),
            );
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
