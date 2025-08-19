import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class QaItem {
  final String q;
  final String a;
  QaItem(this.q, this.a);
}

class QaService {
  QaService._();
  static final instance = QaService._();

  List<QaItem> _public = [];
  List<QaItem> _internal = [];
  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;
    final pub = await rootBundle.loadString('assets/faq_public.json');
    final inter = await rootBundle.loadString('assets/faq_internal.json');
    _public = (jsonDecode(pub) as List).map((e) => QaItem(e['q'], e['a'])).toList();
    _internal = (jsonDecode(inter) as List).map((e) => QaItem(e['q'], e['a'])).toList();
    _inited = true;
  }

  Future<String> answer(String question, {required bool isEmployee}) async {
    final pool = [..._public, if (isEmployee) ..._internal];
    if (pool.isEmpty) return 'Hiện chưa có dữ liệu.';
    final qLower = question.toLowerCase();
    int bestScore = -1;
    String? bestAns;
    for (final item in pool) {
      final score = _score(item.q.toLowerCase(), qLower);
      if (score > bestScore) {
        bestScore = score;
        bestAns = item.a;
      }
    }
    if (bestScore <= 0) {
      return 'Mình chưa tìm thấy câu trả lời phù hợp trong dữ liệu. Bạn thử mô tả rõ hơn nhé.';
    }
    return bestAns ?? 'Không có câu trả lời.';
  }

  int _score(String base, String q) {
    final bTokens = base.split(RegExp(r'\s+')).toSet();
    final qTokens = q.split(RegExp(r'\s+')).toSet();
    return bTokens.intersection(qTokens).length;
  }
}
