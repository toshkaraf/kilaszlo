import 'package:flutter/material.dart';
import '../models/theme_data.dart';
import '../models/chat.dart';
import '../services/chat_storage_service.dart';
import '../services/anthropic_service.dart';
import 'language_provider.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final ChatStorageService storageService;
  final AnthropicService aiService = AnthropicService();
  
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

      // Get initial message from AI
      final initialMessage =
          await aiService.generateInitialMessage(fullTopicName);
      
      // Get suggested responses
      final suggestions =
          await aiService.generateSuggestedResponses(fullTopicName);

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
    } catch (e) {
      errorMessage = 'Ошибка при создании чата: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String userText, {AppLanguage? language}) async {
    if (currentChat == null) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Update language if provided
      if (language != null) {
        aiService.setLanguage(language);
      }

      // Add user message
      final userMessage = ChatMessage(
        id: const Uuid().v4(),
        text: userText,
        timestamp: DateTime.now(),
        isUser: true,
      );

      await storageService.addMessageToChat(currentChat!.id, userMessage);

      final isGerman = language == AppLanguage.german;
      final defaultTopic = isGerman ? 'Allgemeine Information' : 'Общая информация';
      
      // Формируем полное название темы: основная тема + подтема (если есть)
      String fullTopicName;
      if (currentChat!.parentTopicName != null && selectedTopic != null) {
        final parentName = currentChat!.parentTopicName!;
        final subtopicName = selectedTopic!.getName(isGerman);
        fullTopicName = '$parentName - $subtopicName';
      } else {
        fullTopicName = selectedTopic?.getName(isGerman) ?? defaultTopic;
      }

      // Get AI response
      final aiResponse = await aiService.generateAIResponse(
        fullTopicName,
        userText,
      );

      // Get suggested responses for next turn
      final suggestions = await aiService.generateSuggestedResponses(
        fullTopicName,
      );

      final aiMessage = ChatMessage(
        id: const Uuid().v4(),
        text: aiResponse,
        timestamp: DateTime.now(),
        isUser: false,
        suggestedResponses: suggestions,
      );

      await storageService.addMessageToChat(currentChat!.id, aiMessage);
      currentChat = await storageService.getChatById(currentChat!.id);

      chatHistory = await storageService.getAllChats();
    } catch (e) {
      errorMessage = 'Ошибка при отправке сообщения: $e';
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
}
