// lib/models/attachment.dart

import 'dart:typed_data';

class Attachment {
  /// Имя файла, например "video.mp4"
  final String name;

  /// MIME‑тип, например "video/mp4"
  final String mime;

  /// Сырые байты файла
  final Uint8List bytes;

  Attachment({required this.name, required this.mime, required this.bytes});
}
