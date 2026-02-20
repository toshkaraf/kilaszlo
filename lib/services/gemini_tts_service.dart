import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Голос Gemini 2.5 TTS. Возвращает WAV-байты или null при ошибке.
/// Формат: PCM s16le 24 kHz mono -> WAV с заголовком.
Future<Uint8List?> generateSpeechFromGemini(String text, {String voiceName = 'Kore'}) async {
  final apiKey = (dotenv.env['GEMINI_API_KEY'] ?? '').trim();
  if (apiKey.isEmpty) {
    debugPrint('[Gemini TTS] Нет GEMINI_API_KEY');
    return null;
  }

  final t = text.trim();
  if (t.isEmpty) return null;

  const modelId = 'gemini-2.5-flash-preview-tts';
  final uri = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$modelId:generateContent?key=$apiKey',
  );

  final body = {
    'contents': [
      {'parts': [{'text': t}]}
    ],
    'generationConfig': {
      'responseModalities': ['AUDIO'],
      'speechConfig': {
        'voiceConfig': {
          'prebuiltVoiceConfig': {'voiceName': voiceName}
        }
      },
    },
  };

  try {
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      debugPrint('[Gemini TTS] HTTP ${response.statusCode}');
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) return null;

    final content = candidates[0] as Map<String, dynamic>;
    final contentParts = content['content']?['parts'] as List<dynamic>?;
    if (contentParts == null || contentParts.isEmpty) return null;

    final part = contentParts[0] as Map<String, dynamic>;
    final inlineData = part['inlineData'];
    if (inlineData == null) return null;

    final base64Data = (inlineData as Map<String, dynamic>)['data'] as String?;
    if (base64Data == null) return null;

    final pcmBytes = base64Decode(base64Data);
    return _pcmToWav(pcmBytes, sampleRate: 24000, channels: 1);
  } catch (e, st) {
    debugPrint('[Gemini TTS] Ошибка: $e');
    debugPrint(st.toString());
    return null;
  }
}

/// Добавляет WAV-заголовок к PCM (s16le).
Uint8List _pcmToWav(Uint8List pcm, {int sampleRate = 24000, int channels = 1}) {
  const bitsPerSample = 16;
  final byteRate = sampleRate * channels * (bitsPerSample >> 3);
  final dataSize = pcm.length;
  final fileSize = 36 + dataSize;

  final header = ByteData(44);
  header.setUint8(0, 0x52); header.setUint8(1, 0x49); header.setUint8(2, 0x46); header.setUint8(3, 0x46); // RIFF
  header.setUint32(4, fileSize, Endian.little);
  header.setUint8(8, 0x57); header.setUint8(9, 0x41); header.setUint8(10, 0x56); header.setUint8(11, 0x45); // WAVE
  header.setUint8(12, 0x66); header.setUint8(13, 0x6d); header.setUint8(14, 0x74); header.setUint8(15, 0x20); // fmt 
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little); // PCM
  header.setUint16(22, channels, Endian.little);
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, byteRate, Endian.little);
  header.setUint16(32, channels * (bitsPerSample >> 3), Endian.little);
  header.setUint16(34, bitsPerSample, Endian.little);
  header.setUint8(36, 0x64); header.setUint8(37, 0x61); header.setUint8(38, 0x74); header.setUint8(39, 0x61); // data
  header.setUint32(40, dataSize, Endian.little);

  return Uint8List.fromList([...header.buffer.asUint8List(), ...pcm]);
}
