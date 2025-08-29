import 'package:flutter/material.dart';
import 'chat_screen.dart';         // đã có sẵn trong dự án của bạn
import 'admin_screen.dart';        // file ở mục (3)
import 'employee_service.dart';

// Nếu enum UserRole nằm trong file khác (vd: user_role.dart) thì đổi import tương ứng.
// Ở bản trước ChatScreen nhận tham số `UserRole role`.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _codeCtrl = TextEditingController();
  bool _isChecking = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _goPublic() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(role: UserRole.public),
      ),
    );
  }

  Future<void> _goInternal() async {
    // Hộp nhập mã
    final code = await showDialog<String>(
      context: context,
      builder: (_) => _CodeDialog(controller: _codeCtrl),
    );

    if (code == null || code.trim().isEmpty) return;

    setState(() => _isChecking = true);
    final svc = EmployeeService();
    final emp = await svc.findByCode(code.trim());
    setState(() => _isChecking = false);

    if (emp == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã nhân viên không hợp lệ!')),
        );
      }
      return;
    }

    if (emp.isAdmin) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
      }
      return;
    }

    // Nhân viên thường -> vào Chat internal
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(role: UserRole.internal),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn vai trò')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RoleButton(
              label: 'Khách hàng (Public)',
              onTap: _goPublic,
            ),
            const SizedBox(height: 16),
            _RoleButton(
              label: _isChecking ? 'Đang kiểm tra…' : 'Nhân viên (Internal)',
              onTap: _isChecking ? null : _goInternal,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _RoleButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(260, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }
}

class _CodeDialog extends StatelessWidget {
  final TextEditingController controller;

  const _CodeDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nhập mã nhân viên'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'VD: 1234 hoặc admin',
          border: OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => Navigator.of(context).pop(controller.text),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('Tiếp tục'),
        ),
      ],
    );
  }
}
