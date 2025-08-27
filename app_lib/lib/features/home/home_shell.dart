import 'package:flutter/material.dart';
import '../../core/user_role.dart';

class HomeShell extends StatefulWidget {
  final UserRole role;
  const HomeShell({super.key, required this.role});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      const Center(child: Text('Chat (UI sẽ thêm sau)')),
      const Center(child: Text('FAQ (UI sẽ thêm sau)')),
      const Center(child: Text('Tra cứu (UI sẽ thêm sau)')),
      const Center(child: Text('Thông báo (UI sẽ thêm sau)')),
      Center(child: Text('Tài khoản – ${widget.role.name}')),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.help_outline), label: 'FAQ'),
          NavigationDestination(icon: Icon(Icons.folder_open), label: 'Tra cứu'),
          NavigationDestination(icon: Icon(Icons.notifications_none), label: 'Thông báo'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Tài khoản'),
        ],
      ),
    );
  }
}
