import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'user_role.dart';

/// Dịch vụ Q&A đơn giản đọc JSON từ assets và trả lời theo từ khóa
class QAService {
  final UserRole role;

  /// Lưu data đã nạp: danh sách {q, a}
  final List<Map<String, String>> _faqs = [];

  QAService({required this.role});

  /// Nạp dữ liệu JSON theo role
  Future<void> load() async {
    final path = role == UserRole.internal
        ? 'assets/faq_internal.json'
        : 'assets/faq_public.json';

    final raw = await rootBundle.loadString(path);
    final data = jsonDecode(raw);

    _faqs.clear();

    // Chấp nhận cả 2 dạng: LIST các item {q, a} hoặc MAP {question: answer}
    if (data is List) {
      for (final item in data) {
        if (item is Map) {
          final q = (item['q'] ?? item['question'] ?? '').toString();
          final a = (item['a'] ?? item['answer'] ?? '').toString();
          if (q.isNotEmpty && a.isNotEmpty) {
            _faqs.add({'q': q, 'a': a});
          }
        }
      }
    } else if (data is Map) {
      data.forEach((k, v) {
        final q = k.toString();
        final a = v.toString();
        if (q.isNotEmpty && a.isNotEmpty) {
          _faqs.add({'q': q, 'a': a});
        }
      });
    }
  }

  /// Trả lời nhanh theo khớp từ khóa thô (contains, không phân biệt hoa thường)
  Future<String> answer(String question) async {
    if (_faqs.isEmpty) {
      // Phòng trường hợp quên gọi load()
      await load();
    }

    final qLower = question.toLowerCase().trim();

    // 1) Khớp “câu hỏi chứa nhau”
    for (final item in _faqs) {
      final cand = (item['q'] ?? '').toLowerCase();
      if (cand.isNotEmpty && (qLower.contains(cand) || cand.contains(qLower))) {
        return item['a'] ?? '';
      }
    }

    // 2) Khớp theo từ khóa đơn giản (tách từ, đếm trùng)
    int bestScore = 0;
    String? bestAnswer;
    final words = qLower.split(RegExp(r'\s+')).where((w) => w.length >= 3);
    for (final item in _faqs) {
      final cand = (item['q'] ?? '').toLowerCase();
      int score = 0;
      for (final w in words) {
        if (cand.contains(w)) score++;
      }
      if (score > bestScore) {
        bestScore = score;
        bestAnswer = item['a'];
      }
    }
    if (bestScore > 0 && bestAnswer != null) return bestAnswer!;

    // 3) Không tìm thấy
    return 'Xin lỗi, mình chưa có câu trả lời phù hợp. '
        'Bạn thử đặt câu hỏi chi tiết hơn hoặc dùng từ khóa khác nhé.';
  }
}
