import 'package:flutter/material.dart';
import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final codeCtrl = TextEditingController();
  final dobCtrl  = TextEditingController();
  bool internal = false; // bật = nhân viên nội bộ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SNP Chatbot')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('Đăng nhập nhân viên nội bộ'),
              subtitle: const Text('Tắt = khách hàng (public)'),
              value: internal,
              onChanged: (v) => setState(()=> internal = v),
            ),
            if (internal) ...[
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mã nhân viên (VD: NV001)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dobCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ngày sinh (YYYY-MM-DD)',
                ),
              ),
              const SizedBox(height: 8),
            ],
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    isInternal: internal,
                    employeeCode: codeCtrl.text.trim(),
                    dob: dobCtrl.text.trim(),
                  ),
                ));
              },
              child: const Text('Vào Chatbot'),
            ),
            const SizedBox(height: 24),
            const Text('Gợi ý: Bật “nhân viên nội bộ” để truy cập FAQ nội bộ. '
                'Khách hàng chỉ xem bộ câu hỏi public.'),
          ],
        ),
      ),
    );
  }
}
