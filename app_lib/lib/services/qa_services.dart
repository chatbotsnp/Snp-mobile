import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../core/user_role.dart';

class QAService {
  final UserRole role;
  Map<String, dynamic> _cfg = {};
  List<Map<String, String>> _public = [];
  List<Map<String, String>> _internal = [];

  QAService({required this.role});

  Future<void> init() async {
    // 1) đọc config
    final cfgText = await rootBundle.loadString('assets/config.json');
    _cfg = json.decode(cfgText) as Map<String, dynamic>;

    // 2) nạp dữ liệu (remote nếu có, tạm thời dùng assets)
    _public = await _loadQa(
      remoteUrl: (_cfg['content']?['public'] ?? '').toString(),
      assetPath: 'assets/faq_public.json',
    );
    _internal = await _loadQa(
      remoteUrl: (_cfg['content']?['internal'] ?? '').toString(),
      assetPath: 'assets/faq_internal.json',
    );
  }

  Future<List<Map<String, String>>> _loadQa({
    required String remoteUrl,
    required String assetPath,
  }) async {
    try {
      // TODO: nếu sau này có http, ưu tiên tải remoteUrl; hiện tại dùng assets
      final raw = await rootBundle.loadString(assetPath);
      final jsonAny = json.decode(raw);
      final out = <Map<String, String>>[];

      if (jsonAny is List) {
        for (final e in jsonAny) {
          if (e is Map) {
            final q = (e['q'] ?? e['question'] ?? '').toString();
            final a = (e['a'] ?? e['answer'] ?? '').toString();
            if (q.isNotEmpty && a.isNotEmpty) out.add({'q': q, 'a': a});
          }
        }
      } else if (jsonAny is Map) {
        jsonAny.forEach((k, v) {
          final q = k.toString();
          final a = v.toString();
          if (q.isNotEmpty && a.isNotEmpty) out.add({'q': q, 'a': a});
        });
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  List<Map<String, String>> listFAQ() {
    return role == UserRole.internal ? _internal : _public;
  }

  Future<String> answer(String text) async {
    // Bản đơn giản (UI-first): nhắc dùng FAQ
    // Sau khi UI ổn, mình sẽ nâng cấp sang tìm gần-nghĩa.
    return 'Tính năng trả lời đang hoàn thiện. Bạn mở tab FAQ để tra cứu nhanh nhé.';
  }
}
