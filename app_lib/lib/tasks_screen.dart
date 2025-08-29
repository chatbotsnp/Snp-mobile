import 'package:flutter/material.dart';
import 'task_service.dart';
import 'qa_service.dart';

class TasksScreen extends StatefulWidget {
  final dynamic role;
  const TasksScreen({super.key, required this.role});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _svc = TaskService();

  final _deptCtrl = TextEditingController();
  final _assigneeCtrl = TextEditingController(); // tên hoặc mã
  final _searchCtrl = TextEditingController();
  String? _status; // all/scheduled/in_progress/done/canceled

  bool _loading = true;
  bool _syncing = false;
  List<TaskItem> _items = [];

  bool get _isInternal => QAService(role: widget.role).isInternal;

  @override
  void initState() {
    super.initState();
    _load(initial: true);
  }

  Future<void> _load({bool initial = false}) async {
    setState(() {
      if (initial) _loading = true;
      _syncing = !initial;
    });
    if (initial) {
      await _svc.load();
    } else {
      await _svc.refreshOnline();
    }
    await _applyFilter();
    setState(() {
      _loading = false;
      _syncing = false;
    });
  }

  Future<void> _applyFilter() async {
    final status = (_status == null || _status == 'all') ? null : _status;
    final list = await _svc.filter(
      dept: _deptCtrl.text,
      assigneeKeyword: _assigneeCtrl.text,
      query: _searchCtrl.text,
      status: status,
    );
    setState(() => _items = list);
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'done':
        return Colors.green.shade600;
      case 'in_progress':
        return Colors.orange.shade700;
      case 'canceled':
        return Colors.red.shade600;
      default:
        return Colors.blueGrey.shade600;
    }
  }

  String _fmtDT(DateTime dt) {
    return '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')} '
           '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  @override
  void dispose() {
    _deptCtrl.dispose();
    _assigneeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInternal) {
      return const Scaffold(
        body: Center(child: Text('Khu vực nội bộ. Vui lòng đăng nhập nhân viên.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks / Nhắc việc'),
        actions: [
          IconButton(
            tooltip: 'Đồng bộ lịch',
            onPressed: _syncing ? null : () => _load(initial: false),
            icon: _syncing
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.sync),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Bộ lọc
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: 180,
                        child: TextField(
                          controller: _deptCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Phòng ban',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => _applyFilter(),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _assigneeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Tên/Mã người nhận',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => _applyFilter(),
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Từ khoá tiêu đề',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => _applyFilter(),
                        ),
                      ),
                      DropdownButton<String>(
                        value: _status ?? 'all',
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                          DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                          DropdownMenuItem(value: 'in_progress', child: Text('In progress')),
                          DropdownMenuItem(value: 'done', child: Text('Done')),
                          DropdownMenuItem(value: 'canceled', child: Text('Canceled')),
                        ],
                        onChanged: (v) {
                          setState(() => _status = v);
                          _applyFilter();
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Danh sách
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _load(initial: false),
                    child: _items.isEmpty
                        ? const ListTile(
                            title: Text('Không có công việc nào phù hợp bộ lọc.'),
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final t = _items[i];
                              final color = _statusColor(t.status);
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: color.withOpacity(0.15),
                                  child: Icon(Icons.event_note, color: color),
                                ),
                                title: Text(t.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Phòng: ${t.dept} · ${t.status}'),
                                    Text('Thời gian: ${_fmtDT(t.start)} → ${_fmtDT(t.end)}'),
                                    if (t.assignees.isNotEmpty)
                                      Text('Thành phần: ${t.assignees.join(", ")}'),
                                    if (t.updatedAt != null)
                                      Text('Cập nhật: ${_fmtDT(t.updatedAt!)}'),
                                  ],
                                ),
                                trailing: t.status != 'done'
                                    ? IconButton(
                                        icon: const Icon(Icons.check_circle, color: Colors.green),
                                        tooltip: 'Đánh dấu hoàn thành',
                                        onPressed: () async {
                                          await _svc.markDone(t.id);
                                          await _applyFilter();
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Đã hoàn thành task ${t.id}')),
                                            );
                                          }
                                        },
                                      )
                                    : null,
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
