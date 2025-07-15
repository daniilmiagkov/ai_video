// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _uuid = const Uuid();
  final List<ChatSession> _sessions = [];
  String _activeSessionId = '';

  @override
  void initState() {
    super.initState();
    _createNewSession();
  }

  void _createNewSession() {
    final id = _uuid.v4();
    setState(() {
      _sessions.add(ChatSession(id: id, title: 'Чат ${_sessions.length + 1}'));
      _activeSessionId = id;
    });
  }

  void _onSessionSelected(String sessionId) {
    if (sessionId.isEmpty) {
      _createNewSession();
    } else {
      setState(() {
        _activeSessionId = sessionId;
      });
    }
  }

  void _handleSend(String text) {
    final session = _sessions.firstWhere((s) => s.id == _activeSessionId);
    setState(() {
      session.messages.add(ChatMessage(id: _uuid.v4(), text: text, isUser: true));
      session.messages.add(ChatMessage(id: _uuid.v4(), text: 'Ответ ассистента...', isUser: false));
    });
  }

  @override
 @override
Widget build(BuildContext context) {
  final activeSession = _sessions.firstWhere((s) => s.id == _activeSessionId);

  return GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    child: Scaffold(
      drawer: ChatSidebar(
        sessions: _sessions,
        activeSessionId: _activeSessionId,
        onSessionSelected: _onSessionSelected,
      ),
      appBar: AppBar(
        title: Text(activeSession.title),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: activeSession.messages.length,
              itemBuilder: (_, i) =>
                  ChatBubble(message: activeSession.messages[i]),
            ),
          ),
          ChatInput(onSend: _handleSend),
        ],
      ),
    ),
  );
}
}
