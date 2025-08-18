import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const SNPChatbotApp());
}

class SNPChatbotApp extends StatelessWidget {
  const SNPChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNP Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChatScreen(),
    );
  }
}
