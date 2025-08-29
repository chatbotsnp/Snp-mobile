import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

/// Cấu trúc 1 QA
class QAPair {
  final String question;
  final String answer;

  QAPair({required this.question, required this.answer});

  factory QAPair.fromJson(Map<String, dynamic> j) => QAPair(
        question: (j['question'] ?? j['q'] ?? '').toString(),
        answer: (j['answer'] ?? j['a'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {'question': question, 'answer': answer};
}

/// Dịch vụ Q&A dùng offline cache + có thể sync online.
/// LƯU Ý: để không xung đột với enum UserRole ở file khác,
/// mình KHÔNG import/định nghĩa UserRole ở đây.
/// Thay vào đó nhận tham số `role` kiểu dynamic, tự suy ra có phải internal không.
class QAService {
  final bool isInternal;

  /// `role` có thể là enum UserRole.public/internal, hoặc chuỗi 'public'/'internal'
  QAService({dynamic role}) : isInternal = _toInternal(role);

  static bool _toInternal(dynamic role) {
    if (role == null) return false;
    final s = role.toString().toLowerCase();
    return s.contains('internal');
  }

  // Tên file bundle (assets) & cache theo role
  String get _bundleAsset =>
      isInternal ? 'assets/faq_internal.json' : 'assets/faq_public.json';

  String get _cacheFileName =>
      isInternal ? 'qa_internal_cache.json' : 'qa_public_cache.json';

  // Bộ nhớ tạm
  List<QAPair> _items = [];

  /// Đường dẫn file cache trong thư mục Documents của app
  Future<File> _cacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_cacheFileName');
    // ví dụ: /data/user/0/<appId>/files/qa_public_cache.json
  }

  /// Parse từ JSON string thành danh sách QAPair an toàn
  List<QAPair> _parseList(String text) {
    try {
      final raw = jsonDecode(text);
      if (raw is List) {
        return raw
            .map((e) => QAPair.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
      }
    } catch (_) {}
    return <QAPair>[];
  }

  /// Nạp dữ liệu:
  /// - Nếu đã có cache => dùng cache;
  /// - Nếu CHƯA có cache => copy từ bundled assets (faq_public.json / faq_internal.json) rồi lưu thành cache.
  Future<void> load() async {
    final f = await _cacheFile();

    if (!await f.exists()) {
      // Chưa có cache → đọc assets & ghi cache
      final bundled = await rootBundle.loadString(_bundleAsset);
      final list = _parseList(bundled);
      _items = list;
      await f.writeAsString(jsonEncode(list.map((e) => e.toJson()).toList()));
      return;
    }

    // Có cache → đọc thẳng cache
    final text = await f.readAsString();
    _items = _parseList(text);
  }

  /// Lưu lại _items vào cache
  Future<void> _saveCache() async {
    final f = await _cacheFile();
    await f.writeAsString(jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  /// Đồng bộ online:
  /// - Nếu bạn muốn sync theo từng role: truyền đúng URL json public/internal tương ứng.
  /// - Nếu chỉ có 1 URL cho role hiện tại → truyền `urlForThisRole`.
  ///
  /// JSON online phải là mảng các item có {question, answer} (hoặc {q, a}).
  Future<bool> syncFromRemote({String? urlForThisRole}) async {
    if (urlForThisRole == null || urlForThisRole.trim().isEmpty) return false;

    try {
      final uri = Uri.parse(urlForThisRole);
      final http = HttpClient();
      final req = await http.getUrl(uri);
      final res = await req.close();
      if (res.statusCode == 200) {
        final text = await res.transform(utf8.decoder).join();
        final list = _parseList(text);
        if (list.isNotEmpty) {
          _items = list;
          await _saveCache();
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  /// Trả lời câu hỏi `text` dựa trên dữ liệu _items.
  /// Thuật toán đơn giản:
  ///  - Ưu tiên khớp chứa/bao hàm (contains) không phân biệt hoa thường.
  ///  - Nếu không có, dùng điểm tương đồng Jaccard trên tập từ.
  Future<String> answer(String text) async {
    if (_items.isEmpty) {
      await load();
    }
    if (_items.isEmpty) {
      return 'Hiện chưa có dữ liệu hỏi đáp. Vui lòng đồng bộ hoặc thêm nội dung.';
    }

    final q = _norm(text);

    // 1) Ưu tiên match contains
    for (final item in _items) {
      final cand = _norm(item.question);
      if (cand.isNotEmpty && (q.contains(cand) || cand.contains(q))) {
        return item.answer;
      }
    }

    // 2) Tính điểm giống nhau → chọn lớn nhất
    double bestScore = 0;
    String? bestAnswer;

    for (final item in _items) {
      final s = _jaccard(q, _norm(item.question));
      if (s > bestScore) {
        bestScore = s;
        bestAnswer = item.answer;
      }
    }

    // Ngưỡng gợi ý có thể chỉnh (0.15 ~ 0.35)
    if (bestScore >= 0.2 && bestAnswer != null) return bestAnswer!;

    return 'Xin lỗi, mình chưa có câu trả lời phù hợp. Bạn có thể đặt câu hỏi cụ thể hơn hoặc vào mục Hướng dẫn.';
  }

  /// Chuẩn hoá chuỗi
  String _norm(String s) => s.toLowerCase().trim();

  /// Jaccard similarity theo tập từ đơn giản
  double _jaccard(String a, String b) {
    final sa = a.split(RegExp(r'\s+')).toSet()..removeWhere((e) => e.isEmpty);
    final sb = b.split(RegExp(r'\s+')).toSet()..removeWhere((e) => e.isEmpty);
    if (sa.isEmpty || sb.isEmpty) return 0;
    final inter = sa.intersection(sb).length;
    final union = sa.union(sb).length;
    return inter / union;
  }

  /// Thêm/sửa Q&A local (tuỳ chọn dùng cho Admin sau này)
  Future<void> upsert(QAPair qa) async {
    final idx = _items.indexWhere(
        (e) => _norm(e.question) == _norm(qa.question));
    if (idx >= 0) {
      _items[idx] = qa;
    } else {
      _items.add(qa);
    }
    await _saveCache();
  }

  Future<void> removeByQuestion(String question) async {
    _items.removeWhere((e) => _norm(e.question) == _norm(question));
    await _saveCache();
  }

  List<QAPair> get all => List.unmodifiable(_items);
}
