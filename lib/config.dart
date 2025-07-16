// lib/config.dart
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  /// WebSocket URL по умолчанию
  static String get websocketUrl {
    if (kIsWeb) {
      // запуск в браузере (Flutter Web)
      return 'ws://localhost:8080';
    } else {
      // Android/iOS/desktop
      // На эмуляторе Android localhost == 10.0.2.2
      return 'ws://10.0.2.2:8080';
    }
  }

  // сюда потом можно добавить другие конфиги:
  // static String get restApiUrl => ...;
}
