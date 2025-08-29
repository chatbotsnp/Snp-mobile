import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'qa_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _go(BuildContext context, UserRole role) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(role: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn vai trò')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _btn(context, 'Khách hàng (Public)', UserRole.public),
            const SizedBox(height: 16),
            _btn(context, 'Nhân viên (Internal)', UserRole.internal),
          ],
        ),
      ),
    );
  }

  Widget _btn(BuildContext context, String label, UserRole role) {
    return ElevatedButton(onPressed: () => _go(context, role), child: Text(label));
  }
}
