import 'package:flutter/material.dart';
import 'core/user_role.dart';
import 'features/login/login_screen.dart';
import 'features/home/home_shell.dart';

class SNPApp extends StatefulWidget {
  const SNPApp({super.key});
  @override
  State<SNPApp> createState() => _SNPAppState();
}

class _SNPAppState extends State<SNPApp> {
  UserRole role = UserRole.public;
  void setRole(UserRole r) => setState(() => role = r);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNP Chatbot',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      routes: {
        '/': (c) => LoginScreen(onPicked: setRole),
        '/home': (c) => HomeShell(role: role),
      },
    );
  }
}
