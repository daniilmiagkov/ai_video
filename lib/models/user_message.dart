// lib/models/user_message.dart

import 'dart:convert';
import 'dart:typed_data';
import 'attachment.dart';

class UserMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final List<Attachment> attachments;

  UserMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    this.attachments = const [],
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'text': text,
      'type': attachments.isEmpty ? 'text' : 'attachment',
    };

    if (attachments.isNotEmpty) {
      // Формируем список JSON-объектов для каждого вложения
      map['attachments'] = attachments.map((a) {
        return <String, dynamic>{
          'name': a.name,
          'mime': a.mime,
          'data': base64Encode(a.bytes),
        };
      }).toList();
    }

    return map;
  }

  factory UserMessage.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] as String?) ?? 'text';
    final id = (json['id'] as String?) ?? '';
    final timestamp = DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now();
    final text = (json['text'] as String?) ?? '';

    if (type == 'attachment') {
      final attachmentsJson = json['attachments'] as List<dynamic>? ?? [];
      final attachments = attachmentsJson.map((item) {
        final name = item['name'] as String? ?? '';
        final mime = item['mime'] as String? ?? 'application/octet-stream';
        final dataStr = item['data'] as String? ?? '';
        final bytes = base64Decode(dataStr);
        return Attachment(name: name, mime: mime, bytes: Uint8List.fromList(bytes));
      }).toList();

      return UserMessage(
        id: id,
        text: text,
        timestamp: timestamp,
        attachments: attachments,
      );
    } else {
      return UserMessage(
        id: id,
        text: text,
        timestamp: timestamp,
        attachments: const [],
      );
    }
  }
}
