import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Employee {
  final String id;       // uuid ngắn
  final String name;
  final String code;     // mã đăng nhập
  final String dept;
  final bool isAdmin;
  final bool isActive;

  Employee({
    required this.id,
    required this.name,
    required this.code,
    required this.dept,
    this.isAdmin = false,
    this.isActive = true,
  });

  factory Employee.fromJson(Map<String, dynamic> j) => Employee(
        id: j['id'] as String,
        name: j['name'] as String,
        code: j['code'] as String,
        dept: j['dept'] as String? ?? '',
        isAdmin: j['isAdmin'] as bool? => true ?? false,
        isActive: j['isActive'] as bool? => true ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'dept': dept,
        'isAdmin': isAdmin,
        'isActive': isActive,
      };
}

class EmployeeService {
  static final EmployeeService _inst = EmployeeService._();
  EmployeeService._();
  factory EmployeeService() => _inst;

  static const _fileName = 'employees.json';

  Future<File> _dataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Nạp danh sách nhân viên. Nếu chưa có file thì tạo file mẫu.
  Future<List<Employee>> loadAll() async {
    final f = await _dataFile();
    if (!await f.exists()) {
      await f.writeAsString(jsonEncode([
        {
          'id': 'emp-001',
          'name': 'Quản trị',
          'code': 'admin',   // đăng nhập admin mặc định
          'dept': 'IT',
          'isAdmin': true,
          'isActive': true
        },
        {
          'id': 'emp-002',
          'name': 'Nhân viên demo',
          'code': '1234',
          'dept': 'CSKH',
          'isAdmin': false,
          'isActive': true
        }
      ]));
    }
    final text = await f.readAsString();
    final list = (jsonDecode(text) as List).cast<Map<String, dynamic>>();
    return list.map(Employee.fromJson).toList();
  }

  Future<void> saveAll(List<Employee> items) async {
    final f = await _dataFile();
    await f.writeAsString(jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<void> add(Employee e) async {
    final all = await loadAll();
    all.add(e);
    await saveAll(all);
  }

  Future<void> remove(String id) async {
    final all = await loadAll();
    all.removeWhere((e) => e.id == id);
    await saveAll(all);
  }

  Future<Employee?> findByCode(String code) async {
    final all = await loadAll();
    try {
      return all.firstWhere((e) => e.code.trim() == code.trim());
    } catch (_) {
      return null;
    }
  }
}
