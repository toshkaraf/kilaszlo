class ChatMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isUser;
  final List<String>? suggestedResponses;

  ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isUser,
    this.suggestedResponses,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isUser': isUser,
      'suggestedResponses': suggestedResponses,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isUser: json['isUser'] as bool,
      suggestedResponses: json['suggestedResponses'] != null
          ? List<String>.from(json['suggestedResponses'] as List)
          : null,
    );
  }
}

class Chat {
  final String id;
  final String topicId;
  final String topicName;
  final String? parentTopicName; // Основная тема, если выбрана подтема
  final DateTime createdAt;
  final DateTime lastUpdated;
  final List<ChatMessage> messages;

  Chat({
    required this.id,
    required this.topicId,
    required this.topicName,
    this.parentTopicName,
    required this.createdAt,
    required this.lastUpdated,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicId': topicId,
      'topicName': topicName,
      'parentTopicName': parentTopicName,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      topicId: json['topicId'] as String,
      topicName: json['topicName'] as String,
      parentTopicName: json['parentTopicName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
