import 'package:flutter/material.dart';
import '../services/api_client.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  String _backendUrl = '';

  void _sendMessage() async {
    if (_controller.text.isEmpty || _backendUrl.isEmpty) return;
    String reply = await ApiClient(_backendUrl).sendMessage(_controller.text);
    setState(() => _response = reply);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SNP Chatbot')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Backend URL'),
              onChanged: (val) => _backendUrl = val,
            ),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Nhập câu hỏi...'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _sendMessage, child: const Text('Gửi')),
            const SizedBox(height: 20),
            Text(_response),
          ],
        ),
      ),
    );
  }
}
