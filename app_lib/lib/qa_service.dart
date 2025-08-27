// qa_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'user_role.dart';

/// Dịch vụ Q&A: nạp dữ liệu từ JSON và trả lời câu hỏi
class QAService {
  final UserRole role;
  List<_QA> _items = [];

  QAService({required this.role});

  /// Nạp JSON theo role (đường dẫn khớp pubspec.yaml)
  Future<void> load() async {
    final asset = role == UserRole.internal
        ? 'app_lib/assets/faq_internal.json'
        : 'app_lib/assets/faq_public.json';

    final raw = await rootBundle.loadString(asset);
    final data = jsonDecode(raw);

    if (data is List) {
      _items = data.map<_QA>((e) => _QA.fromJson(Map<String, dynamic>.from(e))).toList();
    } else if (data is Map && data['items'] is List) {
      _items = (data['items'] as List)
          .map<_QA>((e) => _QA.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      _items = [];
    }
  }

  /// Trả lời câu hỏi (matching đơn giản, đủ chạy demo)
  Future<String> answer(String question) async {
    if (_items.isEmpty) {
      await load();
    }
    final q = question.toLowerCase();

    _QA? best;
    var bestScore = -1;

    for (final item in _items) {
      final sMain = _score(item.question.toLowerCase(), q);
      if (sMain > bestScore) {
        best = item;
        bestScore = sMain;
      }
      for (final v in item.variants) {
        final sVar = _score(v.toLowerCase(), q);
        if (sVar > bestScore) {
          best = item;
          bestScore = sVar;
        }
      }
    }

    return best?.answer ??
        "Mình chưa có câu trả lời phù hợp. Bạn mô tả rõ hơn giúp mình nhé?";
  }

  // Điểm khớp rất đơn giản: bằng nhau > chứa nhau > trùng từ
  int _score(String a, String b) {
    if (a == b) return 1000;
    if (a.contains(b) || b.contains(a)) return 500;
    final sa = a.split(RegExp(r'\s+')).toSet();
    final sb = b.split(RegExp(r'\s+')).toSet();
    return sa.intersection(sb).length; // 0..n
  }
}

/// Model Q&A (linh hoạt khóa: q/question, a/answer, variants[])
class _QA {
  final String question;
  final String answer;
  final List<String> variants;

  _QA({
    required this.question,
    required this.answer,
    required this.variants,
  });

  factory _QA.fromJson(Map<String, dynamic> json) => _QA(
        question: (json['q'] ?? json['question'] ?? '').toString(),
        answer: (json['a'] ?? json['answer'] ?? '').toString(),
        variants: json['variants'] is List
            ? (json['variants'] as List).map((e) => e.toString()).toList()
            : <String>[],
      );
}
