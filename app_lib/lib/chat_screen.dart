import 'package:flutter/material.dart';
import 'qa_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final QAService _qa = QAService(role: widget.role);
  final _controller = TextEditingController();
  final List<_Msg> _messages = [];

  @override
  void initState() {
    super.initState();
    _qa.load(); // nạp sẵn
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text, true));
    });
    _controller.clear();

    final answer = await _qa.answer(text);
    setState(() {
      _messages.add(_Msg(answer ?? 'Xin lỗi, mình chưa có dữ liệu cho câu này.', false));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isInternal = widget.role == UserRole.internal;

    return Scaffold(
      appBar: AppBar(
        title: Text(isInternal ? 'SNP Chatbot (Nội bộ)' : 'SNP Chatbot (Khách hàng)'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return Align(
                  alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: m.me ? Colors.blueAccent.withOpacity(.15) : Colors.green.withOpacity(.12),
                      borderRadius: BorderRadius.circular(12),
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
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhập câu hỏi...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: _send, icon: const Icon(Icons.send)),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  _Msg(this.text, this.me);
  final String text;
  final bool me;
}
