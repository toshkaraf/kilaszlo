import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../providers/language_provider.dart';
import '../models/theme_data.dart';
import '../l10n/app_localizations.dart';

class ChatHistoryPage extends StatelessWidget {
  const ChatHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            final l10n = AppLocalizations(languageProvider.currentLanguage);
            return Text(l10n.chatHistory);
          },
        ),
        backgroundColor: const Color(0xFF27AE60),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<ChatProvider, LanguageProvider>(
        builder: (context, chatProvider, languageProvider, _) {
          final chats = chatProvider.chatHistory;
          final l10n = AppLocalizations(languageProvider.currentLanguage);
          final isGerman = languageProvider.isGerman;

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isGerman ? 'Chat-Verlauf ist leer' : 'История чатов пуста',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      isGerman ? 'Neuen Chat beginnen' : 'Начать новый чат',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[chats.length - 1 - index]; // Reverse order
              return _buildChatTile(context, chat, chatProvider, isGerman, l10n);
            },
          );
        },
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context,
    dynamic chat,
    ChatProvider chatProvider,
    bool isGerman,
    AppLocalizations l10n,
  ) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final formattedDate = dateFormat.format(chat.lastUpdated);
    
    // Получаем переведенное название темы
    String displayTopicName = chat.topicName;
    if (chat.parentTopicName != null) {
      // Если есть родительская тема, показываем оба
      final parentTopic = Topic(id: '', name: chat.parentTopicName);
      final subtopic = Topic(id: chat.topicId, name: chat.topicName);
      displayTopicName = '${parentTopic.getName(isGerman)} - ${subtopic.getName(isGerman)}';
    } else {
      // Иначе используем перевод для основной темы
      final topic = Topic(id: chat.topicId, name: chat.topicName);
      displayTopicName = topic.getName(isGerman);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () async {
            await chatProvider.loadChat(chat);
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayTopicName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF95A5A6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isGerman 
                            ? '${chat.messages.length} Nachrichten'
                            : '${chat.messages.length} сообщений',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFBDC3C7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton(
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      child: Text(isGerman ? 'Löschen' : 'Удалить'),
                      onTap: () {
                        _showDeleteConfirmation(
                          context,
                          chat.id,
                          displayTopicName,
                          chatProvider,
                          isGerman,
                        );
                      },
                    ),
                  ],
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF95A5A6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String chatId,
    String chatName,
    ChatProvider chatProvider,
    bool isGerman,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isGerman ? 'Chat löschen?' : 'Удалить чат?'),
          content: Text(isGerman 
              ? 'Sind Sie sicher, dass Sie den Chat "$chatName" löschen möchten?'
              : 'Вы уверены, что хотите удалить чат "$chatName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isGerman ? 'Abbrechen' : 'Отмена'),
            ),
            TextButton(
              onPressed: () {
                chatProvider.deleteChat(chatId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isGerman ? 'Chat gelöscht' : 'Чат удален'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                isGerman ? 'Löschen' : 'Удалить',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
