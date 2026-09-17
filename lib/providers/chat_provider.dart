import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/theme_data.dart';
import '../models/chat.dart';
import '../services/chat_storage_service.dart';
import '../services/deepseek_service.dart';
import 'language_provider.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final ChatStorageService storageService;
  final DeepSeekService aiService = DeepSeekService();
  static const Duration _rateLimitCooldown = Duration(seconds: 30);
  
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
  DateTime? _aiCooldownUntil;
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
    if (_isCooldownActive()) {
      errorMessage = _buildAiUnavailableMessage(language);
      notifyListeners();
      return;
    }
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
      List<String> suggestions = const [];
      try {
        suggestions = await aiService.generateInitialFactSuggestions(fullTopicName);
      } catch (e, stackTrace) {
        debugPrint('[ChatProvider.startNewChat.suggestions] $e');
        debugPrint(stackTrace.toString());
      }

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
      if (_isRateLimitError(e.toString())) {
        _aiCooldownUntil = DateTime.now().add(_rateLimitCooldown);
        errorMessage = _buildAiUnavailableMessage(language);
      } else {
        errorMessage = e is Exception
            ? e.toString().replaceFirst('Exception: ', '')
            : 'Ошибка при создании чата: $e';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String userText, {AppLanguage? language}) async {
    if (currentChat == null) return;
    if (_isCooldownActive()) {
      errorMessage = _buildAiUnavailableMessage(language);
      notifyListeners();
      return;
    }

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
      List<String> suggestions = const [];
      try {
        suggestions = await aiService.generateFollowUpFactSuggestions(
          fullTopicName,
          userText,
          suggestionExcerpt,
        );
      } catch (e, stackTrace) {
        debugPrint('[ChatProvider.sendMessage.suggestions] $e');
        debugPrint(stackTrace.toString());
      }

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
      if (_isRateLimitError(e.toString())) {
        _aiCooldownUntil = DateTime.now().add(_rateLimitCooldown);
        errorMessage = _buildAiUnavailableMessage(language);
      } else {
        errorMessage = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      }
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

  /// Возврат на один шаг назад — со списка тем на список подкатегорий,
  /// не сбрасывая выбранную категорию.
  void clearSubcategory() {
    selectedSubcategory = null;
    selectedTopic = null;
    notifyListeners();
  }

  void clearSelection() {
    selectedCategory = null;
    selectedSubcategory = null;
    selectedTopic = null;
    currentChat = null;
    notifyListeners();
  }

  /// Закрывает текущий чат (кнопка «Назад» в ChatPage), не трогая
  /// выбранную категорию/подкатегорию — чат открывается как отдельный
  /// экран поверх списка тем, поэтому «Назад» просто возвращает на него.
  void exitChat() {
    currentChat = null;
    notifyListeners();
  }

  /// Повторить последний запрос (например после ошибки квоты).
  bool get canRetry => _lastUserMessage != null && _lastUserMessage!.isNotEmpty;
  bool get isAiTemporarilyUnavailable => _isCooldownActive();
  int get aiRetryAfterSeconds {
    if (_aiCooldownUntil == null) return 0;
    final diff = _aiCooldownUntil!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  Future<void> retryLastMessage({AppLanguage? language}) async {
    final text = _lastUserMessage;
    if (text == null || text.isEmpty || currentChat == null) return;
    if (_isCooldownActive()) {
      errorMessage = _buildAiUnavailableMessage(language ?? _lastLanguage);
      notifyListeners();
      return;
    }
    errorMessage = null;
    await sendMessage(text, language: language ?? _lastLanguage);
  }

  bool _isCooldownActive() {
    if (_aiCooldownUntil == null) return false;
    if (DateTime.now().isAfter(_aiCooldownUntil!)) {
      _aiCooldownUntil = null;
      return false;
    }
    return true;
  }

  bool _isRateLimitError(String message) {
    final normalized = message.toUpperCase();
    return normalized.contains('429') || normalized.contains('RESOURCE_EXHAUSTED');
  }

  String _buildAiUnavailableMessage(AppLanguage? language) {
    final isGerman = language == AppLanguage.german;
    final seconds = aiRetryAfterSeconds;
    if (isGerman) {
      return 'Der KI-Dienst ist vorübergehend überlastet (429). '
          'Bitte versuche es in ${seconds}s erneut.';
    }
    return 'Сервис ИИ временно перегружен (429). '
        'Повторите попытку через ${seconds} сек.';
  }
}
