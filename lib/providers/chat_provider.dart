import 'package:flutter/material.dart';
import '../models/theme_data.dart';
import '../models/chat.dart';
import '../services/chat_storage_service.dart';
import '../services/anthropic_service.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final ChatStorageService storageService;
  final AnthropicService aiService = AnthropicService();

  Chat? currentChat;
  List<Chat> chatHistory = [];
  ThemeCategory? selectedCategory;
  ThemeSubcategory? selectedSubcategory;
  Topic? selectedTopic;
  bool isLoading = false;
  String? errorMessage;

  ChatProvider({required this.storageService}) {
    _init();
  }

  Future<void> _init() async {
    chatHistory = await storageService.getAllChats();
    notifyListeners();
  }

  Future<void> startNewChat(Topic topic) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      selectedTopic = topic;
      currentChat = await storageService.createNewChat(topic.id, topic.name);

      // Get initial message from AI
      final initialMessage =
          await aiService.generateInitialMessage(topic.name);
      
      // Get suggested responses
      final suggestions =
          await aiService.generateSuggestedResponses(topic.name);

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

  Future<void> sendMessage(String userText) async {
    if (currentChat == null) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Add user message
      final userMessage = ChatMessage(
        id: const Uuid().v4(),
        text: userText,
        timestamp: DateTime.now(),
        isUser: true,
      );

      await storageService.addMessageToChat(currentChat!.id, userMessage);

      // Get AI response
      final aiResponse = await aiService.generateAIResponse(
        selectedTopic?.name ?? 'Общая информация',
        userText,
      );

      // Get suggested responses for next turn
      final suggestions = await aiService.generateSuggestedResponses(userText);

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
