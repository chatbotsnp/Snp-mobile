
import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(const SnPApp());
}

class SnPApp extends StatelessWidget {
  const SnPApp({super.key});

  @override
  Widget build(BuildContext context) {
    const snpBlue = Color(0xFF0057A3);
    const snpAccent = Color(0xFFD71F26);

    return MaterialApp(
      title: 'SNP Chatbot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: snpBlue)
            .copyWith(secondary: snpAccent),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      ),
      home: const LoginScreen(),
    );
  }
}
