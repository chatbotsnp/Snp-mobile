// lib/employee_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Model nhân sự
class Employee {
  final String code;      // Mã nhân viên duy nhất (ví dụ: SNP001)
  final String name;      // Tên
  final String dept;      // Phòng ban
  final bool isAdmin;     // Có quyền admin (quản trị)
  final bool isActive;    // Đang hoạt động

  const Employee({
    required this.code,
    required this.name,
    required this.dept,
    required this.isAdmin,
    required this.isActive,
  });

  Employee copyWith({
    String? code,
    String? name,
    String? dept,
    bool? isAdmin,
    bool? isActive,
  }) {
    return Employee(
      code: code ?? this.code,
      name: name ?? this.name,
      dept: dept ?? this.dept,
      isAdmin: isAdmin ?? this.isAdmin,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Employee.fromJson(Map<String, dynamic> j) {
    return Employee(
      code: (j['code'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      dept: (j['dept'] ?? '').toString(),
      isAdmin: (j['isAdmin'] ?? false) == true,
      isActive: (j['isActive'] ?? true) == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'dept': dept,
        'isAdmin': isAdmin,
        'isActive': isActive,
      };
}

/// Service quản lý danh sách nhân viên, lưu local JSON
class EmployeeService {
  static const _fileName = 'employees.json';

  Future<File> _ensureFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    if (!await file.exists()) {
      await file.create(recursive: true);
      // Tạo data mẫu lần đầu
      final seed = [
        Employee(
          code: 'SNP001',
          name: 'Nguyễn Văn A',
          dept: 'Khai thác Cảng',
          isAdmin: true,
          isActive: true,
        ).toJson(),
        Employee(
          code: 'SNP002',
          name: 'Trần Thị B',
          dept: 'Kinh doanh',
          isAdmin: false,
          isActive: true,
        ).toJson(),
      ];
      await file.writeAsString(jsonEncode(seed));
    }
    return file;
  }

  Future<List<Employee>> loadAll() async {
    final f = await _ensureFile();
    final raw = await f.readAsString();
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Employee.fromJson).toList(growable: true);
  }

  Future<void> _saveAll(List<Employee> items) async {
    final f = await _ensureFile();
    await f.writeAsString(jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  /// Tìm theo mã
  Future<Employee?> findByCode(String code) async {
    final items = await loadAll();
    try {
      return items.firstWhere((e) => e.code.toUpperCase() == code.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  /// Thêm mới hoặc cập nhật theo code (upsert)
  Future<void> add(Employee e) async {
    final items = await loadAll();
    final idx = items.indexWhere((x) => x.code.toUpperCase() == e.code.toUpperCase());
    if (idx >= 0) {
      items[idx] = e;
    } else {
      items.add(e);
    }
    await _saveAll(items);
  }

  /// Xóa theo mã
  Future<void> remove(String code) async {
    final items = await loadAll();
    items.removeWhere((x) => x.code.toUpperCase() == code.toUpperCase());
    await _saveAll(items);
  }
}
