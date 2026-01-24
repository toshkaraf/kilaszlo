import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/chat.dart';

class ChatStorageService {
  static const String _chatsKey = 'kilaszlo_chats';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Chat>> getAllChats() async {
    final chatsJson = _prefs.getStringList(_chatsKey) ?? [];
    return chatsJson
        .map((json) => Chat.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  Future<Chat?> getChatById(String id) async {
    final chats = await getAllChats();
    try {
      return chats.firstWhere((chat) => chat.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveChat(Chat chat) async {
    final chats = await getAllChats();
    final index = chats.indexWhere((c) => c.id == chat.id);

    if (index >= 0) {
      chats[index] = chat;
    } else {
      chats.add(chat);
    }

    final chatsJson =
        chats.map((c) => jsonEncode(c.toJson())).toList();
    await _prefs.setStringList(_chatsKey, chatsJson);
  }

  Future<void> deleteChat(String id) async {
    final chats = await getAllChats();
    chats.removeWhere((c) => c.id == id);
    final chatsJson =
        chats.map((c) => jsonEncode(c.toJson())).toList();
    await _prefs.setStringList(_chatsKey, chatsJson);
  }

  Future<Chat> createNewChat(String topicId, String topicName) async {
    final now = DateTime.now();
    final chat = Chat(
      id: const Uuid().v4(),
      topicId: topicId,
      topicName: topicName,
      createdAt: now,
      lastUpdated: now,
      messages: [],
    );

    await saveChat(chat);
    return chat;
  }

  Future<void> addMessageToChat(String chatId, ChatMessage message) async {
    final chat = await getChatById(chatId);
    if (chat != null) {
      final updatedChat = Chat(
        id: chat.id,
        topicId: chat.topicId,
        topicName: chat.topicName,
        createdAt: chat.createdAt,
        lastUpdated: DateTime.now(),
        messages: [...chat.messages, message],
      );
      await saveChat(updatedChat);
    }
  }

  Future<void> clearAllChats() async {
    await _prefs.remove(_chatsKey);
  }
}
