import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class TaskItem {
  final String id;
  final String title;
  final String dept;
  final List<String> assignees; // mã hoặc tên
  final DateTime start;
  final DateTime end;
  final String status;          // scheduled | in_progress | done | canceled
  final String? colorHex;       // #RRGGBB
  final DateTime? updatedAt;

  TaskItem({
    required this.id,
    required this.title,
    required this.dept,
    required this.assignees,
    required this.start,
    required this.end,
    required this.status,
    this.colorHex,
    this.updatedAt,
  });

  factory TaskItem.fromJson(Map<String, dynamic> j) {
    DateTime? parseDT(String? s) {
      if (s == null || s.trim().isEmpty) return null;
      return DateTime.tryParse(s);
    }

    final a = <String>[];
    final rawA = j['assignees'];
    if (rawA is List) {
      for (final x in rawA) {
        if (x != null) a.add(x.toString());
      }
    }

    return TaskItem(
      id: (j['id'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      dept: (j['dept'] ?? '').toString(),
      assignees: a,
      start: parseDT(j['start']) ?? DateTime.now(),
      end: parseDT(j['end']) ?? DateTime.now(),
      status: (j['status'] ?? 'scheduled').toString(),
      colorHex: (j['color'] ?? j['color_hex'])?.toString(),
      updatedAt: parseDT(j['updated_at']),
    );
  }
}

class _Config {
  final bool remote;
  final String tasksUrl;
  final int timeoutSeconds;

  _Config({required this.remote, required this.tasksUrl, required this.timeoutSeconds});

  static Future<_Config> load() async {
    final raw = await rootBundle.loadString('assets/config.json');
    final j = json.decode(raw) as Map<String, dynamic>;
    return _Config(
      remote: (j['remote'] ?? false) == true,
      tasksUrl: (j['tasks_url'] ?? '').toString(),
      timeoutSeconds: int.tryParse('${j['timeout_seconds'] ?? 10}') ?? 10,
    );
  }
}

class TaskService {
  List<TaskItem> _items = [];
  bool _loaded = false;

  Future<File> _cacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tasks_cache.json');
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

  List<TaskItem> _parse(String text) {
    try {
      final data = json.decode(text);
      final List list = (data is List)
          ? data
          : (data is Map<String, dynamic>)
              ? (data['tasks'] ?? data['items'] ?? []) as List
              : <dynamic>[];
      return list.map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return <TaskItem>[];
    }
  }

  Future<void> load({bool forceOnline = false}) async {
    final cfg = await _Config.load();

    // 0) cache trước nếu không ép online
    if (!forceOnline) {
      final cached = await _readCache();
      if (cached != null) {
        _items = _parse(cached);
        _loaded = true;
        _refreshOnlineSilently(cfg);
        return;
      }
    }

    // 1) online-first
    if (cfg.remote || forceOnline) {
      if (cfg.tasksUrl.isNotEmpty) {
        try {
          final res = await http
              .get(Uri.parse(cfg.tasksUrl))
              .timeout(Duration(seconds: cfg.timeoutSeconds));
          if (res.statusCode == 200 && res.body.isNotEmpty) {
            _items = _parse(res.body);
            _loaded = true;
            await _writeCache(res.body);
            return;
          }
        } catch (_) {}
      }
    }

    // 2) fallback assets
    final raw = await rootBundle.loadString('assets/tasks.json');
    _items = _parse(raw);
    _loaded = true;
    await _writeCache(raw);
  }

  Future<void> refreshOnline() async => load(forceOnline: true);

  Future<List<TaskItem>> getAll() async {
    if (!_loaded) await load();
    return List<TaskItem>.from(_items);
  }

  // ====== Bộ lọc ======
  Future<List<TaskItem>> filter({
    String? dept,
    String? assigneeKeyword, // tên hoặc mã
    String? query,           // từ khoá tự do trên title
    String? status,          // scheduled/in_progress/done/canceled
    DateTime? from,
    DateTime? to,
  }) async {
    if (!_loaded) await load();
    bool match(TaskItem t) {
      if (dept != null && dept.trim().isNotEmpty) {
        if (t.dept.toLowerCase() != dept.trim().toLowerCase()) return false;
      }
      if (assigneeKeyword != null && assigneeKeyword.trim().isNotEmpty) {
        final key = assigneeKeyword.trim().toLowerCase();
        final hit = t.assignees.any((a) => a.toLowerCase().contains(key));
        if (!hit) return false;
      }
      if (query != null && query.trim().isNotEmpty) {
        final k = query.trim().toLowerCase();
        if (!t.title.toLowerCase().contains(k)) return false;
      }
      if (status != null && status.trim().isNotEmpty) {
        if (t.status.toLowerCase() != status.trim().toLowerCase()) return false;
      }
      if (from != null && t.end.isBefore(from)) return false;
      if (to != null && t.start.isAfter(to)) return false;
      return true;
    }

    final list = _items.where(match).toList();
    list.sort((a, b) => a.start.compareTo(b.start)); // gần nhất lên trước
    return list;
  }

  void _refreshOnlineSilently(_Config cfg) async {
    if (!cfg.remote || cfg.tasksUrl.isEmpty) return;
    try {
      final res = await http
          .get(Uri.parse(cfg.tasksUrl))
          .timeout(Duration(seconds: cfg.timeoutSeconds));
      if (res.statusCode == 200 && res.body.isNotEmpty) {
        await _writeCache(res.body);
      }
    } catch (_) {}
  }
}
