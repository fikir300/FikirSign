/// Identifies the author of a message in the communication stream.
enum MessageSender {
  staff,
  deaf,
  ai;

  static MessageSender fromString(String value) {
    switch (value.toLowerCase()) {
      case 'staff':
        return MessageSender.staff;
      case 'deaf':
        return MessageSender.deaf;
      case 'ai':
        return MessageSender.ai;
      default:
        return MessageSender.staff;
    }
  }

  String toValue() => name;
}

/// Identifies the modality or format of a chat message.
enum MessageType {
  text,
  sign,
  recognized,
  suggestions;

  static MessageType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'sign':
        return MessageType.sign;
      case 'recognized':
        return MessageType.recognized;
      case 'suggestions':
        return MessageType.suggestions;
      default:
        return MessageType.text;
    }
  }

  String toValue() => name;
}

/// Represents an individual chat message in the conversation timeline.
class ChatMessage {
  final String id;
  final DateTime timestamp;
  final MessageSender sender;
  final MessageType type;
  final String text;
  final String? phraseId;
  final double? confidence;

  const ChatMessage({
    required this.id,
    required this.timestamp,
    required this.sender,
    required this.type,
    required this.text,
    this.phraseId,
    this.confidence,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      sender: MessageSender.fromString(json['sender'] as String? ?? 'staff'),
      type: MessageType.fromString(json['type'] as String? ?? 'text'),
      text: json['text'] as String? ?? '',
      phraseId: json['phraseId'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'sender': sender.toValue(),
      'type': type.toValue(),
      'text': text,
      'phraseId': phraseId,
      'confidence': confidence,
    };
  }

  ChatMessage copyWith({
    String? id,
    DateTime? timestamp,
    MessageSender? sender,
    MessageType? type,
    String? text,
    String? phraseId,
    double? confidence,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      text: text ?? this.text,
      phraseId: phraseId ?? this.phraseId,
      confidence: confidence ?? this.confidence,
    );
  }
}
