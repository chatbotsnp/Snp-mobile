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
      appBar: AppBar(title: const Text('Chọn vai trò để vào chat')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () => _go(context, UserRole.public),
                icon: const Icon(Icons.public),
                label: const Text('Tôi là KHÁCH HÀNG'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _go(context, UserRole.internal),
                icon: const Icon(Icons.badge),
                label: const Text('Tôi là NHÂN VIÊN NỘI BỘ'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Bản demo: dữ liệu lấy từ 2 file JSON trong assets.\n'
                'Bạn có thể cập nhật nội dung và build lại bất kỳ lúc nào.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
