import 'package:flutter/material.dart';
import 'qa_service.dart';

class ChatScreen extends StatefulWidget {
  final String user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final QaService _qaService = QaService();

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    String question = _controller.text;
    setState(() {
      _messages.add({"user": widget.user, "text": question});
    });
    String answer = _qaService.getAnswer(question);
    setState(() {
      _messages.add({"user": "SNP Bot", "text": answer});
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SNP Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ListTile(
                  title: Text("${msg['user']}: ${msg['text']}"),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Nhập câu hỏi...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
