import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../providers/language_provider.dart';

class AnthropicService {
  // Прямое обращение к Anthropic API
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _modelId = 'claude-3-5-haiku-20241022'; // Cheap model
  
  String get _apiKey => dotenv.env['ANTHROPIC_API_KEY'] ?? '';
  
  AppLanguage _language = AppLanguage.german; // Немецкий по умолчанию
  
  void setLanguage(AppLanguage language) {
    _language = language;
  }
  
  bool get _isGerman => _language == AppLanguage.german;

  Future<String> generateAIResponse(
    String topic,
    String userMessage, {
    List<String>? conversationContext,
  }) async {
    try {
      if (_apiKey.isEmpty) {
        return _isGerman 
            ? 'Fehler: API-Schlüssel nicht in .env-Datei gefunden'
            : 'Ошибка: API ключ не найден в .env файле';
      }

      // Добавляем стиль ответа прямо в запрос:
      // разговорно, без списков и сухих схем.
      final styleInstruction = _isGerman
          ? 'Du antwortest als fesselnder Erzähler zum Thema "$topic". '
              'Antworte in lebendiger, gesprochener Sprache, als zusammenhängender Text in mehreren Absätzen, '
              'ohne nummerierte Listen, Aufzählungen und trockene Schemata. '
              'Sprachniveau: B2.'
          : 'Ты отвечаешь как увлекательный рассказчик по теме "$topic". '
              'Отвечай живым устным языком, цельным текстом в нескольких абзацах, '
              'без нумерованных списков, пунктов и сухих конспектов.';

      final messages = [
        {
          'role': 'user',
          'content': '$styleInstruction\n\n${_isGerman ? "Frage des Nutzers" : "Вопрос пользователя"}: $userMessage',
        }
      ];

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
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
        if (content.isNotEmpty && content[0]['type'] == 'text') {
          return content[0]['text'] as String;
        }
        return _isGerman ? 'Antwort konnte nicht abgerufen werden' : 'Не удалось получить ответ';
      } else {
        final errorBody = response.body;
        return _isGerman 
            ? 'API-Fehler: ${response.statusCode} - $errorBody'
            : 'Ошибка API: ${response.statusCode} - $errorBody';
      }
    } catch (e) {
      return _isGerman ? 'Fehler bei der Verbindung: $e' : 'Ошибка при подключении: $e';
    }
  }

  Future<List<String>> generateSuggestedResponses(String topic) async {
    try {
      if (_apiKey.isEmpty) {
        return [];
      }

      final prompt = _isGerman
          ? 'Für das Thema "$topic" schlage 7 natürliche, gesprächige Fortsetzungen vor, '
              'jede als Frage formuliert (eine pro Zeile). Nicht nummerieren. '
              'Wichtig: Gib ausschließlich nichttriviale Fragen zur Verzweigung des Gesprächs — '
              'also Fragen, die das Gespräch vertiefen, in neue Richtungen lenken oder überraschen, '
              'keine oberflächlichen oder offensichtlichen Nachfragen.'
          : 'Для темы "$topic" предложи 7 естественных, разговорных продолжений в виде вопросов '
              '(по одному на строку). Нумеровать не нужно. '
              'Важно: давай только нетривиальные вопросы для разветвления разговора — '
              'то есть такие, которые углубляют беседу, поворачивают её в новое русло или удивляют, '
              'без поверхностных и очевидных уточнений.';

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
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
        if (content.isNotEmpty && content[0]['type'] == 'text') {
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
      if (_apiKey.isEmpty) {
        return _isGerman 
            ? 'Fehler: API-Schlüssel nicht in .env-Datei gefunden'
            : 'Ошибка: API ключ не найден в .env файле';
      }

      final prompt = _isGerman
          ? 'Beginne ein fesselndes Gespräch zum Thema "$topic" für einen gebildeten Menschen. '
              'Erzähle wie ein guter Redner: lebendig, bildhaft, ohne Listen und trockene Schemata, '
              'als zusammenhängender Text in mehreren Absätzen. Sprachniveau: B2. '
              'Länge: 200-300 Wörter.'
          : 'Начни увлекательный разговор на тему "$topic" для интеллигентного человека. '
              'Рассказывай как хороший оратор: живо, образно, без списков и сухих схем, цельным связным текстом в нескольких абзацах. '
              'Длина: 200-300 слов.';

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
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
        if (content.isNotEmpty && content[0]['type'] == 'text') {
          return content[0]['text'] as String;
        }
      }
      final errorBody = response.body;
      return _isGerman
          ? 'Anfangsnachricht konnte nicht geladen werden. Fehler: ${response.statusCode} - $errorBody'
          : 'Не удалось загрузить начальное сообщение. Ошибка: ${response.statusCode} - $errorBody';
    } catch (e) {
      return _isGerman ? 'Fehler bei der Verbindung: $e' : 'Ошибка при подключении: $e';
    }
  }
}
