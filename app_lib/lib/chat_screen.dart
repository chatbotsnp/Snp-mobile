import 'package:flutter/material.dart';
import 'qa_service.dart';

class ChatScreen extends StatefulWidget {
  final UserRole role;
  const ChatScreen({super.key, required this.role});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  late final QAService _qa = QAService(role: widget.role);
  final List<_Msg> _messages = [];
  bool _sending = false;
  bool _syncing = false;

  String get _title =>
      widget.role == UserRole.public ? 'Chatbot – Khách hàng' : 'Chatbot – Nhân viên';

  @override
  void initState() {
    super.initState();
    // Nạp dữ liệu: ưu tiên cache/online, fallback offline (đã cài trong QAService)
    _qa.load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(_Msg(text: text, fromUser: true));
      _sending = true;
      _ctrl.clear();
    });

    try {
      final answer = await _qa.answer(text);
      if (!mounted) return;
      setState(() => _messages.add(_Msg(text: answer, fromUser: false)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _messages.add(_Msg(
            text: 'Có lỗi khi lấy câu trả lời. Bạn thử lại nhé.',
            fromUser: false,
          )));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _syncNow() async {
    if (_syncing) return;
    setState(() => _syncing = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang đồng bộ dữ liệu...')),
    );

    try {
      // Ép tải ONLINE + ghi cache (QAService đã xử lý)
      await _qa.load(forceOnline: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đồng bộ xong!')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đồng bộ thất bại. Vui lòng thử lại.')),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            onPressed: _syncing ? null : _syncNow,
            tooltip: 'Đồng bộ nội dung',
            icon: _syncing
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemBuilder: (_, i) {
                  final m = _messages[i];
                  final align = m.fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                  final bg = m.fromUser ? Colors.indigo.shade50 : Colors.grey.shade200;
                  return Column(
                    crossAxisAlignment: align,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(m.text),
                      ),
                    ],
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: _messages.length,
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Nhập câu hỏi...',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool fromUser;
  _Msg({required this.text, required this.fromUser});
}
