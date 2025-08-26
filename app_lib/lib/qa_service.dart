import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class QAItem {
  final String question;
  final String answer;

  QAItem({required this.question, required this.answer});

  factory QAItem.fromJson(Map<String, dynamic> json) {
    // Hỗ trợ nhiều cách đặt key trong file JSON
    final q = (json['q'] ?? json['question'] ?? '').toString();
    final a = (json['a'] ?? json['answer'] ?? json['return'] ?? '').toString();
    return QAItem(question: q, answer: a);
  }
}

class QAService {
  List<QAItem> _items = [];

  Future<void> loadFromAssets() async {
    final publicStr = await rootBundle.loadString('assets/faq_public.json');
    final internalStr = await rootBundle.loadString('assets/faq_internal.json');

    final list = <QAItem>[];
    for (final s in [publicStr, internalStr]) {
      final data = json.decode(s);
      if (data is List) {
        for (final e in data) {
          if (e is Map<String, dynamic>) list.add(QAItem.fromJson(e));
        }
      } else if (data is Map<String, dynamic> && data['items'] is List) {
        for (final e in (data['items'] as List)) {
          if (e is Map<String, dynamic>) list.add(QAItem.fromJson(e));
        }
      }
    }
    _items = list;
  }

  List<QAItem> search(String query) {
    final q = query.toLowerCase();
    return _items.where((it) =>
      it.question.toLowerCase().contains(q) ||
      it.answer.toLowerCase().contains(q)
    ).toList();
  }
}
