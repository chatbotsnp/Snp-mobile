import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String base;
  ApiClient(this.base);

  Future<Map<String, dynamic>> ask(String question, {String? token}) async {
    final r = await http.post(Uri.parse('$base/ask'),
        headers: {'Content-Type':'application/json', if (token != null) 'Authorization':'Bearer $token'},
        body: jsonEncode({'question': question}));
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
}
