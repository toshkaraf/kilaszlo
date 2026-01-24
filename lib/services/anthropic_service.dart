import 'package:http/http.dart' as http;
import 'dart:convert';

class AnthropicService {
  static const String _apiKey = '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'; // Replace with actual key
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _modelId = 'claude-3-5-haiku-20241022'; // Cheap model

  Future<String> generateAIResponse(
    String topic,
    String userMessage, {
    List<String>? conversationContext,
  }) async {
    try {
      final messages = [
        {
          'role': 'user',
          'content': userMessage,
        }
      ];

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _modelId,
          'max_tokens': 1024,
          'messages': messages,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final content = jsonResponse['content'] as List;
        if (content.isNotEmpty) {
          return content[0]['text'] as String;
        }
        return 'Не удалось получить ответ';
      } else {
        return 'Ошибка API: ${response.statusCode}';
      }
    } catch (e) {
      return 'Ошибка при подключении: $e';
    }
  }

  Future<List<String>> generateSuggestedResponses(String topic) async {
    try {
      final prompt =
          'Для темы "$topic" предложи 5 направлений дальнейшего развития беседы в виде коротких предложений (по одному на строку). Нумеровать не нужно.';

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _modelId,
          'max_tokens': 500,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final content = jsonResponse['content'] as List;
        if (content.isNotEmpty) {
          final text = content[0]['text'] as String;
          return text
              .split('\n')
              .where((line) => line.trim().isNotEmpty)
              .map((line) => line.trim())
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<String> generateInitialMessage(String topic) async {
    try {
      final prompt =
          'Начни увлекательный разговор на тему "$topic" для интеллигентного человека. Сделай это информативно и интересно. Длина: 200-300 слов.';

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _modelId,
          'max_tokens': 1024,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final content = jsonResponse['content'] as List;
        if (content.isNotEmpty) {
          return content[0]['text'] as String;
        }
      }
      return 'Не удалось загрузить начальное сообщение';
    } catch (e) {
      return 'Ошибка при подключении: $e';
    }
  }
}
