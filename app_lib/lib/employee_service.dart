import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'models/user_role.dart';

class Employee {
  final String id;
  final String name;
  final String phone;
  final bool isAdmin;
  final bool isActive;

  const Employee({
    required this.id,
    required this.name,
    required this.phone,
    required this.isAdmin,
    required this.isActive,
  });

  factory Employee.fromJson(Map<String, dynamic> j) {
    return Employee(
      id: (j['id'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      phone: (j['phone'] ?? '').toString(),
      // quan trọng: dùng ?? thay vì =>
      isAdmin: (j['isAdmin'] as bool?) ?? false,
      isActive: (j['isActive'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'isAdmin': isAdmin,
        'isActive': isActive,
      };
}

class EmployeeService {
  EmployeeService._();
  static final EmployeeService _instance = EmployeeService._();
  factory EmployeeService() => _instance;

  final List<Employee> _cache = [];

  /// Nạp dữ liệu mẫu từ assets (nếu bạn có file),
  /// nếu không có sẽ dùng seed mặc định.
  Future<void> load({String? assetPath}) async {
    if (_cache.isNotEmpty) return;

    if (assetPath != null) {
      try {
        final raw = await rootBundle.loadString(assetPath);
        final list = (jsonDecode(raw) as List)
            .map((e) => Employee.fromJson(e as Map<String, dynamic>))
            .toList();
        _cache
          ..clear()
          ..addAll(list);
        return;
      } catch (_) {
        // fallthrough dùng seed mặc định
      }
    }

    // Seed mặc định (để demo đăng nhập/ phân quyền)
    _cache
      ..clear()
      ..addAll([
        const Employee(
          id: '1',
          name: 'Admin',
          phone: '0900000001',
          isAdmin: true,
          isActive: true,
        ),
        const Employee(
          id: '2',
          name: 'Nhân viên A',
          phone: '0900000002',
          isAdmin: false,
          isActive: true,
        ),
        const Employee(
          id: '3',
          name: 'Nhân viên B (khóa)',
          phone: '0900000003',
          isAdmin: false,
          isActive: false,
        ),
      ]);
  }

  List<Employee> all() => List.unmodifiable(_cache);

  Employee? findByPhone(String phone) {
    try {
      return _cache.firstWhere((e) => e.phone == phone);
    } catch (_) {
      return null;
    }
  }

  /// Trả về role dựa trên nhân sự
  UserRole roleOf(Employee e) {
    if (e.isAdmin) return UserRole.admin;
    return UserRole.internal;
  }
}
