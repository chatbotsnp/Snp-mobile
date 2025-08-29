import 'package:flutter/material.dart';
import 'qa_service.dart';
import 'employee_service.dart';

class AdminScreen extends StatefulWidget {
  final UserRole role;
  const AdminScreen({super.key, required this.role});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _syncingFAQ = false;
  bool _syncingEmp = false;

  Future<void> _syncFAQ(UserRole role) async {
    setState(() => _syncingFAQ = true);
    try {
      final qa = QAService(role: role);
      await qa.load(forceOnline: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đồng bộ FAQ ${role == UserRole.public ? "Public" : "Internal"} xong!')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đồng bộ FAQ thất bại.')),
      );
    } finally {
      if (mounted) setState(() => _syncingFAQ = false);
    }
  }

  Future<void> _syncEmployees() async {
    setState(() => _syncingEmp = true);
    try {
      final svc = EmployeeService();
      await svc.load(forceOnline: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đồng bộ danh sách nhân viên xong!')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đồng bộ nhân viên thất bại.')),
      );
    } finally {
      if (mounted) setState(() => _syncingEmp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInternal = widget.role == UserRole.internal;
    if (!isInternal) {
      return const Scaffold(
        body: Center(child: Text('Khu vực Admin (nội bộ). Vui lòng đăng nhập.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Đồng bộ nội dung', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _syncingFAQ ? null : () => _syncFAQ(UserRole.public),
                  icon: _syncingFAQ ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.sync),
                  label: const Text('Sync FAQ Public'),
                ),
                ElevatedButton.icon(
                  onPressed: _syncingFAQ ? null : () => _syncFAQ(UserRole.internal),
                  icon: _syncingFAQ ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.sync),
                  label: const Text('Sync FAQ Internal'),
                ),
                ElevatedButton.icon(
                  onPressed: _syncingEmp ? null : _syncEmployees,
                  icon: _syncingEmp ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.sync),
                  label: const Text('Sync Nhân viên'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Cấu hình (sẽ bổ sung sau)'),
            const SizedBox(height: 8),
            const Text('• Đổi màu nhận diện, logo'),
            const Text('• Quản lý nhóm làm việc'),
            const Text('• Nhật ký truy vấn & Export CSV'),
          ],
        ),
      ),
    );
  }
}
