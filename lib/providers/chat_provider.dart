import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/theme_data.dart';
import '../models/chat.dart';
import '../services/chat_storage_service.dart';
import '../services/gemini_service.dart';
import 'language_provider.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final ChatStorageService storageService;
  final GeminiService aiService = GeminiService();
  
  void updateLanguage(AppLanguage language) {
    aiService.setLanguage(language);
  }

  Chat? currentChat;
  List<Chat> chatHistory = [];
  ThemeCategory? selectedCategory;
  ThemeSubcategory? selectedSubcategory;
  Topic? selectedTopic;
  bool isLoading = false;
  String? errorMessage;
  /// Для кнопки «Повторить» после ошибки (например квота).
  String? _lastUserMessage;
  AppLanguage? _lastLanguage;

  ChatProvider({required this.storageService}) {
    // Устанавливаем немецкий язык по умолчанию для AI сервиса
    aiService.setLanguage(AppLanguage.german);
    _init();
  }

  Future<void> _init() async {
    chatHistory = await storageService.getAllChats();
    notifyListeners();
  }

  Future<void> startNewChat(Topic topic, {AppLanguage? language, Topic? parentTopic}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      selectedTopic = topic;
      final isGerman = language == AppLanguage.german;
      final parentName = parentTopic?.getName(isGerman);
      final topicName = topic.getName(isGerman);
      final fullTopicName = parentName != null 
          ? '$parentName - $topicName'
          : topicName;
      currentChat = await storageService.createNewChat(
        topic.id, 
        topicName,
        parentTopicName: parentName,
      );

      // Update language if provided
      if (language != null) {
        aiService.setLanguage(language);
      }

      // Intro + 5 фактов для кнопок
      final initialMessage =
          await aiService.generateInitialMessage(fullTopicName);
      final suggestions = await aiService.generateInitialFactSuggestions(fullTopicName);

      final aiMessage = ChatMessage(
        id: const Uuid().v4(),
        text: initialMessage,
        timestamp: DateTime.now(),
        isUser: false,
        suggestedResponses: suggestions,
      );

      await storageService.addMessageToChat(currentChat!.id, aiMessage);
      currentChat = await storageService.getChatById(currentChat!.id);

      chatHistory = await storageService.getAllChats();
    } catch (e, stackTrace) {
      debugPrint('[ChatProvider.startNewChat] $e');
      debugPrint(stackTrace.toString());
      errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Ошибка при создании чата: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String userText, {AppLanguage? language}) async {
    if (currentChat == null) return;

    _lastUserMessage = userText;
    _lastLanguage = language;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (language != null) {
        aiService.setLanguage(language);
      }

      final isGerman = language == AppLanguage.german;
      final defaultTopic = isGerman ? 'Allgemeine Information' : 'Общая информация';
      
      String fullTopicName;
      if (currentChat!.parentTopicName != null && selectedTopic != null) {
        final parentName = currentChat!.parentTopicName!;
        final subtopicName = selectedTopic!.getName(isGerman);
        fullTopicName = '$parentName - $subtopicName';
      } else {
        fullTopicName = selectedTopic?.getName(isGerman) ?? defaultTopic;
      }

      // Kontext: letzte Nachrichten (User + AI), damit die Antwort zum gewählten Fakt passt
      final messages = currentChat!.messages;
      final contextLines = <String>[];
      final start = messages.length > 6 ? messages.length - 6 : 0;
      for (var i = start; i < messages.length; i++) {
        final m = messages[i];
        contextLines.add('${m.isUser ? "Nutzer" : "Assistent"}: ${m.text}');
      }
      final conversationContext = contextLines.isNotEmpty ? contextLines : null;

      final aiResponse = await aiService.generateAIResponse(
        fullTopicName,
        userText,
        conversationContext: conversationContext,
      );

      final suggestionExcerpt = aiResponse.length > 500
          ? '${aiResponse.substring(0, 500)}...'
          : aiResponse;
      final suggestions = await aiService.generateFollowUpFactSuggestions(
        fullTopicName,
        userText,
        suggestionExcerpt,
      );

      final userMessage = ChatMessage(
        id: const Uuid().v4(),
        text: userText,
        timestamp: DateTime.now(),
        isUser: true,
      );
      final aiMessage = ChatMessage(
        id: const Uuid().v4(),
        text: aiResponse,
        timestamp: DateTime.now(),
        isUser: false,
        suggestedResponses: suggestions,
      );
      await storageService.addMessageToChat(currentChat!.id, userMessage);
      await storageService.addMessageToChat(currentChat!.id, aiMessage);
      currentChat = await storageService.getChatById(currentChat!.id);

      chatHistory = await storageService.getAllChats();
    } catch (e, stackTrace) {
      debugPrint('[ChatProvider.sendMessage] $e');
      debugPrint(stackTrace.toString());
      errorMessage = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadChat(Chat chat) async {
    currentChat = chat;
    selectedTopic = Topic(id: chat.topicId, name: chat.topicName);
    // Если есть parentTopicName, это была подтема, но selectedTopic хранит подтему
    notifyListeners();
  }

  Future<void> deleteChat(String chatId) async {
    await storageService.deleteChat(chatId);
    chatHistory = await storageService.getAllChats();
    if (currentChat?.id == chatId) {
      currentChat = null;
    }
    notifyListeners();
  }

  void selectCategory(ThemeCategory category) {
    selectedCategory = category;
    selectedSubcategory = null;
    selectedTopic = null;
    notifyListeners();
  }

  void selectSubcategory(ThemeSubcategory subcategory) {
    selectedSubcategory = subcategory;
    selectedTopic = null;
    notifyListeners();
  }

  void selectTopic(Topic topic) {
    selectedTopic = topic;
    notifyListeners();
  }

  void clearSelection() {
    selectedCategory = null;
    selectedSubcategory = null;
    selectedTopic = null;
    currentChat = null;
    notifyListeners();
  }

  /// Повторить последний запрос (например после ошибки квоты).
  bool get canRetry => _lastUserMessage != null && _lastUserMessage!.isNotEmpty;

  Future<void> retryLastMessage({AppLanguage? language}) async {
    final text = _lastUserMessage;
    if (text == null || text.isEmpty || currentChat == null) return;
    errorMessage = null;
    await sendMessage(text, language: language ?? _lastLanguage);
  }
}
