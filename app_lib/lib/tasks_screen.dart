import 'package:flutter/material.dart';
import 'qa_service.dart';

class TasksScreen extends StatelessWidget {
  final UserRole role;
  const TasksScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isInternal = role == UserRole.internal;
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks / Nhắc việc')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isInternal
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tính năng sắp có:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('• Import lịch làm việc (Excel/CSV)'),
                  const Text('• Map theo phòng ban/người nhận'),
                  const Text('• Nhắc trước hạn, xác nhận hoàn thành'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: null, // sẽ bật sau
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Import lịch (sắp ra mắt)'),
                  ),
                ],
              )
            : const Center(
                child: Text('Khu vực nội bộ. Vui lòng đăng nhập Nhân viên để sử dụng.'),
              ),
      ),
    );
  }
}
