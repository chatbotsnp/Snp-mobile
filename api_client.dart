import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  ApiClient(this.baseUrl);

  Future<String?> loginGuest() async {
    try {
      final res = await http.post(Uri.parse("\$baseUrl/auth/login"));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data["token"];
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<String?> ask(String token, String question) async {
    try {
      final res = await http.post(
        Uri.parse("\$baseUrl/ask"),
        headers: {"Authorization": "Bearer \$token"},
        body: {"question": question},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data["answer"];
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
