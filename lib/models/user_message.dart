// lib/models/user_message.dart
import 'dart:convert';
import 'dart:typed_data';

class UserMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final String? fileName;
  final String? mimeType;
  final Uint8List? fileBytes;

  UserMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    this.fileName,
    this.mimeType,
    this.fileBytes,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'timestamp': timestamp.toUtc().toIso8601String(),
    };

    if (fileBytes != null) {
      // При наличии файла — это attachment
      map['type'] = 'attachment';
      map['fileName'] = fileName!;
      map['mimeType'] = mimeType!;
      map['data'] = base64Encode(fileBytes!);
      // можно включить текст, если нужно:
      if (text.isNotEmpty) map['text'] = text;
    } else {
      // Просто текстовое сообщение
      map['type'] = 'text';
      map['text'] = text;
    }

    return map;
  }

  factory UserMessage.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'text';
    if (type == 'attachment') {
      final dataStr = json['data'] as String? ?? '';
      return UserMessage(
        id: json['id'] ?? '',
        timestamp: DateTime.parse(json['timestamp'] ?? ''),
        text: json['text'] ?? '',
        fileName: json['fileName'],
        mimeType: json['mimeType'],
        fileBytes: base64Decode(dataStr),
      );
    } else {
      return UserMessage(
        id: json['id'] ?? '',
        timestamp: DateTime.parse(json['timestamp'] ?? ''),
        text: json['text'] ?? '',
      );
    }
  }
}
