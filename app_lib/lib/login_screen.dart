import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'user_role.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _go(context, UserRole.public),
              child: const Text('Khách hàng (Public)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _go(context, UserRole.internal),
              child: const Text('Nhân viên (Internal)'),
            ),
          ],
        ),
      ),
    );
  }
}
