import 'package:flutter/material.dart';
import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isEmployee = false;
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _dob = TextEditingController();

  void _go() {
    if (_isEmployee && (_code.text.isEmpty || _dob.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập mã nhân viên và ngày sinh (YYYY-MM-DD)')),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          displayName: _name.text.isEmpty ? (_isEmployee ? 'Nhân viên' : 'Khách') : _name.text,
          isEmployee: _isEmployee,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SNP Chatbot - Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Tên hiển thị (tuỳ chọn)'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _isEmployee,
              onChanged: (v) => setState(() => _isEmployee = v),
              title: const Text('Tôi là Nhân viên (xem nội dung nội bộ)'),
            ),
            if (_isEmployee) ...[
              TextField(
                controller: _code,
                decoration: const InputDecoration(labelText: 'Mã nhân viên'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dob,
                decoration: const InputDecoration(labelText: 'Ngày sinh (YYYY-MM-DD)'),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _go,
                icon: const Icon(Icons.login),
                label: const Text('Vào Chatbot'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
