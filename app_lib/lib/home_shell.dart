import 'package:flutter/material.dart';
import 'qa_service.dart';
import 'chat_screen.dart';
import 'faq_screen.dart';
import 'tasks_screen.dart';
import 'admin_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  final UserRole role;
  const HomeShell({super.key, required this.role});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isInternal = widget.role == UserRole.internal;

    final pages = <Widget>[
      ChatScreen(role: widget.role),
      FAQScreen(role: widget.role),
      TasksScreen(role: widget.role),
      AdminScreen(role: widget.role),
      ProfileScreen(role: widget.role),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.help_outline), selectedIcon: Icon(Icons.help), label: 'FAQ'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), selectedIcon: Icon(Icons.admin_panel_settings), label: 'Admin'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
