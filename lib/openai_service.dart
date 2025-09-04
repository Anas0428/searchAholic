import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String baseUrl = "http://10.0.2.2:3000";
  // ⚠️ Use 10.0.2.2 instead of localhost for Android emulator
  // For iOS simulator use: http://localhost:3000
  // For real device, use your PC IP: http://192.168.x.x:3000

  Future<String> search(String query) async {
    final uri = Uri.parse('$baseUrl/api/chat');

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "messages": [
          {"role": "user", "content": query}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["text"] ?? "No response";
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }
}
