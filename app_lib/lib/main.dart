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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
