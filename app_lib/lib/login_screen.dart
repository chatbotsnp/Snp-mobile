// lib/login_screen.dart
import 'package:flutter/material.dart';
import 'package:snp_chatbot/chat_screen.dart';

/// Vai trò người dùng
enum UserRole { public, internal }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _codeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _go(BuildContext context, UserRole role) {
    // Nếu khách hàng (public) => không cần mã nhân viên
    if (role == UserRole.public) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChatScreen(role: UserRole.public),
      ));
      return;
    }

    // Nội bộ: yêu cầu nhập mã (có thể cho phép trống nếu bạn muốn)
    if (!_formKey.currentState!.validate()) return;

    final code = _codeCtrl.text.trim();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatScreen(
        role: UserRole.internal,
        employeeCode: code,
      ),
    ));
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = const SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn vai trò')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ElevatedButton(
              onPressed: () => _go(context, UserRole.public),
              child: const Text('Khách hàng (Public)'),
            ),
            spacing,
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nhân viên (Internal)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _codeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Mã nhân viên (ví dụ SNP001)',
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.done,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Vui lòng nhập mã nhân viên';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _go(context, UserRole.internal),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => _go(context, UserRole.internal),
                          child: const Text('Vào kênh nội bộ'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
