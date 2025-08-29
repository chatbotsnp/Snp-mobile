import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'qa_service.dart';

/// Màn hình chat.
/// Nhận vào tham số [role] (có thể là enum UserRole.public/internal, hoặc chuỗi).
class ChatScreen extends StatefulWidget {
  final dynamic role;

  const ChatScreen({super.key, required this.role});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final QAService _qa = QAService(role: widget.role);

  final TextEditingController _text = TextEditingController();
  final ScrollController _scroll = ScrollController();

  // messages: mỗi item = {from: 'user'|'bot', text: '...'}
  final List<Map<String, String>> _messages = [];

  bool _loading = true;
  bool _syncing = false;

  bool get _isInternal => QAService(role: widget.role).isInternal;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _qa.load();
    setState(() => _loading = false);
  }

  void _addMsg(String from, String text) {
    _messages.add({'from': from, 'text': text});
    setState(() {});
    // scroll xuống cuối
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

  Future<void> _send() async {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    _text.clear();
    _addMsg('user', t);

    final reply = await _qa.answer(t);
    _addMsg('bot', reply);
  }

  /// Đọc assets/config.json và sync theo vai trò hiện tại
  Future<void> _syncFromConfig() async {
    setState(() => _syncing = true);

    try {
      final raw = await rootBundle.loadString('assets/config.json');
      final j = jsonDecode(raw) as Map<String, dynamic>;

      final url = _isInternal
          ? (j['internal_faq_url'] ?? j['faq_internal_url'] ?? '').toString()
          : (j['public_faq_url'] ?? j['faq_public_url'] ?? '').toString();

      if (url.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy URL trong assets/config.json'),
            ),
          );
        }
      } else {
        final ok = await _qa.syncFromRemote(urlForThisRole: url);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ok
                  ? 'Đồng bộ thành công! Dữ liệu đã được lưu offline.'
                  : 'Đồng bộ thất bại. Kiểm tra lại link raw JSON.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đọc config: $e')),
        );
      }
    } finally {
      setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isInternal ? 'Chat nội bộ' : 'Chat khách hàng';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Đồng bộ dữ liệu',
            onPressed: _syncing ? null : _syncFromConfig,
            icon: _syncing
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : const Icon(Icons.sync),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, i) {
                      final m = _messages[i];
                      final isUser = m['from'] == 'user';
                      return Align(
                        alignment:
                            isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.78,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(m['text'] ?? ''),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _text,
                            minLines: 1,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Nhập câu hỏi...',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _send,
                          child: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
