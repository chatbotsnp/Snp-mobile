import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'qa_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _go(BuildContext ctx, UserRole role) {
    Navigator.of(ctx).push(
      MaterialPageRoute(builder: (_) => ChatScreen(role: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn vai trò')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _go(context, UserRole.public),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Khách hàng (Public)'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _go(context, UserRole.internal),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Nhân viên (Internal)'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
