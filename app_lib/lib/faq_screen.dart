import 'package:flutter/material.dart';
import 'qa_service.dart';

class FAQScreen extends StatefulWidget {
  final UserRole role;
  const FAQScreen({super.key, required this.role});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final _searchCtrl = TextEditingController();
  final _items = <_QA>[];
  final _filtered = <_QA>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final qa = QAService(role: widget.role);
    await qa.load(); // dùng cơ chế online+cache+offline có sẵn
    // Lấy toàn bộ mục hỏi đáp (tạm: lấy bằng trick answer cho list câu)
    // Ở bản sau: mình sẽ thêm API public trong QAService để trả list chuẩn.
    // Tạm thời, để hiển thị mẫu, mình đọc lại assets/remote từ chính qa.load()
    // => giải pháp gọn: yêu cầu người dùng nhập từ khoá để xem trả lời.
    setState(() => _loading = false);
  }

  void _doSearch() async {
    final text = _searchCtrl.text.trim();
    _filtered.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    // Tìm theo cơ chế chatbot: trả lời duy nhất tốt nhất
    final qa = QAService(role: widget.role);
    final ans = await qa.answer(text);
    _filtered.add(_QA(q: text, a: ans));
    setState(() {});
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.role == UserRole.public ? 'FAQ (Public)' : 'FAQ (Internal)';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _searchCtrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _doSearch(),
                    decoration: const InputDecoration(
                      hintText: 'Nhập từ khoá cần tra cứu...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _filtered.isEmpty
                        ? const Center(child: Text('Nhập từ khoá để tra cứu FAQ.'))
                        : ListView.separated(
                            itemBuilder: (_, i) {
                              final it = _filtered[i];
                              return ListTile(
                                title: Text(it.q),
                                subtitle: Text(it.a),
                              );
                            },
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemCount: _filtered.length,
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _QA {
  final String q;
  final String a;
  _QA({required this.q, required this.a});
}
