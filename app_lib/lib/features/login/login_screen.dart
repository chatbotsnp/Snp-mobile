import 'package:flutter/material.dart';
import '../../core/user_role.dart';

class LoginScreen extends StatelessWidget {
  final void Function(UserRole) onPicked;
  const LoginScreen({super.key, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn vai trò')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () { onPicked(UserRole.public); Navigator.pushReplacementNamed(context, '/home'); },
              child: const Text('Khách hàng (Public)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () { onPicked(UserRole.internal); Navigator.pushReplacementNamed(context, '/home'); },
              child: const Text('Nhân viên (Internal)'),
            ),
          ],
        ),
      ),
    );
  }
}
