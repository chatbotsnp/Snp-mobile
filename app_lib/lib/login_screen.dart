import 'package:flutter/material.dart';
import 'home_shell.dart';
import 'qa_service.dart';
import 'employee_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _codeCtrl = TextEditingController();
  final _dobCtrl  = TextEditingController();
  final _formKey  = GlobalKey<FormState>();
  final _empSvc   = EmployeeService();
  bool _loading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  void _goPublic() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HomeShell(role: UserRole.public)),
    );
  }

  Future<void> _loginInternal() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final emp = await _empSvc.authenticate(
        code: _codeCtrl.text,
        dobInput: _dobCtrl.text,
      );
      if (emp != null) {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HomeShell(role: UserRole.internal)),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sai Mã NV hoặc Ngày sinh.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi khi xác thực.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _require(String? v) => (v == null || v.trim().isEmpty) ? 'Không được để trống' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Public
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Khách hàng (Public)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Tra cứu nội dung public mà không cần đăng nhập.'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _goPublic,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Vào khu vực Khách hàng'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Internal
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nhân viên (Internal)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Đăng nhập bằng Mã NV & Ngày sinh (YYYY-MM-DD hoặc dd/mm/yyyy).'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _codeCtrl,
                        decoration: const InputDecoration(labelText: 'Mã nhân viên', border: OutlineInputBorder()),
                        textInputAction: TextInputAction.next,
                        validator: _require,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dobCtrl,
                        decoration: const InputDecoration(labelText: 'Ngày sinh', border: OutlineInputBorder()),
                        keyboardType: TextInputType.datetime,
                        textInputAction: TextInputAction.done,
                        validator: _require,
                        onFieldSubmitted: (_) => _loginInternal(),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _loginInternal,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: _loading
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Đăng nhập nội bộ'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
