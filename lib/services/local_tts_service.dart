// Copyright: см. MODEL_CARD в assets/tts — голос "Thorsten" (CC0),
// синтез через sherpa-onnx (Apache-2.0, https://github.com/k2-fsa/sherpa-onnx).
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

/// Полностью локальный, офлайн немецкий голос (VITS/Piper "Thorsten",
/// движок sherpa-onnx). Модель распаковывается один раз при первом запуске
/// в каталог приложения, дальше синтез речи выполняется на устройстве —
/// без интернета, без ключей и без лимитов.
///
/// Сама генерация выполняется в фоновом изоляте, чтобы не подвешивать UI.
class LocalTtsService {
  static const String _archiveAsset =
      'assets/tts/vits-piper-de_DE-thorsten-medium.tar.bz2';
  static const String _modelDirName = 'vits-piper-de_DE-thorsten-medium';
  static const String _modelFileName = 'de_DE-thorsten-medium.onnx';

  Isolate? _isolate;
  SendPort? _sendPort;
  Completer<void>? _readyCompleter;
  final Map<int, Completer<_SynthResult>> _pending = {};
  int _nextId = 0;
  bool _bindingsInitialized = false;

  bool get isReady => _sendPort != null;

  /// Готовит модель и поднимает фоновый изолят синтеза. Можно вызывать
  /// заранее (например, при открытии чата), чтобы к моменту первого
  /// ответа ИИ голос уже был готов. Повторные вызовы не делают лишней работы.
  Future<void> ensureInitialized() async {
    if (_sendPort != null) return;
    if (_readyCompleter != null) return _readyCompleter!.future;

    final completer = Completer<void>();
    _readyCompleter = completer;

    try {
      final modelDir = await _ensureModelExtracted();

      final receivePort = ReceivePort();
      _isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);

      receivePort.listen((message) {
        if (message is SendPort) {
          _sendPort = message;
          message.send(_InitRequest(modelDir));
        } else if (message is _Ready) {
          if (!completer.isCompleted) completer.complete();
        } else if (message is _InitError) {
          if (!completer.isCompleted) completer.completeError(message.error);
          _readyCompleter = null;
        } else if (message is _SynthDone) {
          _pending.remove(message.id)?.complete(
                _SynthResult(message.samples, message.sampleRate),
              );
        } else if (message is _SynthError) {
          _pending.remove(message.id)?.completeError(message.error);
        }
      });

      await completer.future;
    } catch (e) {
      _readyCompleter = null;
      rethrow;
    }
  }

  /// Синтезирует речь и сохраняет её во временный WAV-файл.
  /// Возвращает путь к файлу или null при ошибке.
  Future<String?> synthesizeToWavFile(String text, {double speed = 1.0}) async {
    final t = text.trim();
    if (t.isEmpty) return null;
    try {
      await ensureInitialized();
      final id = _nextId++;
      final completer = Completer<_SynthResult>();
      _pending[id] = completer;
      _sendPort!.send(_SynthRequest(id, t, speed));
      final result = await completer.future;

      if (!_bindingsInitialized) {
        sherpa_onnx.initBindings();
        _bindingsInitialized = true;
      }
      final tempDir = await getTemporaryDirectory();
      final path = p.join(
        tempDir.path,
        'local_tts_${DateTime.now().millisecondsSinceEpoch}.wav',
      );
      final ok = sherpa_onnx.writeWave(
        filename: path,
        samples: result.samples,
        sampleRate: result.sampleRate,
      );
      return ok ? path : null;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _readyCompleter = null;
    _pending.clear();
  }

  /// Распаковывает модель из assets в Application Support Directory
  /// (один раз — при повторных запусках проверяет файл-маркер).
  Future<String> _ensureModelExtracted() async {
    final supportDir = (await getApplicationSupportDirectory()).path;
    final targetDir = p.join(supportDir, _modelDirName);
    final marker = File(p.join(targetDir, '.extracted'));
    if (await marker.exists()) return targetDir;

    final data = await rootBundle.load(_archiveAsset);
    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final tarBytes = BZip2Decoder().decodeBytes(bytes);
    final archive = TarDecoder().decodeBytes(tarBytes);

    for (final entry in archive) {
      // Записи архива вида "vits-piper-de_DE-thorsten-medium/espeak-ng-data/...".
      final parts = p.split(entry.name);
      final relative = parts.length > 1 ? p.joinAll(parts.sublist(1)) : '';
      if (relative.isEmpty) continue;
      final outPath = p.join(targetDir, relative);
      if (entry.isFile) {
        final outFile = File(outPath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(entry.content as List<int>);
      } else {
        await Directory(outPath).create(recursive: true);
      }
    }
    await marker.create(recursive: true);
    return targetDir;
  }

  // ── Фоновый изолят ──────────────────────────────────────────────────

  static void _isolateEntry(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);

    sherpa_onnx.OfflineTts? tts;

    receivePort.listen((message) {
      if (message is _InitRequest) {
        try {
          // Каждый изолят, использующий sherpa-onnx, должен сам
          // инициализировать нативные биндинги.
          sherpa_onnx.initBindings();
          tts = sherpa_onnx.OfflineTts(
            sherpa_onnx.OfflineTtsConfig(
              model: sherpa_onnx.OfflineTtsModelConfig(
                vits: sherpa_onnx.OfflineTtsVitsModelConfig(
                  model: p.join(message.modelDir, _modelFileName),
                  tokens: p.join(message.modelDir, 'tokens.txt'),
                  dataDir: p.join(message.modelDir, 'espeak-ng-data'),
                ),
                numThreads: 2,
                debug: false,
              ),
              maxNumSenetences: 1,
            ),
          );
          mainSendPort.send(_Ready());
        } catch (e) {
          mainSendPort.send(_InitError('$e'));
        }
      } else if (message is _SynthRequest) {
        final currentTts = tts;
        if (currentTts == null) {
          mainSendPort.send(_SynthError(message.id, 'TTS не инициализирован'));
          return;
        }
        try {
          final audio = currentTts.generate(
            text: message.text,
            sid: 0,
            speed: message.speed,
          );
          mainSendPort.send(_SynthDone(
            message.id,
            Float32List.fromList(audio.samples),
            audio.sampleRate,
          ));
        } catch (e) {
          mainSendPort.send(_SynthError(message.id, '$e'));
        }
      }
    });
  }
}

class _SynthResult {
  final Float32List samples;
  final int sampleRate;
  _SynthResult(this.samples, this.sampleRate);
}

class _InitRequest {
  final String modelDir;
  _InitRequest(this.modelDir);
}

class _Ready {}

class _InitError {
  final String error;
  _InitError(this.error);
}

class _SynthRequest {
  final int id;
  final String text;
  final double speed;
  _SynthRequest(this.id, this.text, this.speed);
}

class _SynthDone {
  final int id;
  final Float32List samples;
  final int sampleRate;
  _SynthDone(this.id, this.samples, this.sampleRate);
}

class _SynthError {
  final int id;
  final String error;
  _SynthError(this.id, this.error);
}
