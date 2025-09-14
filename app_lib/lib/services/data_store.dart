import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class QAItem {
  final String q;
  final String a;
  QAItem({required this.q, required this.a});
  factory QAItem.fromJson(Map<String, dynamic> j) => QAItem(q: j['q'] ?? '', a: j['a'] ?? '');
}

class DataStore {
  static bool isEmployee = false; // giả lập đăng nhập nội bộ

  static Future<List<QAItem>> loadPublicFAQ() async {
    final txt = await rootBundle.loadString('assets/faq_public.json');
    final list = (jsonDecode(txt) as List).map((e) => QAItem.fromJson(e)).toList();
    return list;
    // Sau này thay bằng fetch từ URL + cache
  }

  static Future<List<QAItem>> loadInternalFAQ() async {
    if (!isEmployee) return []; // chặn nếu chưa đăng nhập NV
    final txt = await rootBundle.loadString('assets/faq_internal.json');
    final list = (jsonDecode(txt) as List).map((e) => QAItem.fromJson(e)).toList();
    return list;
  }

  static Future<void> fakeSync() async {
    // Giả lập đồng bộ dữ liệu online (1-2s)
    await Future.delayed(const Duration(seconds: 1));
  }
}
