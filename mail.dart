import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(const SnPApp());
}

class SnPApp extends StatelessWidget {
  const SnPApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Màu sắc theo tông SNP (xanh dương đậm + đỏ cờ làm accent)
    const snpBlue = Color(0xFF0057A3);
    const snpAccent = Color(0xFFD71F26);

    return MaterialApp(
      title: 'SNP Chatbot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: snpBlue,
        colorScheme: ColorScheme.fromSeed(seedColor: snpBlue)
            .copyWith(secondary: snpAccent),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      ),
      home: const LoginScreen(),
    );
  }
}
