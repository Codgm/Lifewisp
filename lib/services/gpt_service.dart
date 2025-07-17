import 'package:http/http.dart' as http;
import 'dart:convert';

class GPTService {
  final String apiKey;

  GPTService(this.apiKey);

  Future<Map<String, dynamic>> analyzeEmotion(String text) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4",
        "messages": [
          {"role": "system", "content": "너는 감정 분석가야. 사용자의 감정, 키워드, 감정 요약을 아래 JSON 형식으로 반환해줘. {\"main_emotion\": \"...\", \"sub_emotions\": [\"...\"], \"summary\": \"...\", \"keywords\": [\"...\"]}"},
          {"role": "user", "content": text}
        ]
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return jsonDecode(content);
    } else {
      throw Exception('Failed to analyze emotion');
    }
  }
} 