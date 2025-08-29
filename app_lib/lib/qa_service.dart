import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Vai trò người dùng
enum UserRole { public, internal }

/// Một mục Hỏi–Đáp
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

class _Config {
  final bool remote;
  final String publicUrl;
  final String internalUrl;
  final int timeoutSeconds;

  _Config({
    required this.remote,
    required this.publicUrl,
    required this.internalUrl,
    required this.timeoutSeconds,
  });

  static Future<_Config> load() async {
    final raw = await rootBundle.loadString('assets/config.json');
    final j = json.decode(raw) as Map<String, dynamic>;
    return _Config(
      remote: (j['remote'] ?? false) == true,
      publicUrl: (j['public_url'] ?? '').toString(),
      internalUrl: (j['internal_url'] ?? '').toString(),
      timeoutSeconds: int.tryParse('${j['timeout_seconds'] ?? 10}') ?? 10,
    );
  }
}

/// Service nạp dữ liệu & trả lời
class QAService {
  final UserRole role;
  List<FAQItem> _items = [];
  bool _loaded = false;

  QAService({required this.role});

  /// Nạp dữ liệu (ưu tiên cache → online → offline assets)
  Future<void> load({bool forceOnline = false}) async {
    final cfg = await _Config.load();

    // 0) Cache trước nếu không ép online
    if (!forceOnline) {
      final cached = await _readCache();
      if (cached != null) {
        _items = _parseItems(cached);
        _loaded = true;
        // làm mới online âm thầm
        _refreshOnlineSilently(cfg);
        return;
      }
    }

    // 1) Online-first nếu bật remote hoặc forceOnline
    if (cfg.remote || forceOnline) {
      final url = _urlForRole(cfg);
      if (url.isNotEmpty) {
        try {
          final res = await http.get(Uri.parse(url))
              .timeout(Duration(seconds: cfg.timeoutSeconds));
          if (res.statusCode == 200 && res.body.isNotEmpty) {
            _items = _parseItems(res.body);
            _loaded = true;
            await _writeCache(res.body);
            return;
          }
        } catch (_) { /* fallback */ }
      }
    }

    // 2) Fallback offline
    final path = role == UserRole.public
        ? 'assets/faq_public.json'
        : 'assets/faq_internal.json';
    final raw = await rootBundle.loadString(path);
    _items = _parseItems(raw);
    _loaded = true;
    await _writeCache(raw);
  }

  /// Ép tải ONLINE ngay (dùng cho nút "Đồng bộ")
  Future<void> refreshOnline() async {
    await load(forceOnline: true);
  }

  /// Trả về bản sao danh sách FAQ hiện có (sau khi load)
  Future<List<FAQItem>> getAll() async {
    if (!_loaded) await load();
    return List<FAQItem>.from(_items);
  }

  /// Tìm câu trả lời tốt nhất theo cơ chế fuzzy đơn giản
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

  // ====== Private helpers ======
  String _urlForRole(_Config cfg) =>
      role == UserRole.public ? cfg.publicUrl : cfg.internalUrl;

  List<FAQItem> _parseItems(String raw) {
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
    return list
        .map((e) => FAQItem.fromJson(e))
        .where((it) => it.question.isNotEmpty && it.answer.isNotEmpty)
        .toList();
  }

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

  Future<File> _cacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final name = role == UserRole.public ? 'faq_public.json' : 'faq_internal.json';
    return File('${dir.path}/$name');
  }

  Future<void> _writeCache(String content) async {
    try {
      final f = await _cacheFile();
      await f.writeAsString(content, flush: true);
    } catch (_) {}
  }

  Future<String?> _readCache() async {
    try {
      final f = await _cacheFile();
      if (await f.exists()) return await f.readAsString();
    } catch (_) {}
    return null;
  }

  void _refreshOnlineSilently(_Config cfg) async {
    if (!cfg.remote) return;
    final url = _urlForRole(cfg);
    if (url.isEmpty) return;
    try {
      final res = await http.get(Uri.parse(url))
          .timeout(Duration(seconds: cfg.timeoutSeconds));
      if (res.statusCode == 200 && res.body.isNotEmpty) {
        await _writeCache(res.body);
      }
    } catch (_) {}
  }
}
