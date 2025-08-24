import 'dart:convert';
import 'package:flutter/services.dart';

class QaService {
  Map<String, String> _publicData = {};
  Map<String, String> _internalData = {};

  QaService() {
    _loadData();
  }

  Future<void> _loadData() async {
    String publicJson = await rootBundle.loadString('assets/faq_public.json');
    String internalJson = await rootBundle.loadString('assets/faq_internal.json');

    _publicData = Map<String, String>.from(json.decode(publicJson));
    _internalData = Map<String, String>.from(json.decode(internalJson));
  }

  String getAnswer(String question) {
    if (_publicData.containsKey(question)) {
      return _publicData[question]!;
    } else if (_internalData.containsKey(question)) {
      return _internalData[question]!;
    }
    return "Xin lỗi, tôi chưa có thông tin về câu hỏi này.";
  }
}
