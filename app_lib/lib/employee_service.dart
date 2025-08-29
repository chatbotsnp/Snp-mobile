import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Model nhân sự
class Employee {
  final String code;     // mã NV (duy nhất)
  final String name;     // tên
  final String dept;     // phòng ban
  final bool isAdmin;    // có quyền Admin trong app
  final bool isActive;   // còn hiệu lực

  const Employee({
    required this.code,
    required this.name,
    required this.dept,
    required this.isAdmin,
    required this.isActive,
  });

  factory Employee.fromJson(Map<String, dynamic> j) => Employee(
        code: (j['code'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        dept: (j['dept'] ?? '').toString(),
        isAdmin: (j['isAdmin'] is bool)
            ? j['isAdmin'] as bool
            : j['isAdmin']?.toString().toLowerCase() == 'true',
        isActive: (j['isActive'] is bool)
            ? j['isActive'] as bool
            : j['isActive']?.toString().toLowerCase() != 'false',
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'dept': dept,
        'isAdmin': isAdmin,
        'isActive': isActive,
      };
}

/// Service quản lý danh sách nhân sự (lưu local JSON)
class EmployeeService {
  static const _fileName = 'employees.json';

  List<Employee> _cache = [];

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final f = File('${dir.path}/$_fileName');
    if (!(await f.exists())) {
      // seed rỗng lần đầu
      await f.writeAsString(jsonEncode(<Map<String, dynamic>>[]));
    }
    return f;
  }

  /// Đọc hết danh sách
  Future<List<Employee>> loadAll() async {
    if (_cache.isNotEmpty) return _cache;
    final f = await _getFile();
    final raw = await f.readAsString();
    final data = (jsonDecode(raw) as List)
        .map((e) => Employee.fromJson(e as Map<String, dynamic>))
        .toList();
    _cache = data;
    return _cache;
  }

  /// Lưu cache ra file
  Future<void> _flush() async {
    final f = await _getFile();
    final data = _cache.map((e) => e.toJson()).toList();
    await f.writeAsString(jsonEncode(data));
  }

  /// Tìm theo mã
  Future<Employee?> findByCode(String code) async {
    final all = await loadAll();
    try {
      return all.firstWhere(
          (e) => e.code.trim().toLowerCase() == code.trim().toLowerCase());
    } catch (_) {
      return null;
    }
  }

  /// Thêm/cập nhật (nếu trùng code thì ghi đè)
  Future<void> add(Employee e) async {
    await loadAll();
    _cache.removeWhere(
        (x) => x.code.trim().toLowerCase() == e.code.trim().toLowerCase());
    _cache.add(e);
    await _flush();
  }

  /// Xóa theo mã
  Future<void> remove(String code) async {
    await loadAll();
    _cache.removeWhere(
        (x) => x.code.trim().toLowerCase() == code.trim().toLowerCase());
    await _flush();
  }
}
