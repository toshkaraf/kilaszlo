import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Возвращает URL одной подходящей по запросу фотографии (Unsplash).
/// Если ключа нет или запрос не удался — возвращает null.
Future<String?> fetchImageUrlForQuery(String query) async {
  final accessKey = (dotenv.env['UNSPLASH_ACCESS_KEY'] ?? '').trim();
  if (accessKey.isEmpty) {
    debugPrint('[Unsplash] Ключ UNSPLASH_ACCESS_KEY не задан в .env');
    return null;
  }

  final q = query.trim();
  if (q.isEmpty) return null;

  try {
    final uri = Uri.parse(
      'https://api.unsplash.com/search/photos'
      '?query=${Uri.encodeComponent(q)}'
      '&per_page=1'
      '&client_id=$accessKey',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      debugPrint('[Unsplash] HTTP ${response.statusCode} для запроса "$q": ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) {
      debugPrint('[Unsplash] Нет результатов для "$q"');
      return null;
    }

    final first = results[0] as Map<String, dynamic>;
    final urls = first['urls'] as Map<String, dynamic>?;
    if (urls == null) {
      debugPrint('[Unsplash] В ответе нет urls');
      return null;
    }

    final url = urls['regular'] as String? ?? urls['small'] as String? ?? urls['thumb'] as String?;
    if (url != null) debugPrint('[Unsplash] Получен URL для "$q"');
    return url;
  } catch (e, st) {
    debugPrint('[Unsplash] Ошибка: $e');
    debugPrint(st.toString());
    return null;
  }
}
