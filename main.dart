import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() => runApp(const SNPApp());

class SNPApp extends StatelessWidget {
  const SNPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNP Chatbot',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF005BAC),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
