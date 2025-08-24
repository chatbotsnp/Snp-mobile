import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(const SnpApp());
}

class SnpApp extends StatelessWidget {
  const SnpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNP Chatbot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A5DB6)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
