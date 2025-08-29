import 'package:flutter/material.dart';
import 'qa_service.dart';
import 'user_role.dart';

class ChatScreen extends StatefulWidget {
  final UserRole role;
  const ChatScreen({super.key, required this.role});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final QAService _qa;
  final _controller = TextEditingController();
  final List<_Msg> _messages = []; // lịch sử chat đơn giản

  @override
  void initState() {
    super.initState();
    _qa = QAService(role: widget.role);
    _qa.load(); // nạp dữ liệu
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text, true));
    });
    _controller.clear();
    final reply = await _qa.answer(text);
    setState(() {
      _messages.add(_Msg(reply, false));
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.role == UserRole.public ? 'Chatbot (Khách hàng)' : 'Chatbot (Nội bộ)';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                return Align(
                  alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: m.isMe ? Colors.blue.shade100 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(m.text),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Nhập câu hỏi...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ElevatedButton(
                    onPressed: _send,
                    child: const Text('Gửi'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isMe;
  _Msg(this.text, this.isMe);
}
