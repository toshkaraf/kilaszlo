import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/chat_provider.dart';
import '../models/chat.dart';

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
    await _tts.setLanguage('ru_RU');
    await _tts.setSpeechRate(0.8);

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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final messages = chatProvider.currentChat?.messages ?? [];

        return WillPopScope(
          onWillPop: () async {
            chatProvider.clearSelection();
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                chatProvider.selectedTopic?.name ?? 'Чат',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              backgroundColor: const Color(0xFF3498DB),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  chatProvider.clearSelection();
                  Navigator.pop(context);
                },
              ),
            ),
            body: Column(
              children: [
                // Messages list
                Expanded(
                  child: messages.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return _buildMessageBubble(
                              context,
                              message,
                              chatProvider,
                            );
                          },
                        ),
                ),

                // Suggested responses or input
                if (messages.isNotEmpty && !messages.last.isUser)
                  _buildSuggestedResponses(context, messages.last, chatProvider),

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
        );
      },
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessage message,
    ChatProvider chatProvider,
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
                      fontSize: 16,
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
                          onTap: () =>
                              _speak(message.text, message.id),
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
                                      ? 'СТОП'
                                      : 'ОЗВУЧИТЬ',
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
                await chatProvider.sendMessage('Продолжи разговор');
              },
              borderRadius: BorderRadius.circular(12),
              child: const Center(
                child: Text(
                  'ПРОДОЛЖИТЬ РАЗГОВОР',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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
                        await chatProvider.sendMessage(suggestion);
                        _scrollToBottom();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          suggestion,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
