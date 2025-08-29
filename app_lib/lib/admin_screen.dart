import 'package:flutter/material.dart';
import 'employee_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _svc = EmployeeService();

  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  bool _isAdmin = false;
  bool _isActive = true;

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
    _items.sort((a, b) => a.code.compareTo(b.code));
    setState(() => _loading = false);
  }

  Future<void> _addOrUpdate() async {
    final e = Employee(
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      dept: _deptCtrl.text.trim(),
      isAdmin: _isAdmin,
      isActive: _isActive,
    );
    if (e.code.isEmpty) return;
    await _svc.add(e);
    _clearInputs();
    await _reload();
  }

  Future<void> _remove(Employee e) async {
    await _svc.remove(e.code);
    await _reload();
  }

  void _fill(Employee e) {
    _codeCtrl.text = e.code;
    _nameCtrl.text = e.name;
    _deptCtrl.text = e.dept;
    _isAdmin = e.isAdmin;
    _isActive = e.isActive;
    setState(() {});
  }

  void _clearInputs() {
    _codeCtrl.clear();
    _nameCtrl.clear();
    _deptCtrl.clear();
    _isAdmin = false;
    _isActive = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản trị nhân sự')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _codeCtrl,
                              decoration:
                                  const InputDecoration(labelText: 'Mã'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _nameCtrl,
                              decoration:
                                  const InputDecoration(labelText: 'Tên'),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _deptCtrl,
                              decoration:
                                  const InputDecoration(labelText: 'Phòng'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _isAdmin,
                                  onChanged: (v) =>
                                      setState(() => _isAdmin = v ?? false),
                                ),
                                const Text('Admin'),
                                const SizedBox(width: 12),
                                Checkbox(
                                  value: _isActive,
                                  onChanged: (v) =>
                                      setState(() => _isActive = v ?? true),
                                ),
                                const Text('Active'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _addOrUpdate,
                            child: const Text('Lưu'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _clearInputs,
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final e = _items[i];
                      return ListTile(
                        title: Text('${e.code} - ${e.name}'),
                        subtitle: Text(
                            'Phòng: ${e.dept} · ${e.isAdmin ? "Admin" : "User"} · ${e.isActive ? "Active" : "Locked"}'),
                        onTap: () => _fill(e),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _remove(e),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
