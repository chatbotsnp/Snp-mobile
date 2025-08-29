import 'package:flutter/material.dart';
import 'qa_service.dart';

class ProfileScreen extends StatelessWidget {
  final UserRole role;
  const ProfileScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final roleName = role == UserRole.public ? 'Khách hàng (Public)' : 'Nhân viên (Internal)';
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vai trò hiện tại: $roleName', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            const Text('Phiên bản: 1.0.0'),
            const SizedBox(height: 12),
            const Text('Thông tin ứng dụng sẽ được bổ sung ở bản tới.'),
          ],
        ),
      ),
    );
  }
}
