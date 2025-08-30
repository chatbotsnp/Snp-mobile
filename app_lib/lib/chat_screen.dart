// lib/chat_screen.dart
import 'package:flutter/material.dart';

// Chỉ lấy enum UserRole từ màn Login (đã có sẵn ở dự án của bạn)
import 'package:snp_chatbot/login_screen.dart' show UserRole;

import 'package:snp_chatbot/qa_service.dart';
import 'package:snp_chatbot/employee_service.dart';

class ChatScreen extends StatefulWidget {
  final UserRole role;

  /// Mã nhân viên (tùy chọn) – dùng khi role = internal để hiển thị thông tin
  final String? employeeCode;

  const ChatScreen({
    super.key,
    required this.role,
    this.employeeCode,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final QAService _qa;
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  // tin nhắn đơn giản
  final List<_Msg> _msgs = [];

  // Thông tin nhân viên (nếu có)
  Employee? _me;

  @override
  void initState() {
    super.initState();
    _qa = QAService(role: widget.role);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _qa.load(); // nạp FAQ + cache
    if (widget.role == UserRole.internal && (widget.employeeCode ?? '').isNotEmpty) {
      final svc = EmployeeService();
      _me = await svc.findByCode(widget.employeeCode!.trim());
      if (_me != null) {
        _pushBot(
          'Xin chào ${_me!.name} (${_me!.code}) - ${_me!.dept}'
          '${_me!.isAdmin ? ' · Admin' : ''}. Bạn cần hỗ trợ gì?',
        );
      } else {
        _pushBot('Không tìm thấy mã nhân viên ${widget.employeeCode}. Bạn vẫn có thể hỏi hệ thống.');
      }
    } else {
      _pushBot('Xin chào! Bạn đang ở kênh ${widget.role == UserRole.public ? 'Khách hàng' : 'Nội bộ'}.');
    }
  }

  void _pushUser(String text) {
    setState(() => _msgs.add(_Msg(isUser: true, text: text)));
    _scrollToEndSoon();
  }

  void _pushBot(String text) {
    setState(() => _msgs.add(_Msg(isUser: false, text: text)));
    _scrollToEndSoon();
  }

  void _scrollToEndSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _onSend() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();

    _pushUser(text);

    // Gọi AI/FAQ
    final answer = await _qa.answer(text);
    _pushBot(answer);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInternal = widget.role == UserRole.internal;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isInternal ? 'SNP Chat (Nội bộ)' : 'SNP Chat (Khách hàng)',
        ),
        actions: [
          if (isInternal && _me != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  _me!.code,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _msgs.length,
              itemBuilder: (context, i) {
                final m = _msgs[i];
                final align =
                    m.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                final bubbleColor =
                    m.isUser ? Theme.of(context).colorScheme.primary : Colors.grey.shade200;
                final textColor = m.isUser ? Colors.white : Colors.black87;

                return Column(
                  crossAxisAlignment: align,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(m.text, style: TextStyle(color: textColor)),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Nhập câu hỏi…',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _onSend(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _onSend,
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
  final bool isUser;
  final String text;
  _Msg({required this.isUser, required this.text});
}
