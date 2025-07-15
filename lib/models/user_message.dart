class UserMessage {
  final String id;
  final String text;
  final DateTime timestamp;

  UserMessage({
    required this.id,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'user_message',
        'text': text,
        'timestamp': timestamp.toUtc().toIso8601String(),
      };
}