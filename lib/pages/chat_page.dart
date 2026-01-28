import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/chat_provider.dart';
import '../providers/language_provider.dart';
import '../services/chat_storage_service.dart';
import '../l10n/app_localizations.dart';
import '../models/chat.dart';
import '../models/theme_data.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;

  const ChatPage({Key? key, required this.chat}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FlutterTts _tts = FlutterTts();
  late ScrollController _scrollController;
  String? _currentlyPlayingMessageId;
  bool _isSpeaking = false;
  bool _autoPlay = false;
  String? _lastAIMessageId;
  double _speechRate = 0.53;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
      setState(() => _isSpeaking = true);
    });

    _tts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _currentlyPlayingMessageId = null;
      });
    });
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

  Future<void> _speak(String text, String messageId) async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() {
        _isSpeaking = false;
        _currentlyPlayingMessageId = null;
      });
    } else {
      setState(() => _currentlyPlayingMessageId = messageId);
      await _tts.speak(text);
    }
  }

  Future<void> _repeatLastMessage() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final messages = chatProvider.currentChat?.messages ?? [];
    if (messages.isNotEmpty) {
      final lastAIMessage = messages.reversed.firstWhere(
        (m) => !m.isUser,
        orElse: () => messages.last,
      );
      if (!lastAIMessage.isUser) {
        await _speak(lastAIMessage.text, lastAIMessage.id);
      }
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

  void _checkAndAutoPlay(ChatProvider chatProvider) {
    if (_autoPlay && !chatProvider.isLoading) {
      final messages = chatProvider.currentChat?.messages ?? [];
      if (messages.isNotEmpty) {
        final lastMessage = messages.last;
        if (!lastMessage.isUser && lastMessage.id != _lastAIMessageId) {
          _lastAIMessageId = lastMessage.id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _speak(lastMessage.text, lastMessage.id);
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _tts.stop();
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
        
        // Update AI service language
        chatProvider.updateLanguage(languageProvider.currentLanguage);
        
        // Check for auto-play
        _checkAndAutoPlay(chatProvider);

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
                    _autoPlay ? Icons.volume_up : Icons.volume_off,
                    color: _autoPlay ? Colors.white : Colors.white70,
                  ),
                  tooltip: l10n.autoPlay,
                  onPressed: () {
                    setState(() {
                      _autoPlay = !_autoPlay;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.repeat),
                  tooltip: l10n.repeatLast,
                  onPressed: _repeatLastMessage,
                ),
              ],
            ),
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // Messages list
                  messages.isEmpty
                      ? const SizedBox(
                          height: 400,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return _buildMessageBubble(
                              context,
                              message,
                              chatProvider,
                              l10n,
                            );
                          },
                        ),

                  // Suggested responses or input
                  if (messages.isNotEmpty && !messages.last.isUser)
                    _buildSuggestedResponses(context, messages.last, chatProvider, l10n, languageProvider),

                  // Loading indicator
                  if (chatProvider.isLoading)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: const CircularProgressIndicator(),
                    ),

                  // Error message
                  if (chatProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          chatProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessage message,
    ChatProvider chatProvider,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? const Color(0xFF3498DB)
                        : const Color(0xFFECF0F1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 20,
                      color: message.isUser ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
                if (!message.isUser)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      height: 50,
                      child: Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(25),
                        color: _currentlyPlayingMessageId == message.id
                            ? Colors.red
                            : const Color(0xFF27AE60),
                        child: InkWell(
                          onTap: () => _speak(message.text, message.id),
                          borderRadius: BorderRadius.circular(25),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _currentlyPlayingMessageId == message.id
                                      ? Icons.stop
                                      : Icons.volume_up,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _currentlyPlayingMessageId == message.id
                                      ? l10n.stop
                                      : l10n.speak,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedResponses(
    BuildContext context,
    ChatMessage lastMessage,
    ChatProvider chatProvider,
    AppLocalizations l10n,
    LanguageProvider languageProvider,
  ) {
    final suggestions = lastMessage.suggestedResponses ?? [];

    if (suggestions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF3498DB),
            child: InkWell(
              onTap: () async {
                final continueText = l10n.isGerman 
                    ? 'Setze das Gespräch fort' 
                    : 'Продолжи разговор';
                await chatProvider.sendMessage(continueText, language: languageProvider.currentLanguage);
              },
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Text(
                  l10n.continueChat,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
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
                        _scrollToBottom();
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
