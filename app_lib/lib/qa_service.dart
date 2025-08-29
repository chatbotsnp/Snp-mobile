import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Vai trò người dùng
enum UserRole { public, internal }

/// 1 mục Hỏi–Đáp
class FAQItem {
  final String question;
  final String answer;
  FAQItem(this.question, this.answer);

  factory FAQItem.fromJson(dynamic j) {
    if (j is Map<String, dynamic>) {
      final q = (j['q'] ?? j['question'] ?? '').toString();
      final a = (j['a'] ?? j['answer'] ?? '').toString();
      return FAQItem(q, a);
    }
    return FAQItem('', '');
  }
}

/// Service nạp dữ liệu & tìm câu trả lời gần đúng
class QAService {
  final UserRole role;
  List<FAQItem> _items = [];
  bool _loaded = false;

  QAService({required this.role});

  Future<void> load() async {
    final path = role == UserRole.public
        ? 'assets/faq_public.json'
        : 'assets/faq_internal.json';
    final raw = await rootBundle.loadString(path);
    final data = json.decode(raw);

    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      list = (data['faqs'] ??
              data['data'] ??
              data['items'] ??
              data.values.firstWhere((v) => v is List, orElse: () => []))
          as List<dynamic>;
    } else {
      list = [];
    }

    _items = list
        .map((e) => FAQItem.fromJson(e))
        .where((it) => it.question.isNotEmpty && it.answer.isNotEmpty)
        .toList();

    _loaded = true;
  }

  Future<String> answer(String question) async {
    if (!_loaded) await load();
    final q = _normalize(question);
    if (q.isEmpty) return 'Bạn vui lòng nhập câu hỏi nhé.';

    double bestScore = -1;
    FAQItem? best;
    for (final it in _items) {
      final s = _score(q, it.question, it.answer);
      if (s > bestScore) {
        bestScore = s;
        best = it;
      }
    }

    if (best == null || bestScore < 0.22) {
      return 'Xin lỗi, mình chưa có thông tin phù hợp. '
          'Bạn thử diễn đạt khác giúp mình nhé.';
    }
    return best.answer;
  }

  // ===== Helpers =====
  String _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  Set<String> _tokens(String s) =>
      _normalize(s).split(' ').where((t) => t.isNotEmpty).toSet();

  double _jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final inter = a.intersection(b).length;
    final uni = a.union(b).length;
    return inter / uni;
  }

  double _score(String q, String candQ, String candA) {
    final qn = _normalize(candQ);
    final an = _normalize(candA);
    final containsQ = qn.contains(q) ? 1.0 : 0.0;
    final jacQ = _jaccard(_tokens(q), _tokens(qn));
    final jacA = _jaccard(_tokens(q), _tokens(an));
    return containsQ * 0.6 + jacQ * 0.35 + jacA * 0.05;
  }
}
