import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'notification_service.dart';

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dept': dept,
    'assignees': assignees,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'status': status,
    'color': colorHex,
    'updated_at': updatedAt?.toIso8601String(),
  };
}

class _Config {
  final bool remote;
  final String tasksUrl;
  final int timeoutSeconds;
  final int notifyLeadMinutes; // nhắc trước X phút (mặc định 15)

  _Config({
    required this.remote,
    required this.tasksUrl,
    required this.timeoutSeconds,
    required this.notifyLeadMinutes,
  });

  static Future<_Config> load() async {
    final raw = await rootBundle.loadString('assets/config.json');
    final j = json.decode(raw) as Map<String, dynamic>;
    return _Config(
      remote: (j['remote'] ?? false) == true,
      tasksUrl: (j['tasks_url'] ?? '').toString(),
      timeoutSeconds: int.tryParse('${j['timeout_seconds'] ?? 10}') ?? 10,
      notifyLeadMinutes: int.tryParse('${j['notify_lead_minutes'] ?? 15}') ?? 15,
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

  Future<File> _logFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tasks_log.json');
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
        // schedule nhắc cho dữ liệu hiện có
        _scheduleNotifications(cfg);
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
            _scheduleNotifications(cfg);
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
    _scheduleNotifications(cfg);
  }

  Future<void> refreshOnline() async => load(forceOnline: true);

  Future<List<TaskItem>> getAll() async {
    if (!_loaded) await load();
    return List<TaskItem>.from(_items);
  }

  Future<List<TaskItem>> filter({
    String? dept,
    String? assigneeKeyword,
    String? query,
    String? status,
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
    list.sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  // ====== Actions ======
  Future<void> markDone(String taskId) async {
    final idx = _items.indexWhere((t) => t.id == taskId);
    if (idx < 0) return;
    final t = _items[idx];
    final done = TaskItem(
      id: t.id,
      title: t.title,
      dept: t.dept,
      assignees: t.assignees,
      start: t.start,
      end: t.end,
      status: 'done',
      colorHex: t.colorHex,
      updatedAt: DateTime.now(),
    );
    _items[idx] = done;

    // lưu cache
    final jsonStr = json.encode(_items.map((e) => e.toJson()).toList());
    await _writeCache(jsonStr);

    await _logAction(taskId, 'done');
  }

  Future<void> _logAction(String taskId, String action) async {
    try {
      final f = await _logFile();
      List list = [];
      if (await f.exists()) {
        final txt = await f.readAsString();
        list = (json.decode(txt) as List?) ?? [];
      }
      list.add({
        'task_id': taskId,
        'action': action,
        'at': DateTime.now().toIso8601String(),
      });
      await f.writeAsString(json.encode(list), flush: true);
    } catch (_) {}
  }

  // ====== Notifications scheduling ======
  void _scheduleNotifications(_Config cfg) {
    // Nhắc trước X phút so với start, và trước khi end nếu chưa done
    final now = DateTime.now();

    for (final t in _items) {
      if (t.status == 'canceled' || t.status == 'done') continue;

      final lead = Duration(minutes: cfg.notifyLeadMinutes);
      final startWhen = t.start.subtract(lead);
      if (startWhen.isAfter(now)) {
        NotifService.schedule(
          _idFrom('start_${t.id}'),
          'Sắp đến: ${t.title}',
          'Phòng ${t.dept} — bắt đầu ${_fmtShort(t.start)}',
          startWhen,
        );
      }

      // Nhắc trước end  (chỉ nếu end > now)
      final endWhen = t.end.subtract(Duration(minutes: 5));
      if (endWhen.isAfter(now)) {
        NotifService.schedule(
          _idFrom('end_${t.id}'),
          'Sắp hết hạn: ${t.title}',
          'Kết thúc lúc ${_fmtShort(t.end)}',
          endWhen,
        );
      }
    }
  }

  int _idFrom(String s) {
    // Hash đơn giản ra số int cho notification id
    var h = 0;
    for (final codePoint in s.codeUnits) {
      h = (h * 31 + codePoint) & 0x7fffffff;
    }
    return h;
  }

  String _fmtShort(DateTime dt) =>
      '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')} '
      '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
}
