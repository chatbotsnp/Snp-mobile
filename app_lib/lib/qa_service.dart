// lib/qa_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:snp_chatbot/login_screen.dart' show UserRole;

/// Dạng Q&A đơn giản
class QAItem {
  final String q; // câu hỏi
  final String a; // câu trả lời

  const QAItem({required this.q, required this.a});

  factory QAItem.fromJson(Map<String, dynamic> j) =>
      QAItem(q: (j['q'] ?? '').toString(), a: (j['a'] ?? '').toString());

  Map<String, dynamic> toJson() => {'q': q, 'a': a};
}

/// Service đọc Q&A từ assets và cache local
class QAService {
  final UserRole role;
  QAService({required this.role});

  final List<QAItem> _items = [];

  // Tên file assets
  static const _assetPublic = 'assets/faq_public.json';
  static const _assetInternal = 'assets/faq_internal.json';

  // Tên file cache
  static const _cachePublic = 'faq_public.cache.json';
  static const _cacheInternal = 'faq_internal.cache.json';

  /// Load dữ liệu (ưu tiên cache; nếu chưa có thì đọc assets và ghi cache)
  Future<void> load() async {
    _items.clear();

    // public luôn có
    final public = await _loadOne(
      cacheName: _cachePublic,
      assetPath: _assetPublic,
    );

    // nếu nội bộ thì cộng thêm internal
    List<QAItem> internal = const [];
    if (role == UserRole.internal) {
      internal = await _loadOne(
        cacheName: _cacheInternal,
        assetPath: _assetInternal,
      );
    }

    _items
      ..addAll(public)
      ..addAll(internal);
  }

  /// Đọc 1 nguồn: thử cache trước, fail thì dùng assets rồi ghi cache
  Future<List<QAItem>> _loadOne({
    required String cacheName,
    required String assetPath,
  }) async {
    // thử đọc cache
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$cacheName');
      if (await file.exists()) {
        final raw = await file.readAsString();
        return _parseJsonList(raw);
      }
    } catch (_) {
      // bỏ qua, fallback assets
    }

    // đọc assets
    final raw = await rootBundle.loadString(assetPath);
    final list = _parseJsonList(raw);

    // ghi cache (best-effort)
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$cacheName');
      await file.create(recursive: true);
      await file.writeAsString(jsonEncode(list.map((e) => e.toJson()).toList()));
    } catch (_) {}

    return list;
  }

  List<QAItem> _parseJsonList(String raw) {
    final decoded = jsonDecode(raw);

    // Hỗ trợ dạng: [{q,a},...] hoặc {items:[{q,a},...]}
    final List data;
    if (decoded is List) {
      data = decoded;
    } else if (decoded is Map && decoded['items'] is List) {
      data = decoded['items'];
    } else {
      data = const [];
    }

    return data
        .map((e) => e is Map<String, dynamic>
            ? QAItem.fromJson(e)
            : QAItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Trả lời nhanh dựa trên khớp văn bản đơn giản
  Future<String> answer(String text) async {
    final t = _normalize(text);
    // ưu tiên khớp đầy đủ, sau đó khớp chứa
    for (final item in _items) {
      if (_normalize(item.q) == t) return item.a;
    }
    for (final item in _items) {
      if (_normalize(item.q).contains(t) || t.contains(_normalize(item.q))) {
        return item.a;
      }
    }
    return 'Mình chưa tìm thấy câu trả lời phù hợp. Bạn có thể hỏi theo cách khác hoặc liên hệ hỗ trợ.';
  }

  String _normalize(String s) =>
      s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
}
