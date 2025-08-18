import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  ApiClient(this.baseUrl);

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        body: {'message': message},
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'Lỗi server: ${response.statusCode}';
      }
    } catch (e) {
      return 'Không thể kết nối: $e';
    }
  }
}
