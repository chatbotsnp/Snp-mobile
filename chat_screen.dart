import 'package:flutter/material.dart';
import '../services/qa_service.dart';

class ChatScreen extends StatefulWidget {
  final String displayName;
  final bool isEmployee;
  const ChatScreen({super.key, required this.displayName, required this.isEmployee});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageCtrl = TextEditingController();
  final List<_Msg> _messages = [];
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    QaService.instance.init().then((_) {
      setState(() => _ready = true);
      _addBot('Xin chào ${widget.displayName}! Hãy nhập câu hỏi về quy trình/ANC…');
    });
  }

  void _addUser(String t) {
    setState(() => _messages.add(_Msg(t, true)));
  }

  void _addBot(String t) {
    setState(() => _messages.add(_Msg(t, false)));
  }

  Future<void> _send() async {
    final q = _messageCtrl.text.trim();
    if (q.isEmpty || !_ready) return;
    _messageCtrl.clear();
    _addUser(q);
    final ans = await QaService.instance.answer(q, isEmployee: widget.isEmployee);
    _addBot(ans);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SNP Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final align = m.isUser ? Alignment.centerRight : Alignment.centerLeft;
                final color = m.isUser ? Theme.of(context).colorScheme.primaryContainer : Colors.grey.shade200;
                return Align(
                  alignment: align,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m.text),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Nhập câu hỏi…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _send,
                    child: const Icon(Icons.send),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isUser;
  _Msg(this.text, this.isUser);
}
