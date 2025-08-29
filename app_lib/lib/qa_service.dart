import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'user_role.dart';

class QAService {
  final UserRole role;
  late List<Map<String, dynamic>> _faqs;

  QAService({required this.role});

  /// Nạp dữ liệu FAQ từ asset theo vai trò
  Future<void> load() async {
    final file =
        role == UserRole.public ? 'assets/faq_public.json' : 'assets/faq_internal.json';
    final raw = await rootBundle.loadString(file);
    final List list = jsonDecode(raw) as List;
    _faqs = list.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Trả lời câu hỏi đơn giản: tìm câu có chứa (case-insensitive)
  Future<String> answer(String question) async {
    final q = question.toLowerCase().trim();
    for (final item in _faqs) {
      final txt = (item['q'] ?? '').toString().toLowerCase();
      if (txt.isNotEmpty && txt.contains(q)) {
        return (item['a'] ?? '').toString();
      }
    }
    return 'Mình chưa có câu trả lời phù hợp trong bộ FAQ. Bạn thử hỏi cách khác nhé!';
  }
}
