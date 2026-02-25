import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../providers/language_provider.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _modelId = 'gemini-2.0-flash';

  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  AppLanguage _language = AppLanguage.german; // Немецкий по умолчанию

  void setLanguage(AppLanguage language) {
    _language = language;
  }

  bool get _isGerman => _language == AppLanguage.german;

  Uri _buildUri() {
    return Uri.parse('$_baseUrl/$_modelId:generateContent?key=${_apiKey}');
  }

  /// При ошибке API (например квота) бросает [Exception] с понятным текстом.
  /// Полный ответ API пишется в логи для отладки.
  Future<String> _extractTextFromResponse(http.Response response) async {
    if (response.statusCode != 200) {
      final errorBody = response.body;
      // В лог — полный ответ, как раньше показывалось в UI
      debugPrint('[Gemini API] HTTP ${response.statusCode}');
      debugPrint('[Gemini API] $errorBody');
      final isQuota = response.statusCode == 429 ||
          errorBody.contains('RESOURCE_EXHAUSTED') ||
          errorBody.contains('quota') ||
          errorBody.contains('rate');
      if (isQuota) {
        throw Exception(_isGerman
            ? 'Das Kontingent der KI ist aufgebraucht. Bitte in 15–20 Sekunden erneut versuchen oder Plan prüfen.'
            : 'Исчерпан лимит запросов к ИИ. Попробуйте через 15–20 секунд или проверьте тариф.');
      }
      throw Exception(_isGerman
          ? 'API-Fehler: ${response.statusCode}. Bitte später erneut versuchen.'
          : 'Ошибка API: ${response.statusCode}. Попробуйте позже.');
    }

    try {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = jsonResponse['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        return _isGerman
            ? 'Antwort konnte nicht abgerufen werden'
            : 'Не удалось получить ответ';
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        return _isGerman
            ? 'Antwort konnte nicht abgerufen werden'
            : 'Не удалось получить ответ';
      }

      final firstPart = parts[0] as Map<String, dynamic>;
      final text = firstPart['text'];
      if (text is String && text.trim().isNotEmpty) {
        return text;
      }

      return _isGerman
          ? 'Antwort konnte nicht abgerufen werden'
          : 'Не удалось получить ответ';
    } catch (e) {
      return _isGerman
          ? 'Fehler bei der Verarbeitung der Antwort: $e'
          : 'Ошибка при обработке ответа: $e';
    }
  }

  /// Отбрасывает строки, похожие на вводную фразу ИИ (например "Okay, hier sind 5 interessante...").
  bool _looksLikeIntroLine(String line) {
    final lower = line.toLowerCase().trim();
    if (lower.length > 120) return true;
    final introStarts = [
      'okay,', 'ok,', 'also,', 'so,', 'nun,', 'hier sind', 'here are', 'here is',
      'die folgenden', 'folgende', 'die 5 ', 'these are', 'вот ', 'итак', 'например,',
      'genau 5', 'exactly 5', 'fünf ', '5 interessante', '5 interesting',
    ];
    if (introStarts.any((s) => lower.startsWith(s))) return true;
    if (RegExp(r'^\d+\s*(interessante|interesting|titels?|aspects?|fakten)', caseSensitive: false).hasMatch(lower)) return true;
    if (lower.contains('die neugierig machen') || lower.contains('neugierig machen sollen')) return true;
    if (lower.contains('im bereich ') && lower.contains('die ')) return true;
    return false;
  }

  /// Убирает звёздочки, тире, нумерацию в начале и конце строки (для текста кнопок).
  String _cleanBulletLine(String line) {
    var text = line.trim();
    // Начало: маркеры и нумерация
    while (text.isNotEmpty) {
      final before = text;
      if (text.startsWith('*') || text.startsWith('•') || text.startsWith('-')) {
        text = text.substring(1).trim();
      } else if (RegExp(r'^\d+[.)]\s*').hasMatch(text)) {
        text = text.replaceFirst(RegExp(r'^\d+[.)]\s*'), '').trim();
      } else {
        break;
      }
      if (text == before) break;
    }
    // Конец: звёздочки и прочие маркеры (часто ** в конце)
    while (text.isNotEmpty) {
      final before = text;
      if (text.endsWith('*') || text.endsWith('•') || text.endsWith('-')) {
        text = text.substring(0, text.length - 1).trim();
      } else {
        break;
      }
      if (text == before) break;
    }
    return text;
  }

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

      final styleInstruction = _isGerman
          ? 'Du antwortest als fesselnder Erzähler zum Thema "$topic". '
              'Der Nutzer wählt einen Aspekt/Fakt – erkläre genau diesen kurz und lebendig. '
              'WICHTIG: Beginne deine Antwort immer mit einer kurzen mündlichen Wiederholung oder Umformulierung der Frage des Nutzers (z. B. "Du fragst nach …" oder "Zu deiner Frage, warum … – dazu …"), damit der Nutzer sich erinnert, worum es geht. Danach folgt deine eigentliche Erklärung. '
              'Antworte in gesprochener Sprache, als zusammenhängender Text in mehreren Absätzen, '
              'ohne nummerierte Listen und Aufzählungen. '
              'Länge: maximal 10 Sätze; nur wenn nötig für minimales Erschließen des Themas, bis zu 15 Sätze. Sprachniveau: B2.'
          : 'Ты отвечаешь как увлекательный рассказчик по теме "$topic". '
              'Пользователь выбрал аспект/факт – расскажи именно о нём, кратко и живо. '
              'ВАЖНО: Начинай ответ всегда с краткого устного повторения или переформулировки вопроса пользователя (например: "Ты спрашиваешь о …" или "К твоему вопросу о том, почему … – вот …"), чтобы пользователь вспомнил, о чём речь. Затем идёт твой основной рассказ. '
              'Отвечай устным языком, связным текстом в нескольких абзацах, без списков и пунктов. '
              'Объём: не больше 10 предложений; только если нужно минимально раскрыть тему — до 15 предложений.';

      final contextText = (conversationContext ?? []).join('\n');

      final promptText = StringBuffer()
        ..writeln(styleInstruction)
        ..writeln()
        ..writeln(_isGerman ? 'Auswahl des Nutzers:' : 'Выбор пользователя:')
        ..writeln(userMessage);

      if (contextText.isNotEmpty) {
        promptText
          ..writeln()
          ..writeln(_isGerman ? 'Kontext (vorherige Runden):' : 'Контекст (предыдущие реплики):')
          ..writeln(contextText);
      }

      final body = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': promptText.toString()},
            ],
          }
        ],
        'generationConfig': {
          'maxOutputTokens': 1024,
        },
      };

      final response = await http
          .post(
            _buildUri(),
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': _apiKey,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      return await _extractTextFromResponse(response);
    } catch (e) {
      return _isGerman
          ? 'Fehler bei der Verbindung: $e'
          : 'Ошибка при подключении: $e';
    }
  }

  /// Erste Runde: genau 5 kurze, prägnante Titel interessanter Fakten zum Thema (für Buttons).
  Future<List<String>> generateInitialFactSuggestions(String topic) async {
    try {
      if (_apiKey.isEmpty) return [];

      final prompt = _isGerman
          ? 'Zum Thema "$topic": Nenne genau 5 interessante, konkrete Fakten oder Aspekte als kurze Titel (z. B. "Warum die Pyramiden so stabil sind"). '
              'Eine Zeile pro Titel, keine Nummerierung, keine Einleitungszeile (kein "Okay, hier sind 5..." o. ä.). Nur die 5 Titel.'
          : 'По теме "$topic": назови ровно 5 интересных конкретных фактов или аспектов короткими заголовками (например: "Почему пирамиды такие устойчивые"). '
              'Одна строка на заголовок, без нумерации, без вводной фразы (без "Вот 5..." и т.п.). Только 5 заголовков.';

      final body = {
        'contents': [{'role': 'user', 'parts': [{'text': prompt}]}],
        'generationConfig': {'maxOutputTokens': 400},
      };

      final response = await http
          .post(_buildUri(), headers: {'Content-Type': 'application/json', 'x-goog-api-key': _apiKey}, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      final text = await _extractTextFromResponse(response);
      final list = text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map(_cleanBulletLine)
          .where((line) => line.isNotEmpty && !_looksLikeIntroLine(line))
          .toList();
      return list.take(5).toList();
    } catch (_) {
      return [];
    }
  }

  /// Folgerunden: 5 weitere Fakten-Buttons – Vertiefung zum gewählten Fakt oder verwandte Aspekte (Fragen vorwegnehmen).
  Future<List<String>> generateFollowUpFactSuggestions(
    String topic,
    String userChoice,
    String lastAiAnswer,
  ) async {
    try {
      if (_apiKey.isEmpty) return [];

      final prompt = _isGerman
          ? 'Thema: "$topic". Der Nutzer hat gewählt: "$userChoice". Deine letzte Antwort war (Auszug): "$lastAiAnswer". '
              'Nenne genau 5 weitere kurze Titel (eine pro Zeile, keine Nummerierung, keine Einleitungszeile): '
              'entweder Vertiefungen zu diesem Fakt oder thematisch nahe Fakten. Nur die 5 Titel.'
          : 'Тема: "$topic". Пользователь выбрал: "$userChoice". Твой последний ответ (выдержка): "$lastAiAnswer". '
              'Назови ровно 5 следующих коротких заголовков (по одному на строку, без нумерации и без вводной фразы): '
              'либо углубление этого факта, либо смежные факты. Только 5 заголовков.';

      final body = {
        'contents': [{'role': 'user', 'parts': [{'text': prompt}]}],
        'generationConfig': {'maxOutputTokens': 400},
      };

      final response = await http
          .post(_buildUri(), headers: {'Content-Type': 'application/json', 'x-goog-api-key': _apiKey}, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      final text = await _extractTextFromResponse(response);
      final list = text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map(_cleanBulletLine)
          .where((line) => line.isNotEmpty && !_looksLikeIntroLine(line))
          .toList();
      return list.take(5).toList();
    } catch (_) {
      return [];
    }
  }

  @Deprecated('Use generateInitialFactSuggestions or generateFollowUpFactSuggestions')
  Future<List<String>> generateSuggestedResponses(String topic) async {
    return generateInitialFactSuggestions(topic);
  }

  static final List<String> _introPhrasesDe = [
    'Zu diesem Thema gibt es viele spannende Aspekte. Wähle einen aus – dann erzähle ich dir mehr dazu.',
    'Dieses Thema steckt voller Überraschungen. Such dir einen Punkt aus, und ich vertiefe ihn.',
    'Hier gibt es einiges zu entdecken. Wähle einen Aspekt, und ich nehme dich mit.',
    'Spannende Facetten warten auf dich. Klick einen an – ich erzähle dazu.',
    'Das Thema hat viele Seiten. Entscheide dich für eine, dann lege ich los.',
    'Ein weites Feld – wähle einen Einstieg, und ich mache daraus eine kleine Geschichte.',
    'Interessante Details gibt es zuhauf. Nimm einen zur Hand, ich fülle ihn aus.',
    'Du hast die Wahl: Such dir einen der Aspekte aus, ich ergänze den Rest.',
    'Viele spannende Fäden führen hier weiter. Zieh an einem – ich spinne ihn weiter.',
    'Zu diesem Thema kann ich dir einiges erzählen. Wähle einen Schwerpunkt.',
    'Hier lohnt sich genaueres Hinsehen. Such dir einen Punkt aus.',
    'Ein Thema mit Tiefe – wähle einen Zugang, dann geht es los.',
    'Es gibt viel zu entdecken. Klick einen Aspekt an, ich vertiefe ihn.',
    'Spannende Geschichten warten. Wähle einen Einstieg.',
    'Das Thema hat viele Ecken und Kanten. Entscheide dich für eine.',
    'Interessante Aspekte gibt es genug. Nimm einen – ich erzähle dazu.',
    'Hier ist für jeden etwas dabei. Wähle einen Fokus, dann lege ich los.',
    'Viele Türen führen in dieses Thema. Öffne eine, ich führe dich weiter.',
    'Ein reiches Thema – such dir einen Zugang aus.',
    'Spannende Einzelheiten warten. Klick einen an, ich fülle die Lücken.',
  ];

  static final List<String> _introPhrasesRu = [
    'По этой теме есть много интересного. Выбери один аспект — и я расскажу о нём подробнее.',
    'У этой темы много граней. Выбери одну — и я её раскрою.',
    'Тут есть что открыть. Выбери пункт — я расскажу.',
    'Интересных поворотов хватает. Выбери один — я продолжу.',
    'Тема богатая. Выбери угол — и я начну.',
    'Можно копать вглубь с разных сторон. Выбери сторону.',
    'Здесь много любопытного. Выбери один пункт — я его разверну.',
    'Есть о чём поговорить. Выбери аспект — я подхвачу.',
    'Тема с сюрпризами. Выбери один — расскажу.',
    'Разных входов в тему много. Выбери один — пойдём дальше.',
    'Интересных деталей достаточно. Выбери одну — я дополню.',
    'Тут есть с чего начать. Выбери начало.',
    'Тема глубокая — выбери угол, и я расскажу.',
    'Много любопытных ниточек. Выбери одну — я потяну.',
    'Есть о чём рассказать. Выбери фокус.',
    'Тема с разными гранями. Выбери грань — я её покажу.',
    'Здесь немало интересного. Выбери один пункт.',
    'Можно зайти с разных сторон. Выбери сторону.',
    'Богатая тема — выбери вход, и начнём.',
    'Интересных деталей хватает. Выбери одну — я расскажу.',
  ];

  /// Краткий вводный текст; один из набора выбирается случайно при каждом новом чате.
  Future<String> generateInitialMessage(String topic) async {
    if (_apiKey.isEmpty) {
      return _isGerman
          ? 'Fehler: API-Schlüssel nicht in .env-Datei gefunden'
          : 'Ошибка: API ключ не найден в .env файле';
    }
    final list = _isGerman ? _introPhrasesDe : _introPhrasesRu;
    return list[Random().nextInt(list.length)];
  }
}

