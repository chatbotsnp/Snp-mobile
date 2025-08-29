import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'employee_service.dart';

enum UserRole { public, internal }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _codeCtrl = TextEditingController();
  final _svc = EmployeeService();
  bool _checking = false;
  String? _error;

  Future<void> _go(UserRole role) async {
    setState(() {
      _error = null;
    });

    if (role == UserRole.public) {
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChatScreen(role: UserRole.public),
      ));
      return;
    }

    // internal -> cần mã nhân viên (có thể rỗng, nhưng nếu đúng admin thì bật màn admin trong ChatScreen)
    final code = _codeCtrl.text.trim();
    setState(() => _checking = true);
    final emp = code.isEmpty ? null : await _svc.findByCode(code);
    setState(() => _checking = false);

    if (!mounted) return;
    if (emp == null) {
      _error = code.isEmpty
          ? null // cho phép vào nội bộ không mã (chỉ chat)
          : 'Không tìm thấy nhân viên $code';
    } else if (!emp.isActive) {
      _error = 'Tài khoản đã bị khóa';
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatScreen(
        role: UserRole.internal,
        employeeCode: code.isEmpty ? null : code,
        isAdmin: emp?.isAdmin ?? false,
        employeeName: emp?.name,
        employeeDept: emp?.dept,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn vai trò')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Mã nhân viên (tuỳ chọn khi vào nội bộ)',
                hintText: 'VD: SNP001',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checking ? null : () => _go(UserRole.public),
              child: const Text('Khách hàng (Public)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _checking ? null : () => _go(UserRole.internal),
              child: _checking
                  ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator())
                  : const Text('Nhân viên (Internal)'),
            ),
          ],
        ),
      ),
    );
  }
}
