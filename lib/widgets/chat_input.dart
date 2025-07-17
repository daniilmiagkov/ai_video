import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:mime/mime.dart';

import '../models/user_message.dart';
import '../models/attachment.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final void Function(UserMessage) onSend;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final List<Attachment> _attachments = [];

  Future<void> _pickAttachment() async {
    final typeGroup = XTypeGroup(label: 'any', mimeTypes: ['*/*']);
    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final name = file.name;
    final mime = lookupMimeType(name) ?? 'application/octet-stream';

    setState(() {
      _attachments.add(Attachment(name: name, mime: mime, bytes: bytes));
    });
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  void _send() {
    final text = widget.controller.text.trim();
    if (text.isEmpty && _attachments.isEmpty) return;

    final msg = UserMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      timestamp: DateTime.now(),
      attachments: List.from(_attachments),
    );
    widget.onSend(msg);

    widget.controller.clear();
    setState(() {
      _attachments.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Превью всех вложений
        if (_attachments.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _attachments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final att = _attachments[i];
                return Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: att.mime.startsWith('image/')
                          ? Image.memory(att.bytes, fit: BoxFit.cover)
                          : Icon(
                              att.mime.startsWith('video/') ? Icons.videocam
                              : att.mime.startsWith('audio/') ? Icons.audiotrack
                              : Icons.insert_drive_file,
                              size: 40, color: Colors.grey.shade600,
                            ),
                      ),
                    ),
                    Positioned(
                      top: -6, right: -6,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => _removeAttachment(i),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        // Поле ввода
        Row(
          children: [
            IconButton(icon: const Icon(Icons.attach_file), onPressed: _pickAttachment),
            Expanded(
              child: TextField(
                controller: widget.controller,
                decoration: const InputDecoration(
                  hintText: 'Написать сообщение…',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            IconButton(icon: const Icon(Icons.send), onPressed: _send),
          ],
        ),
      ],
    );
  }
}
