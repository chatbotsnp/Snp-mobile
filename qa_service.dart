import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class QaItem {
  final String q;
  final String a;
  QaItem({required this.q, required this.a});

  factory QaItem.fromMap(Map<String, dynamic> m) =>
      QaItem(q: m['q'] as String, a: m['a'] as String);
}

class QaService {
  List<QaItem> _public = [];
  List<QaItem> _internal = [];
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final pub = await rootBundle.loadString('assets/faq_public.json');
      final itn = await rootBundle.loadString('assets/faq_internal.json');
      _public = (jsonDecode(pub) as List)
          .map((e) => QaItem.fromMap(e as Map<String, dynamic>))
          .toList();
      _internal = (jsonDecode(itn) as List)
          .map((e) => QaItem.fromMap(e as Map<String, dynamic>))
          .toList();
      _loaded = true;
    } catch (_) {
      _public = [];
      _internal = [];
      _loaded = true;
    }
  }

  Future<String> answer(String query, bool isInternal) async {
    await load();
    final src = isInternal ? _internal : _public;
    if (src.isEmpty) {
      return 'Hiện chưa có dữ liệu. Vui lòng tải lên file JSON hoặc import nội dung.';
    }

    final qLower = query.toLowerCase();

    // 1) match chính xác / contains
    for (final x in src) {
      final qq = x.q.toLowerCase();
      if (qq == qLower || qq.contains(qLower)) return x.a;
    }

    // 2) match gần đúng theo số từ trùng
    int bestScore = -1;
    String best = '';
    final tokens = qLower.split(RegExp(r'\s+')).toSet();
    for (final x in src) {
      final t2 = x.q.toLowerCase().split(RegExp(r'\s+')).toSet();
      final score = tokens.intersection(t2).length;
      if (score > bestScore) {
        bestScore = score;
        best = x.a;
      }
    }
    if (bestScore <= 0) {
      return 'Mình chưa tìm thấy câu trả lời phù hợp. Bạn có thể hỏi cách khác hoặc liên hệ bộ phận hỗ trợ.';
    }
    return best;
  }
}
