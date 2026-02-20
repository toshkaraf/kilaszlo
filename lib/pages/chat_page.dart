import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/chat_provider.dart';
import '../services/gemini_tts_service.dart';
import '../providers/language_provider.dart';
import '../services/chat_storage_service.dart';
import '../l10n/app_localizations.dart';
import '../models/chat.dart';
import '../models/theme_data.dart';
import '../widgets/voice_waveform.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;

  const ChatPage({Key? key, required this.chat}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ScrollController _scrollController;
  final GlobalKey _suggestionsKey = GlobalKey();
  bool _isSpeaking = false;
  /// true только когда реально идёт воспроизведение (не во время ожидания TTS)
  bool _isAudioPlaying = false;
  bool _usingGeminiVoice = true;
  double _speechRate = 0.53;
  int _lastMessageCount = 0;
  String? _lastSpokenMessageId;

  // Очередь автоозвучки: сначала текст ответа, потом подписи кнопок
  List<String> _autoSpeakQueue = [];
  bool _isAutoSpeakMode = false;
  /// Фраза, которую сейчас читают из очереди (при паузе — дочитываем её при продолжении)
  String? _currentSpeakPhrase;

  // Состояние чтения текущего сообщения ИИ (для кнопки play/pause)
  String? _currentMessageId;
  List<String> _currentSentences = [];
  int _currentSentenceIndex = 0;
  bool _manuallyStopped = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      if (_manuallyStopped) return;
      if (_isAutoSpeakMode) {
        _currentSpeakPhrase = null;
        _speakNextInQueue();
      }
    });
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _initTts() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final storage = Provider.of<ChatStorageService>(context, listen: false);
    final languageCode = languageProvider.languageCode;
    await _tts.setLanguage(languageCode);
    final rate = await storage.getSpeechRate();
    await _tts.setSpeechRate(rate);
    if (mounted) setState(() => _speechRate = rate);

    _tts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
        _isAudioPlaying = true;
        _manuallyStopped = false;
      });
    });

    _tts.setCompletionHandler(() {
      if (_manuallyStopped) return;
      if (_isAutoSpeakMode) {
        _currentSpeakPhrase = null;
        _speakNextInQueue();
        return;
      }
      if (_currentSentenceIndex < _currentSentences.length) {
        _speakNextSentence();
      } else {
        setState(() {
          _isSpeaking = false;
          _currentMessageId = null;
          _currentSentences = [];
          _currentSentenceIndex = 0;
        });
      }
    });
  }

  void _speakNextInQueue() {
    if (_autoSpeakQueue.isEmpty) {
      setState(() {
        _isSpeaking = false;
        _isAudioPlaying = false;
        _isAutoSpeakMode = false;
        _currentSpeakPhrase = null;
      });
      return;
    }
    final next = _autoSpeakQueue.removeAt(0);
    _currentSpeakPhrase = next;
    if (_usingGeminiVoice) {
      _playPhraseWithGeminiOrFallback(next);
    } else {
      _tts.speak(next);
    }
  }

  Future<void> _playPhraseWithGeminiOrFallback(String phrase) async {
    final wavBytes = await generateSpeechFromGemini(phrase);
    if (!mounted) return;
    if (wavBytes != null) {
      try {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/gemini_tts_${DateTime.now().millisecondsSinceEpoch}.wav');
        await file.writeAsBytes(wavBytes);
        if (!mounted) return;
        setState(() => _isAudioPlaying = true);
        await _audioPlayer.play(DeviceFileSource(file.path));
        if (file.existsSync()) file.deleteSync();
      } catch (_) {
        if (mounted) _tts.speak(phrase);
      }
    } else {
      _tts.speak(phrase);
    }
  }

  void _startAutoSpeak(String messageId, String text, List<String> buttons) {
    if (messageId == _lastSpokenMessageId) return;
    _lastSpokenMessageId = messageId;
    _currentMessageId = messageId;
    _manuallyStopped = false;
    _currentSpeakPhrase = null;
    // Весь ответ — один запрос к TTS, чтобы читать подряд без пауз и без переключения голоса
    _autoSpeakQueue = [text];
    _isAutoSpeakMode = true;
    setState(() => _isSpeaking = true);
    _speakNextInQueue();
  }

  Future<void> _showSpeechRateDialog(AppLocalizations l10n) async {
    final storage = Provider.of<ChatStorageService>(context, listen: false);
    double value = _speechRate;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.speechSpeed),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: value,
                min: 0.3,
                max: 1.2,
                divisions: 18,
                onChanged: (v) {
                  value = v;
                  setDialogState(() {});
                  _tts.setSpeechRate(v);
                  storage.setSpeechRate(v);
                },
              ),
              Text(value.toStringAsFixed(2)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
            ),
          ],
        ),
      ),
    );
    if (mounted) setState(() => _speechRate = value);
  }

  Future<void> _updateTtsLanguage() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final languageCode = languageProvider.languageCode;
    await _tts.setLanguage(languageCode);
  }

  void _prepareSentences(String text) {
    _currentSentences = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
    _currentSentenceIndex = 0;
  }

  Future<void> _speakNextSentence() async {
    if (_currentSentenceIndex >= _currentSentences.length) return;
    final sentence = _currentSentences[_currentSentenceIndex];
    _currentSentenceIndex++;
    await _tts.speak(sentence);
  }

  Future<void> _playPauseLastAiMessage(ChatProvider chatProvider) async {
    final messages = chatProvider.currentChat?.messages ?? [];
    if (messages.isEmpty) return;
    final lastAIMessage = messages.reversed.firstWhere(
      (m) => !m.isUser,
      orElse: () => messages.last,
    );
    if (lastAIMessage.isUser) return;

    // Пауза: уже читаем это сообщение
    if (_isSpeaking && _currentMessageId == lastAIMessage.id) {
      _manuallyStopped = true;
      await _tts.stop();
      await _audioPlayer.stop();
      setState(() {
        _isSpeaking = false;
        _isAudioPlaying = false;
      });
      return;
    }

    // Продолжение после паузы: если были в режиме очереди (текст + кнопки)
    final canResumeQueue = _currentMessageId == lastAIMessage.id &&
        _isAutoSpeakMode &&
        (_currentSpeakPhrase != null || _autoSpeakQueue.isNotEmpty);
    if (!_isSpeaking && canResumeQueue) {
      setState(() {
        _isSpeaking = true;
        _manuallyStopped = false;
      });
      if (_currentSpeakPhrase != null) {
        final phrase = _currentSpeakPhrase!;
        if (_usingGeminiVoice) {
          _playPhraseWithGeminiOrFallback(phrase);
        } else {
          _tts.speak(phrase);
        }
      } else {
        _speakNextInQueue();
      }
      return;
    }

    // Новое сообщение или обычный режим по предложениям
    if (_currentMessageId != lastAIMessage.id) {
      _currentMessageId = lastAIMessage.id;
      _prepareSentences(lastAIMessage.text);
    }
    if (_currentSentenceIndex < _currentSentences.length) {
      await _speakNextSentence();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildChatBody(
    BuildContext context,
    List<ChatMessage> messages,
    ChatProvider chatProvider,
    LanguageProvider languageProvider,
    AppLocalizations l10n,
  ) {
    if (chatProvider.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    chatProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            if (chatProvider.canRetry)
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF3498DB),
                child: InkWell(
                  onTap: () async {
                    await chatProvider.retryLastMessage(
                      language: languageProvider.currentLanguage,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        l10n.retry,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (chatProvider.isLoading) {
      return _buildWaitingScreen(context);
    }

    if (messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final lastMsg = messages.last;
    final isLastAI = !lastMsg.isUser;
    final suggestions = lastMsg.suggestedResponses ?? [];

    // Ждём ответ или генерацию голоса — показываем заставку
    if (isLastAI && _isSpeaking && !_isAudioPlaying) {
      return _buildWaitingScreen(context);
    }

    // Реально играет голос — картинка по теме + визуализация
    if (isLastAI && _isAudioPlaying) {
      return Column(
        children: [
          Expanded(
            child: _buildFullScreenImage(lastMsg.imageUrl),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            color: const Color(0xFF3498DB),
            child: const VoiceWaveform(isSpeaking: true),
          ),
        ],
      );
    }

    if (isLastAI && suggestions.isNotEmpty) {
      // Чтение закончено — показываем только кнопки выбора
      return SingleChildScrollView(
        child: _buildSuggestedResponses(
          context,
          lastMsg,
          chatProvider,
          l10n,
          languageProvider,
          _suggestionsKey,
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildWaitingScreen(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFECF0F1),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Image.asset(
                    'assets/thinking_woman_de.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.psychology_outlined,
                      size: 120,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
              const Text(
                'Einen Moment! Ich denke über die Antwort nach.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                color: Color(0xFF3498DB),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
    );
  }

  Widget _buildFullScreenImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Container(
        width: double.infinity,
        color: Colors.black87,
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          headers: const {
            'User-Agent': 'Kilaszlo/1.0',
            'Referer': 'https://unsplash.com/',
          },
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '...',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF2C3E50),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 80,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChatProvider, LanguageProvider>(
      builder: (context, chatProvider, languageProvider, _) {
        final messages = chatProvider.currentChat?.messages ?? [];
        final l10n = AppLocalizations(languageProvider.currentLanguage);
        
        // Update TTS language when language changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateTtsLanguage();
        });

        // При появлении нового ответа ИИ запускаем озвучку (текст не показываем — только картинка + волна)
        if (messages.isNotEmpty && !messages.last.isUser) {
          final lastMsg = messages.last;
          final suggestions = lastMsg.suggestedResponses ?? [];
          if (messages.length != _lastMessageCount) {
            _lastMessageCount = messages.length;
            if (suggestions.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _startAutoSpeak(lastMsg.id, lastMsg.text, suggestions);
              });
            }
          }
        }

        chatProvider.updateLanguage(languageProvider.currentLanguage);

        return WillPopScope(
          onWillPop: () async {
            chatProvider.clearSelection();
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Builder(
                builder: (context) {
                  final topic = chatProvider.selectedTopic;
                  final chat = chatProvider.currentChat;
                  String title;
                  if (topic != null) {
                    if (chat?.parentTopicName != null) {
                      final parentTopic = Topic(id: '', name: chat!.parentTopicName!);
                      title = '${parentTopic.getName(languageProvider.isGerman)} - ${topic.getName(languageProvider.isGerman)}';
                    } else {
                      title = topic.getName(languageProvider.isGerman);
                    }
                  } else {
                    title = l10n.chat;
                  }
                  return Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  );
                },
              ),
              backgroundColor: const Color(0xFF3498DB),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  chatProvider.clearSelection();
                  // Возвращаемся на стартовый экран (HomePage)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.speed),
                  tooltip: l10n.speechSpeed,
                  onPressed: () => _showSpeechRateDialog(l10n),
                ),
                IconButton(
                  icon: Icon(
                    _isSpeaking ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: Colors.white,
                  ),
                  tooltip: l10n.autoPlay,
                  onPressed: () => _playPauseLastAiMessage(chatProvider),
                ),
                IconButton(
                  icon: const Icon(Icons.repeat),
                  tooltip: l10n.repeatLast,
                  onPressed: () async {
                    // Повторить последнее сообщение заново
                    _currentMessageId = null;
                    _currentSentences = [];
                    _currentSentenceIndex = 0;
                    await _playPauseLastAiMessage(chatProvider);
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: _buildChatBody(
                context,
                messages,
                chatProvider,
                languageProvider,
                l10n,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestedResponses(
    BuildContext context,
    ChatMessage lastMessage,
    ChatProvider chatProvider,
    AppLocalizations l10n,
    LanguageProvider languageProvider,
    GlobalKey suggestionsKey,
  ) {
    final suggestions = lastMessage.suggestedResponses ?? [];

    // Кнопки только для вариантов выбора темы; без вариантов — ничего не показываем
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      key: suggestionsKey,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: suggestions
            .map((suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF27AE60),
                    child: InkWell(
                      onTap: () async {
                        await chatProvider.sendMessage(suggestion, language: languageProvider.currentLanguage);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          suggestion,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
