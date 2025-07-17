import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:mime/mime.dart';
import '../models/user_message.dart';
import '../models/chat_message.dart';

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
  Uint8List? _fileBytes;
  String? _fileName;
  String? _mimeType;

  Future<void> _pickAndAttach() async {
    final typeGroup = XTypeGroup(label: 'any', mimeTypes: ['*/*']);
    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final name = file.name;
    final mime = lookupMimeType(name) ?? 'application/octet-stream';

    setState(() {
      _fileBytes = bytes;
      _fileName = name;
      _mimeType = mime;
    });
  }

  void _clearAttachment() {
    setState(() {
      _fileBytes = null;
      _fileName = null;
      _mimeType = null;
    });
  }

  void _send() {
    final text = widget.controller.text.trim();
    if (text.isEmpty && _fileBytes == null) return;

    final msg = UserMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      timestamp: DateTime.now(),
      fileBytes: _fileBytes,
      fileName: _fileName,
      mimeType: _mimeType,
    );

    widget.onSend(msg);

    // очистить после отправки
    widget.controller.clear();
    _clearAttachment();
  }

  @override
  Widget build(BuildContext context) {
    final hasAttachment = _fileBytes != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasAttachment)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              children: [
                _buildFileIcon(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _fileName ?? 'файл',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clearAttachment,
                  tooltip: 'Удалить вложение',
                ),
              ],
            ),
          ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _pickAndAttach,
              tooltip: 'Прикрепить файл',
            ),
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
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _send,
              tooltip: 'Отправить',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFileIcon() {
    final mime = _mimeType ?? '';
    if (mime.startsWith('image/')) return const Icon(Icons.image, color: Colors.blue);
    if (mime.startsWith('video/')) return const Icon(Icons.videocam, color: Colors.deepPurple);
    if (mime.startsWith('audio/')) return const Icon(Icons.audiotrack, color: Colors.green);
    return const Icon(Icons.insert_drive_file, color: Colors.grey);
  }
}
