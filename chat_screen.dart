import 'package:flutter/material.dart';
import '../services/api_client.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _backendController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  String _response = "";
  String? _token;

  void _loginGuest() async {
    final client = ApiClient(_backendController.text);
    final token = await client.loginGuest();
    setState(() {
      _token = token;
      _response = token != null ? "Login Guest thành công!" : "Login thất bại";
    });
  }

  void _ask() async {
    if (_token == null) {
      setState(() => _response = "Bạn cần login trước");
      return;
    }
    final client = ApiClient(_backendController.text);
    final answer = await client.ask(_token!, _questionController.text);
    setState(() => _response = answer ?? "Lỗi khi hỏi");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SNP Chatbot")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _backendController,
              decoration: const InputDecoration(
                labelText: "Backend URL",
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loginGuest,
              child: const Text("Đăng nhập Khách"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: "Nhập câu hỏi",
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _ask,
              child: const Text("Hỏi"),
            ),
            const SizedBox(height: 16),
            Text("Trả lời: $_response"),
          ],
        ),
      ),
    );
  }
}
